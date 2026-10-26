import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/filter_chip_bar.dart';
import 'package:forum_kit/views/widgets/section_header.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/start_discussion_button.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import '../thread/thread_page.dart';
import 'tag_label.dart';
import 'tag_masthead.dart';

/// The forum's tags on a page of their own, as the drawer's All Tags opens them ([TagsView]).
class TagsPage extends StatelessWidget {
  const TagsPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TagsPage(site: site)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(flarumL10n(context).tags)),
        body: TagsView(site: site),
      );
}

/// The forum's tags, as the Discourse app lists a forum's categories: a card per primary tag in the
/// admin's order, with its colour down the side, its description, its latest discussion (as the
/// web's Tags page shows it) and its child tags as chips; then the secondary tags. A tag opens its
/// discussions. On Home's Tags chip, under Home's header ([headerSlivers]); on [TagsPage], alone.
class TagsView extends StatefulWidget {
  const TagsView({super.key, required this.site, this.headerSlivers = const [], this.refreshEdgeOffset = 0});

  final SiteContext site;

  /// Above the tags, scrolling with them: Home's masthead and chips.
  final List<Widget> headerSlivers;

  /// Where the refresh spinner shows: under the header's pinned bar.
  final double refreshEdgeOffset;

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  List<FlarumTag>? _tags;
  Object? _error;

  /// Each tag's latest discussion, read after the tags (the tags show without them).
  Map<String, FlarumDiscussion> _latest = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await _forum.api.tagsLatestDiscussions();
      if (mounted) setState(() => _latest = latest);
    } catch (_) {
      // The tags show without them.
    }
  }

  Future<void> _load({bool refresh = false}) async {
    try {
      final tags = await _forum.tags(refresh: refresh);
      if (mounted) {
        setState(() {
          _tags = tags;
          _error = null;
        });
        _loadLatest();
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

  void _open(FlarumTag tag) => TagPage.open(context, widget.site, tag);

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final tags = _tags;
    final List<Widget> body = switch ((tags, _error)) {
      // A forum without flarum/tags has no /api/tags.
      (null, FlarumApiException(statusCode: 404)) => [
          SliverFillRemaining(
              hasScrollBody: false, child: EmptyStateView(icon: Icons.sell_outlined, message: l10n.noTagsOnForum)),
        ],
      (null, final Object error) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView.error(
              message: l10n.tagsLoadFailed,
              hint: describeError(context, error),
              onRetry: () => _load(refresh: true),
            ),
          ),
        ],
      (null, _) => const [SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))],
      (final List<FlarumTag> tags, _) => _list(context, tags),
    };
    return RefreshIndicator(
      edgeOffset: widget.refreshEdgeOffset,
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [...widget.headerSlivers, ...body],
      ),
    );
  }

  List<Widget> _list(BuildContext context, List<FlarumTag> tags) {
    final l10n = flarumL10n(context);
    int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
    final primary = tags.where((t) => t.isPrimary && !t.isChild).toList()..sort(byPosition);
    final secondary = tags.where((t) => !t.isPrimary).toList()
      ..sort((a, b) => b.discussionCount.compareTo(a.discussionCount));
    return [
      SliverPadding(
        padding: const EdgeInsets.only(top: DesignTokens.spacingS),
        sliver: SliverList.list(children: [
          for (final tag in primary)
            TagCard(
              tag: tag,
              children: tags.where((t) => t.parentId == tag.id).toList()..sort(byPosition),
              latest: _latest[tag.id],
              onOpen: _open,
              onOpenLatest: (latest) =>
                  ThreadPage.open(context, widget.site, latest.id, near: latest.lastPostNumber, title: latest.title),
            ),
        ]),
      ),
      if (secondary.isNotEmpty) ...[
        SliverToBoxAdapter(child: SectionHeader(primary.isEmpty ? l10n.tags : l10n.otherTags)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
            child: Wrap(
              spacing: DesignTokens.spacingS,
              children: [for (final tag in secondary) TagLabel(tag: tag, onTap: () => _open(tag))],
            ),
          ),
        ),
      ],
      // Room for a Start a Discussion button over the last card.
      const SliverToBoxAdapter(child: SizedBox(height: 88)),
    ];
  }
}

/// A primary tag as the Discourse app's category card: its tile mark and name, how many
/// discussions it has, two lines of description, its latest discussion, and its child tags as
/// chips. A band of its colour runs down the left edge.
class TagCard extends StatelessWidget {
  const TagCard({
    super.key,
    required this.tag,
    required this.onOpen,
    this.children = const [],
    this.latest,
    this.onOpenLatest,
  });

  final FlarumTag tag;
  final List<FlarumTag> children;

