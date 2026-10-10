import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../l10n/flarum_l10n.dart';
import '../media/image_viewer_page.dart';
import '../navigation/forum_links.dart';
import '../render/flarum_html.dart';
import '../render/links.dart';
import '../profile/user_page.dart';
import '../tags/tag_label.dart';
import 'post_tile.dart';
import 'thread_model.dart';

/// A discussion's posts, opened at its start or at post [near].
///
/// The posts load a page at a time as the reader nears the end; a thread
/// opened part-way down offers the posts before. What the reader scrolls
/// past is reported as read. Links to the forum's discussions open here in
/// the app, a user in their profile; [onOpenUser] and [onOpenTag] let the
/// host decide (a tag otherwise opens the forum's page).
class ThreadPage extends StatefulWidget {
  const ThreadPage({
    super.key,
    required this.site,
    required this.discussionId,
    this.near,
    this.title,
    this.onOpenUser,
    this.onOpenTag,
  });

  final SiteContext site;
  final String discussionId;

  /// The post number to open at; the start when null.
  final int? near;

  /// The title to show until the discussion has loaded.
  final String? title;

  final void Function(BuildContext context, String username)? onOpenUser;
  final void Function(BuildContext context, String slug)? onOpenTag;

  /// Pushes a thread page for [discussionId].
  static Future<void> open(BuildContext context, SiteContext site, String discussionId,
          {int? near, String? title}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ThreadPage(site: site, discussionId: discussionId, near: near, title: title),
      ));

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late final ThreadModel _model = ThreadModel(FlarumForum.of(widget.site), widget.discussionId)..addListener(_changed);
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  /// Bumped when the thread reopens elsewhere, so the list starts afresh.
  int _generation = 0;
  int? _near;

  /// The forum's tags by id, to name the tags in retag events.
  Map<String, FlarumTag>? _tags;

  @override
  void initState() {
    super.initState();
    _near = widget.near;
    _positions.itemPositions.addListener(_scrolled);
    _model.open(near: _near);
    FlarumForum.of(widget.site).tags().then(
      (tags) {
        if (mounted) setState(() => _tags = {for (final tag in tags) tag.id: tag});
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_scrolled);
    _model
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  /// The discussion's tags head the thread while it starts at its first post.
  bool get _header => !_model.hasPrevious && (_model.discussion?.tags.isNotEmpty ?? false);

  /// Rows before the first post: "Load earlier posts", or the tags header.
  int get _leading => _model.hasPrevious || _header ? 1 : 0;
  int get _rowCount => _leading + _model.posts.length + 1;

  void _scrolled() {
    final visible = _positions.itemPositions.value.where((p) => p.itemLeadingEdge < 1 && p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    var lastPost = -1;
    var lastRow = 0;
    for (final position in visible) {
      if (position.index > lastRow) lastRow = position.index;
      final post = position.index - _leading;
      if (post >= 0 && post < _model.posts.length && post > lastPost) lastPost = post;
    }
    if (lastPost >= 0) _model.reportRead(_model.posts[lastPost].number);
    if (lastRow >= _rowCount - 3 && _model.pageError == null) _model.loadNext();
  }

  Future<void> _loadEarlier() async {
    final added = await _model.loadPrevious();
    if (added > 0 && _scroll.isAttached) _scroll.jumpTo(index: _leading + added);
  }

  /// Opens a link from a post: this forum's discussions here, users and tags
  /// through the host, everything else outside the app.
  void _openLink(String url) {
    final link = ForumLink.parse(url, widget.site.site.url);
    switch (link) {
      case DiscussionLink(:final id, :final number) when id == widget.discussionId:
        _goTo(number ?? 1);
      case DiscussionLink(:final id, :final number):
        ThreadPage.open(context, widget.site, id, near: number);
      case UserLink(:final username):
        _openUser(username);
      case TagLink(:final slug) when widget.onOpenTag != null:
        widget.onOpenTag!(context, slug);
      default:
        openExternally(url);
    }
  }

  void _openUser(String username) {
    if (widget.onOpenUser != null) {
      widget.onOpenUser!(context, username);
    } else {
      UserPage.open(context, widget.site, username);
    }
  }

  /// A reply to a post: in this thread, scroll to it; elsewhere, open its discussion there.
  void _openReply(FlarumPostReply reply) {
    final discussion = reply.discussionId;
    if (discussion == null) return;
    if (discussion == widget.discussionId) {
      _goTo(reply.number ?? 1);
    } else {
      ThreadPage.open(context, widget.site, discussion, near: reply.number, title: reply.discussionTitle);
    }
  }

  /// Scrolls to post [number], reopening the thread there if it isn't loaded.
  void _goTo(int number) {
    final index = _model.indexOfNumber(number);
    if (index >= 0 && _scroll.isAttached) {
      _scroll.scrollTo(index: _leading + index, duration: const Duration(milliseconds: 300));
      return;
    }
    setState(() {
      _near = number;
      _generation++;
    });
    _model.open(near: number);
  }

  PostContentCallbacks _callbacksFor(FlarumPost post) => PostContentCallbacks(
        onUrlTap: _openLink,
        onMentionTap: _openUser,
        onImageTap: (url, context, _) => ImageViewerPage.open(
          context,
          url,
          FlarumHtml.parse(post.contentHtml ?? '', forumBaseUrl: widget.site.site.url).imageUrls,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final discussion = _model.discussion;
    return Scaffold(
      appBar: AppBar(
        title: Text(discussion?.title ?? widget.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: switch (_model) {
        ThreadModel(discussion: null, error: final error?) => EmptyStateView.error(
            message: l10n.threadLoadFailed,
            hint: describeFlarumError(error),
            onRetry: () => _model.open(near: _near),
          ),
        ThreadModel(discussion: null) => const Center(child: CircularProgressIndicator()),
        _ => ScrollablePositionedList.separated(
            key: ValueKey(_generation),
            itemScrollController: _scroll,
            itemPositionsListener: _positions,
            itemCount: _rowCount,
            initialScrollIndex: _initialRow(),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, row) => _row(context, row, l10n),
          ),
      },
    );
  }

  int _initialRow() {
    final near = _near;
    if (near == null) return 0;
    final index = _model.indexOfNumber(near);
    return index < 0 ? 0 : _leading + index;
  }

  Widget _row(BuildContext context, int row, FlarumLocalizations l10n) {
    if (_header && row == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingL, DesignTokens.spacingS),
        child: Wrap(
          spacing: DesignTokens.spacingS,
          runSpacing: DesignTokens.spacingXS,
          children: [for (final tag in tagsInWebOrder(_model.discussion!.tags)) TagLabel(tag: tag)],
        ),
      );
    }
    if (_model.hasPrevious && row == 0) {
      return Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingS),
        child: Center(
          child: _model.loadingPrevious
              ? const _Spinner()
              : TextButton.icon(
                  onPressed: _loadEarlier,
                  icon: const Icon(Icons.expand_less),
                  label: Text(l10n.loadEarlierPosts),
                ),
        ),
      );
    }
    final index = row - _leading;
    if (index < _model.posts.length) {
      final post = _model.posts[index];
      return PostTile(
        key: ValueKey(post.id),
        site: widget.site,
        post: post,
        callbacks: _callbacksFor(post),
        onAuthorTap: (author) => _openUser(author.username),
        onOpenReply: _openReply,
        tags: _tags,
      );
    }
    // The end: more to come, a page that failed, or the thread's end.
    if (_model.hasNext) {
      return Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Center(
          child: _model.pageError != null
              ? TextButton.icon(onPressed: _model.loadNext, icon: const Icon(Icons.refresh), label: Text(l10n.retry))
              : const _Spinner(),
        ),
      );
    }
    return const SizedBox(height: DesignTokens.spacingXXXL);
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
}
