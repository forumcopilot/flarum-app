import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import 'tag_label.dart';

/// The forum's tags, as the web's tags page: the primary tags in the admin's
/// order, each with its child tags, then the secondary tags. A tag opens its
/// discussions.
class TagsPage extends StatefulWidget {
  const TagsPage({super.key, required this.site});

  final SiteContext site;

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  List<FlarumTag>? _tags;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    try {
      final tags = await _forum.tags(refresh: refresh);
      if (mounted) {
        setState(() {
          _tags = tags;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _open(FlarumTag tag) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TagPage(site: widget.site, tag: tag)));

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final tags = _tags;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tags)),
      body: switch ((tags, _error)) {
        (null, final Object error) => EmptyStateView.error(
            message: l10n.tagsLoadFailed,
            hint: describeFlarumError(error),
            onRetry: () => _load(refresh: true),
          ),
        (null, _) => const Center(child: CircularProgressIndicator()),
        (final List<FlarumTag> tags, _) => RefreshIndicator(
            onRefresh: () => _load(refresh: true),
            child: _list(context, tags),
          ),
      },
    );
  }

  Widget _list(BuildContext context, List<FlarumTag> tags) {
    int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
    final primary = tags.where((t) => t.isPrimary && !t.isChild).toList()..sort(byPosition);
    final secondary = tags.where((t) => !t.isPrimary).toList()
      ..sort((a, b) => b.discussionCount.compareTo(a.discussionCount));
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        for (final tag in primary) ...[
          _TagTile(tag: tag, onTap: () => _open(tag)),
          for (final child in tags.where((t) => t.parentId == tag.id).toList()..sort(byPosition))
            _TagTile(tag: child, child: true, onTap: () => _open(child)),
        ],
        if (secondary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Wrap(
              spacing: DesignTokens.spacingS,
              runSpacing: DesignTokens.spacingS,
              children: [
                for (final tag in secondary)
                  InkWell(onTap: () => _open(tag), child: TagLabel(tag: tag)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({required this.tag, required this.onTap, this.child = false});

  final FlarumTag tag;
  final VoidCallback onTap;
  final bool child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = flarumTagColor(tag) ?? colorScheme.surfaceContainerHighest;
    final onColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;
    final size = child ? 32.0 : 40.0;
    final description = tag.description;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.only(left: child ? 56 : DesignTokens.spacingL, right: DesignTokens.spacingL),
      leading: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(DesignTokens.radiusS)),
        child: Icon(flarumTagIcon(tag.icon) ?? Icons.sell_outlined, size: size * 0.55, color: onColor),
      ),
      title: Text(tag.name, style: child ? theme.textTheme.bodyLarge : theme.textTheme.titleMedium),
      subtitle: description == null || description.isEmpty || child
          ? null
          : Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text('${tag.discussionCount}',
          style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
    );
  }
}

/// One tag's discussions, latest first.
class TagPage extends StatefulWidget {
  const TagPage({super.key, required this.site, required this.tag});

  final SiteContext site;
  final FlarumTag tag;

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late final DiscussionListModel _list =
      DiscussionListModel(FlarumForum.of(widget.site), tagSlug: widget.tag.slug)..addListener(_changed);

  @override
  void initState() {
    super.initState();
    _list.refresh();
  }

  @override
  void dispose() {
    _list
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.tag.description;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        bottom: description == null || description.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
        shape: Border(bottom: BorderSide(color: flarumTagColor(widget.tag) ?? Colors.transparent, width: 3)),
      ),
      body: DiscussionListView(site: widget.site, list: _list),
    );
  }
}
