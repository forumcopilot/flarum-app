import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/composers.dart';
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

  final void Function(BuildContext context, String slug)? onOpenUser;
  final void Function(BuildContext context, String slug)? onOpenTag;

  /// Pushes a thread page for [discussionId].
  static Future<void> open(BuildContext context, SiteContext site, String discussionId, {int? near, String? title}) =>
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
      case UserLink(:final slug):
        _openUser(slug);
      case TagLink(:final slug) when widget.onOpenTag != null:
        widget.onOpenTag!(context, slug);
      default:
        openExternally(url);
    }
  }

  /// Opens the profile of the user whose slug is [slug] (see [UserPage]).
  void _openUser(String slug) {
    if (widget.onOpenUser != null) {
      widget.onOpenUser!(context, slug);
    } else {
      UserPage.open(context, widget.site, slug);
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

  /// fof/best-answer chose a reply, so the question offers a way to it.
  bool get _bestAnswerElsewhere {
    final answer = _model.discussion?.bestAnswerPostId;
    return answer != null && !_model.posts.any((post) => post.number == 1 && post.id == answer);
  }

  /// Goes to the best answer: scrolls there if it's loaded, else finds its number and opens the thread there.
  Future<void> _goToBestAnswer() async {
    final id = _model.discussion?.bestAnswerPostId;
    if (id == null) return;
    final loaded = _model.posts.where((post) => post.id == id).firstOrNull;
    if (loaded != null) return _goTo(loaded.number);
    try {
      final answer = await FlarumForum.of(widget.site).api.post(id);
      if (mounted) _goTo(answer.number);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeFlarumError(e))));
    }
  }

  /// Whether the reader may reply here: signed in, and the discussion lets them.
  bool get _canReply => FlarumForum.of(widget.site).isSignedIn && (_model.discussion?.canReply ?? false);

  /// Opens the composer for a reply, starting from [initial] (a quote, a reply to a post).
  Future<void> _reply({String? initial}) async {
    final discussion = _model.discussion;
    if (discussion == null) return;
    final post = await composeReply(context, widget.site, discussion, initialContent: initial);
    if (post == null || !mounted) return;
    if (!post.isApproved) {
      SnackbarHelper.showInfo(context, flarumL10n(context).postAwaitingApproval);
      return;
    }
    _reload(at: post.number);
  }

  Future<void> _edit(FlarumPost post) async {
    final saved = await composeEdit(context, widget.site, post);
    if (saved != null && mounted) _reload(at: post.number);
  }

  FlarumForum get _forum => FlarumForum.of(widget.site);
  bool get _signedIn => _forum.isSignedIn;
  String? get _readerId => _forum.info?.actor?.id;

  /// Shows [change] to [before] at once, then [send]s it; [reconcile] takes in the forum's answer.
  /// Refused, the post goes back as it was, with the reason.
  Future<void> _changePost(FlarumPost before, FlarumPost Function(FlarumPost) change, Future<FlarumPost> Function() send,
      FlarumPost Function(FlarumPost shown, FlarumPost saved) reconcile) async {
    _model.replacePost(change(before));
    try {
      final saved = await send();
      final shown = _model.postById(before.id);
      if (shown != null) _model.replacePost(reconcile(shown, saved));
    } catch (e) {
      _model.replacePost(before);
      if (mounted) SnackbarHelper.showError(context, describeFlarumError(e));
    }
  }

  void _like(FlarumPost post) {
    final reader = _forum.info?.actor;
    final liked = post.isLikedBy(_readerId);
    _changePost(
      post,
      (p) => p.copyWith(
        likesCount: p.likesCount + (liked ? -1 : 1),
        likedBy: liked ? [for (final u in p.likedBy) if (u.id != _readerId) u] : [if (reader != null) reader, ...p.likedBy],
      ),
      () => _forum.api.likePost(post.id, liked: !liked),
      (shown, saved) => shown.copyWith(likesCount: saved.likesCount, likedBy: saved.likedBy),
    );
  }

  /// A reader has one reaction a post: another replaces it, the same one takes it back.
  void _react(FlarumPost post, FlarumReaction reaction) {
    final mine = post.userReactionId;
    final takingBack = mine == reaction.id;
    final counts = {...post.reactionCounts};
    void add(String id, int by) {
      final n = (counts[id] ?? 0) + by;
      n > 0 ? counts[id] = n : counts.remove(id);
    }

    if (mine != null) add(mine, -1);
    if (!takingBack) add(reaction.id, 1);
    _changePost(
      post,
      (p) => p.copyWith(reactionCounts: counts, userReactionId: () => takingBack ? null : reaction.id),
      () => takingBack ? _forum.api.unreactToPost(post.id, reaction.id) : _forum.api.reactToPost(post.id, reaction.id),
      (shown, saved) => shown.copyWith(reactionCounts: saved.reactionCounts, userReactionId: () => saved.userReactionId),
    );
  }

  void _bookmarkPost(FlarumPost post) => _changePost(
        post,
        (p) => p.copyWith(bookmarked: !post.bookmarked),
        () => _forum.api.bookmarkPost(post.id, bookmarked: !post.bookmarked),
        (shown, saved) => shown.copyWith(bookmarked: saved.bookmarked),
      );

  /// Shows [change] to the discussion at once, then [send]s it; refused, it goes back as it was.
  Future<void> _changeDiscussion(
      FlarumDiscussion Function(FlarumDiscussion) change, Future<FlarumDiscussion> Function() send) async {
    final before = _model.discussion;
    if (before == null) return;
    _model.updateDiscussion(change);
    try {
      await send();
    } catch (e) {
      _model.updateDiscussion((_) => before);
      if (mounted) SnackbarHelper.showError(context, describeFlarumError(e));
    }
  }

  void _chooseBestAnswer(FlarumPost post) {
    final chosen = _model.discussion?.bestAnswerPostId == post.id;
    _changeDiscussion(
      (d) => d.copyWith(bestAnswerPostId: () => chosen ? null : post.id),
      () => _forum.api.setBestAnswer(widget.discussionId, chosen ? null : post.id),
    );
  }

  void _setSubscription(String? level) => _changeDiscussion(
        (d) => d.copyWith(subscription: () => level),
        () => _forum.api.setSubscription(widget.discussionId, level),
      );

  void _bookmarkDiscussion() {
    final bookmarked = !(_model.discussion?.bookmarked ?? false);
    _changeDiscussion(
      (d) => d.copyWith(bookmarked: bookmarked),
      () => _forum.api.bookmarkDiscussion(widget.discussionId, bookmarked: bookmarked),
    );
  }

  /// Opens the thread again at post [number], loaded afresh: a new reply, an edited post.
  void _reload({required int at}) {
    setState(() {
      _near = at;
      _generation++;
    });
    _model.open(near: at);
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
        actions: [
          if (_signedIn && discussion != null && _forum.extensions.bookmarks)
            IconButton(
              icon: Icon(discussion.bookmarked ? Icons.bookmark : Icons.bookmark_border),
              tooltip: discussion.bookmarked ? l10n.removeBookmark : l10n.bookmark,
              onPressed: _bookmarkDiscussion,
            ),
          if (_signedIn && discussion != null) _FollowMenu(level: discussion.subscription, onChanged: _setSubscription),
        ],
      ),
      floatingActionButton: _canReply
          ? FloatingActionButton.extended(
              onPressed: _reply,
              icon: const Icon(Icons.reply),
              label: Text(kitL10n(context).reply),
            )
          : null,
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
        onAuthorTap: (author) => _openUser(author.slug ?? author.username),
        onOpenReply: _openReply,
        tags: _tags,
        isBestAnswer: post.id == _model.discussion!.bestAnswerPostId,
        onGoToBestAnswer: post.number == 1 && _bestAnswerElsewhere ? _goToBestAnswer : null,
        onReply: _canReply ? () => _reply(initial: replyTo(post, l10n)) : null,
        onQuote: _canReply ? () => _reply(initial: quoteOf(post, l10n)) : null,
        onEdit: post.canEdit ? () => _edit(post) : null,
        readerId: _readerId,
        reactions: _forum.info?.reactions ?? const [],
        onLike: post.canLike ? () => _like(post) : null,
        onReact: post.canReact ? (reaction) => _react(post, reaction) : null,
        onBookmark: _signedIn && _forum.extensions.bookmarks ? () => _bookmarkPost(post) : null,
        onChooseBestAnswer: post.canSelectAsBestAnswer && post.number > 1 ? () => _chooseBestAnswer(post) : null,
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
    // Room under the last post for the Reply button.
    return SizedBox(height: _canReply ? 96 : DesignTokens.spacingXXXL);
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
}

/// How the reader follows the discussion (flarum/subscriptions), as the web's menu offers it.
class _FollowMenu extends StatelessWidget {
  const _FollowMenu({required this.level, required this.onChanged});

  /// `follow`, `ignore`, or null for neither.
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
        'follow' => Icons.notifications_active,
        'ignore' => Icons.notifications_off_outlined,
        _ => Icons.notifications_none,
      }),
      tooltip: l10n.notificationSettings,
      onSelected: (value) => onChanged(value == _none ? null : value),
      itemBuilder: (_) => [
        item(_none, Icons.notifications_none, l10n.notFollowing, l10n.notFollowingHint),
        item('follow', Icons.notifications_active, l10n.following, l10n.followingHint),
        item('ignore', Icons.notifications_off_outlined, l10n.ignoring, l10n.ignoringHint),
      ],
    );
  }
}