  /// Its latest discussion, which opens at its last post.
  final FlarumDiscussion? latest;
  final ValueChanged<FlarumTag> onOpen;
  final ValueChanged<FlarumDiscussion>? onOpenLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = flarumL10n(context);
    final color = tagMarkColor(flarumTagColor(tag) ?? colorScheme.outline, colorScheme.surface);
    final muted = colorScheme.onSurfaceVariant;
    final description = tag.description;
    final latest = this.latest;
    final when = latest?.lastPostedAt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onOpen(tag),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    TagTileMark(tag: tag, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tag.name, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    if (tag.subscription == 'follow') ...[
                      const SizedBox(width: 8),
                      Icon(Icons.star, size: 16, color: muted, semanticLabel: l10n.following),
                    ],
                    const SizedBox(width: 8),
                    Text(l10n.tagDiscussionCount(tag.discussionCount), style: text.bodySmall?.copyWith(color: muted)),
                  ]),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(description,
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodyMedium?.copyWith(color: muted)),
                  ],
                  if (latest != null)
                    InkWell(
                      onTap: onOpenLatest == null ? null : () => onOpenLatest!(latest),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Row(children: [
                          Icon(Icons.forum_outlined, size: 14, color: muted),
                          const SizedBox(width: DesignTokens.spacingXS),
                          Flexible(
                            child: Text(latest.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          if (when != null)
                            Text(' · ${formatTimeAgo(when.toLocal(), context)}', style: text.bodySmall?.copyWith(color: muted)),
                        ]),
                      ),
                    ),
                  if (children.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [for (final child in children) ChildTagChip(tag: child, parent: tag, onTap: () => onOpen(child))],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A child tag as a small chip, its mark and name, that opens it: 32dp tall to tap, so a tap meant
/// for it doesn't open the card it sits on.
class ChildTagChip extends StatelessWidget {
  const ChildTagChip({super.key, required this.tag, required this.onTap, this.parent, this.outlined = false});

  final FlarumTag tag;
  final FlarumTag? parent;
  final VoidCallback onTap;

  /// Drawn with an outline on the page rather than filled on a card.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(8);
    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: outlined ? null : colorScheme.surfaceContainerHigh,
            border: outlined ? Border.all(color: colorScheme.outlineVariant) : null,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TagMark(tag: tag, parent: parent, size: 10),
              const SizedBox(width: 6),
              Flexible(
                child: Text(tag.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tag's discussions, under its header ([TagMasthead]): its child tags as chips, the web's
/// sorts as chips, then the list.
class TagPage extends StatefulWidget {
  const TagPage({super.key, required this.site, required this.tag});

  final SiteContext site;
  final FlarumTag tag;

  static Future<void> open(BuildContext context, SiteContext site, FlarumTag tag) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TagPage(site: site, tag: tag)));

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
    open(context, site, tag);
    return true;
  }

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final Map<DiscussionSort, DiscussionListModel> _lists = {};
  DiscussionSort _sort = DiscussionSort.latest;

  /// The forum's tags, for this one's parent and children.
  List<FlarumTag> _tags = const [];

  /// The reader's level for the tag (fof/follow-tags): follow, lurk, ignore, hide, or none.
  late String? _level = widget.tag.subscription;

  /// Folded to its icon while the reader scrolls on through the list.
  bool _fabExtended = true;

  DiscussionListModel get _list => _lists.putIfAbsent(_sort, () {
        final model = DiscussionListModel(_forum, tagSlug: widget.tag.slug, sort: _sort)..addListener(_changed);
        model.refresh();
        return model;
      });

  @override
  void initState() {
    super.initState();
    _forum.tags().then((tags) {
      if (mounted) setState(() => _tags = tags);
    }, onError: (_) {
      // Without them, the page has no breadcrumb or child tags.
    });
  }

  @override
  void dispose() {
    for (final model in _lists.values) {
      model
        ..removeListener(_changed)
        ..dispose();
    }
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

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
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    // The forum's copy knows the tag's parent, which a discussion's copy may not.
    final tag = _tags.where((t) => t.id == widget.tag.id).firstOrNull ?? widget.tag;
    int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
    final children = _tags.where((t) => t.parentId == tag.id).toList()..sort(byPosition);
    final parent = parentAmong(tag, _tags);
    final sorts = DiscussionSort.offeredOn(_forum.info?.version);
    if (!sorts.contains(_sort)) _sort = DiscussionSort.latest;
    final list = _list;
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.depth != 0) return false;
          final extended = switch (n.direction) {
            ScrollDirection.reverse => false,
            ScrollDirection.forward => true,
            ScrollDirection.idle => _fabExtended,
          };
          if (extended != _fabExtended) setState(() => _fabExtended = extended);
          return false;
        },
        child: DiscussionListView(
          site: widget.site,
          list: list,
          excerpts: true,
          hiddenTagId: tag.id,
          refreshEdgeOffset: TagMasthead.collapsedHeight(context),
          headerSlivers: [
            TagMasthead(
              tag: tag,
              forumName: _forum.info?.title ?? widget.site.site.name,
              forumIconUrl: _forum.info?.faviconUrl,
              parent: parent,
              onOpenParent: parent == null ? null : () => TagPage.open(context, widget.site, parent),
              followLevel: _level,
              onFollowChanged: _forum.isSignedIn && _forum.extensions.followTags ? _setLevel : null,
            ),
            // Child tags as chips under the header, as the Discourse app shows a category's
            // subcategories: the page used to leave them out.
            if (children.isNotEmpty)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    for (final child in children)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChildTagChip(
                          tag: child,
                          parent: tag,
                          outlined: true,
                          onTap: () => TagPage.open(context, widget.site, child),
                        ),
                      ),
                  ]),
                ),
              ),
            if (sorts.length > 1)
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: FilterChipBar(
                    options: [for (final sort in sorts) FilterChipOption(label: discussionSortLabel(sort, l10n))],
                    selectedIndex: sorts.indexOf(_sort),
                    onSelected: (i) => setState(() => _sort = sorts[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton:
          startDiscussionButton(context, widget.site, tag: tag, onStarted: list.refresh, extended: _fabExtended),
    );
  }
}
