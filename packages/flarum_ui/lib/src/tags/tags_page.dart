import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/start_discussion_button.dart';
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

  Future<void> _refresh() async {
    await _load(refresh: true);
    // Failed over the tags it had: they stay, and the reader learns why.
    if (_error case final error? when mounted) SnackbarHelper.showError(context, describeError(context, error));
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
        // A forum without flarum/tags has no /api/tags.
        (null, FlarumApiException(statusCode: 404)) => EmptyStateView(icon: Icons.sell_outlined, message: l10n.noTagsOnForum),
        (null, final Object error) => EmptyStateView.error(
            message: l10n.tagsLoadFailed,
            hint: describeError(context, error),
            onRetry: () => _load(refresh: true),
          ),
        (null, _) => const Center(child: CircularProgressIndicator()),
        (final List<FlarumTag> tags, _) => RefreshIndicator(
            onRefresh: _refresh,
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

  /// Opens the tag a link names by its slug (`/t/{slug}`), found among the forum's tags. False when
  /// the forum has no such tag, for the caller to open the link some other way.
  static Future<bool> openBySlug(BuildContext context, SiteContext site, String slug) async {
    final FlarumTag? tag;
    try {
      tag = (await FlarumForum.of(site).tags()).where((t) => t.slug.toLowerCase() == slug.toLowerCase()).firstOrNull;
    } catch (_) {
      return false;
    }
    if (tag == null || !context.mounted) return false;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TagPage(site: site, tag: tag!)));
    return true;
  }

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final DiscussionListModel _list = DiscussionListModel(_forum, tagSlug: widget.tag.slug)..addListener(_changed);

  /// The reader's level for the tag (fof/follow-tags): follow, lurk, ignore, hide, or none.
  late String? _level = widget.tag.subscription;

  Future<void> _setLevel(String? level) async {
    final before = _level;
    setState(() => _level = level);
    try {
      await _forum.api.setTagSubscription(widget.tag.id, level);
    } catch (e) {
      if (!mounted) return;
      setState(() => _level = before);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

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
        actions: [
          if (_forum.isSignedIn && _forum.extensions.followTags) _TagFollowMenu(level: _level, onChanged: _setLevel),
        ],
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
      floatingActionButton: startDiscussionButton(context, widget.site, tag: widget.tag, onStarted: _list.refresh),
    );
  }
}

/// How the reader follows a tag (fof/follow-tags), as the web's menu offers it.
class _TagFollowMenu extends StatelessWidget {
  const _TagFollowMenu({required this.level, required this.onChanged});

  final String? level;
  final ValueChanged<String?> onChanged;

  // A menu item's value can't be null (that reads as dismissing the menu).
  static const _none = '';

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    PopupMenuItem<String> item(String value, IconData icon, String title, String hint) => PopupMenuItem(
          value: value,
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(hint),
            trailing: (level ?? _none) == value ? const Icon(Icons.check) : null,
            contentPadding: EdgeInsets.zero,
          ),
        );
    return PopupMenuButton<String>(
      icon: Icon(switch (level) {
        'follow' || 'lurk' => Icons.notifications_active,
        'ignore' || 'hide' => Icons.notifications_off_outlined,
        _ => Icons.notifications_none,
      }),
      tooltip: l10n.notifications,
      onSelected: (value) => onChanged(value == _none ? null : value),
      itemBuilder: (_) => [
        item(_none, Icons.notifications_none, l10n.notFollowing, l10n.notFollowingHint),
        item('follow', Icons.notifications_active, l10n.following, l10n.tagFollowingHint),
        item('lurk', Icons.visibility_outlined, l10n.lurking, l10n.lurkingHint),
        item('ignore', Icons.notifications_off_outlined, l10n.ignoring, l10n.tagIgnoringHint),
        item('hide', Icons.visibility_off_outlined, l10n.hidden, l10n.hiddenHint),
      ],
    );
  }
}
