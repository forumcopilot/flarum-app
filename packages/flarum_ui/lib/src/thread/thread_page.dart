import 'dart:math' as math;

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
import '../account/log_in_first.dart';
import '../compose/composers.dart';
import '../compose/tag_picker_page.dart';
import '../media/image_viewer_page.dart';
import '../navigation/forum_links.dart';
import '../render/flarum_html.dart';
import '../render/links.dart';
import '../profile/user_page.dart';
import '../safety/flag_post_page.dart';
import '../safety/ignore_actions.dart';
import '../safety/ignored_users.dart';
import '../tags/tag_label.dart';
import '../tags/tags_page.dart';
import 'post_tile.dart';
import 'thread_model.dart';
import 'time_gap.dart';
import '../navigation/web_links.dart';
import '../home/discussion_tile.dart' show discussionBadges;

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
  late final ThreadModel _model =
      ThreadModel(FlarumForum.of(widget.site), widget.discussionId, forumBaseUrl: widget.site.site.url)
        ..addListener(_changed);
  late final IgnoredUsers _ignored = IgnoredUsers.of(widget.site)..addListener(_changed);
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
    _ignored.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    if ((_model.discussion?.isPrivate ?? false) && !_readingRecipients) _readRecipients();
    setState(() {});
  }

  /// The head row, while the thread starts at its first post: the web's discussion hero, in its
  /// first tag's colour, with its badges, tags and title, and who a private one is with.
  bool get _header => !_model.hasPrevious && _model.discussion != null;

  /// Whether the hero is on screen: the bar shows the title only once it has scrolled away, as the
  /// web's header does.
  bool _heroOnScreen = true;

  /// Who a private discussion is with (fof/byobu), read once it's known to be one.
  List<FlarumUser>? _recipients;
  bool _readingRecipients = false;

  Future<void> _readRecipients() async {
    _readingRecipients = true;
    try {
      final recipients = await _forum.api.recipients(widget.discussionId);
      if (mounted) setState(() => _recipients = recipients);
    } catch (_) {
      // The thread reads as well without its people listed.
    }
  }

  /// Rows before the first post: "Load earlier posts", or the tags header.
  int get _leading => _model.hasPrevious || _header ? 1 : 0;
  int get _rowCount => _leading + _model.posts.length + 1;

  void _scrolled() {
    final visible = _positions.itemPositions.value.where((p) => p.itemLeadingEdge < 1 && p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    final hero = _header && visible.any((p) => p.index == 0 && p.itemTrailingEdge > 0.02);
    if (hero != _heroOnScreen) setState(() => _heroOnScreen = hero);
    // The first post on screen, counted from the discussion's start, for the bar's "12 of 340";
    // the last, once the discussion's end is all on screen (the web's scrubber reads "60 of 60"
    // there, where the top post can be 57).
    final shown = visible.map((p) => p.index - _leading).where((i) => i >= 0 && i < _model.posts.length);
    if (shown.isNotEmpty) {
      final atEnd = !_model.hasNext &&
          visible.any((p) => p.index - _leading == _model.posts.length - 1 && p.itemTrailingEdge <= 1.0);
      final position = atEnd ? _model.start + _model.posts.length : _model.start + shown.reduce(math.min) + 1;
      if (position != _position) setState(() => _position = position);
    }
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
  /// through the host, another forum's where the host opens it, everything else outside the app.
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
      case TagLink(:final slug):
        _openTag(slug, url);
      default:
        openPostLink(context, url);
    }
  }

  /// A tag in the app, as a profile opens in it; a tag the forum doesn't list, on the web.
  Future<void> _openTag(String slug, String url) async {
    if (!await TagPage.openBySlug(context, widget.site, slug) && mounted) openExternally(url);
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

  /// The best answer, read once for its preview under the question.
  FlarumPost? _bestAnswer;
  String? _readingBestAnswer;

  FlarumPost? _bestAnswerPreview() {
    final id = _model.discussion?.bestAnswerPostId;
    if (id == null) return null;
    if (_bestAnswer?.id == id) return _bestAnswer;
    final loaded = _model.posts.where((post) => post.id == id).firstOrNull;
    if (loaded != null) return loaded;
    if (_readingBestAnswer != id) {
      _readingBestAnswer = id;
      _forum.api.post(id).then((answer) {
        if (mounted) setState(() => _bestAnswer = answer);
      }, onError: (Object _) {});
    }
    return null;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(context, e))));
    }
  }

  /// Puts [poll], as the reader's vote left it, in its post.
  void _pollChanged(String postId, FlarumPoll poll) {
    final post = _model.postById(postId);
    if (post == null) return;
    _model.replacePost(post.copyWith(polls: [for (final p in post.polls) p.id == poll.id ? poll : p]));
  }

  /// Whether the reader may reply here: signed in, and the discussion lets them.
  bool get _canReply => FlarumForum.of(widget.site).isSignedIn && (_model.discussion?.canReply ?? false);

  /// A guest, where a member could reply: Reply asks them to Log In first, as the web's "Log In to
  /// Reply" does.
  bool get _guestCouldReply => !_forum.isSignedIn && _model.discussion != null && !_model.discussion!.isLocked;

  /// Logs a guest in, reads the discussion again as them (what they may do now), then opens the
  /// reply they asked for, starting from [initial].
  Future<void> _logInToReply({String? initial, int? at}) async {
    if (!await logInFirst(context, widget.site) || !mounted) return;
    await _reload(at: at ?? _firstShownPost());
    if (mounted && _canReply) _reply(initial: initial);
  }

  /// The number of the first post on screen, to open the thread at again.
  int _firstShownPost() {
    final rows = _positions.itemPositions.value.where((p) => p.itemTrailingEdge > 0).map((p) => p.index - _leading);
    final first = rows.where((i) => i >= 0 && i < _model.posts.length).fold<int?>(null, (a, b) => a == null || b < a ? b : a);
    return first == null ? (_near ?? 1) : _model.posts[first].number;
  }

  /// The people in the discussion as far as it's loaded, its latest posters first, the reader left
  /// out: who `@` offers in a reply.
  List<FlarumUser> _people() {
    final seen = <String>{if (_readerId case final reader?) reader};
    return [
      for (final post in _model.posts.reversed)
        if (post.author case final author? when seen.add(author.id)) author,
    ];
  }

  /// Opens the composer for a reply, starting from [initial] (a quote, a reply to a post).
  Future<void> _reply({String? initial}) async {
    final discussion = _model.discussion;
    if (discussion == null) return;
    final post = await composeReply(context, widget.site, discussion, initialContent: initial, mentionable: _people());
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
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
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

  // ---- Moderation. ----

  /// Deletes [post] the way Flarum's Delete does, hiding it, or restores it.
  void _hidePost(FlarumPost post) => _changePost(
        post,
        (p) => p.copyWith(isHidden: !p.isHidden),
        () => _forum.api.setPostHidden(post.id, !post.isHidden),
        (shown, saved) => shown.copyWith(isHidden: saved.isHidden),
      );

  void _approvePost(FlarumPost post) => _changePost(
        post,
        (p) => p.copyWith(isApproved: true),
        () => _forum.api.approvePost(post.id),
        (shown, saved) => shown.copyWith(isApproved: saved.isApproved),
      );

  Future<void> _deletePostForever(FlarumPost post) async {
    if (!await _sure(flarumL10n(context).deleteForeverConfirm)) return;
    try {
      await _forum.api.deletePost(post.id);
      if (mounted) _reload(at: post.number);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  Future<bool> _sure(String question) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(question),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(kitL10n(context).cancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(flarumL10n(context).deleteForever)),
          ],
        ),
      ) ??
      false;

  /// A moderator's change to the discussion, after which the thread is read again (a rename, a lock
  /// or a pin leaves an event post at its end); Delete forever closes it.
  Future<void> _moderate(_DiscussionAction action) async {
    final discussion = _model.discussion;
    if (discussion == null) return;
    final api = _forum.api;
    final id = discussion.id;
    try {
      switch (action) {
        case _DiscussionAction.rename:
          final title = await _askTitle(discussion.title);
          if (title == null || title == discussion.title) return;
          await api.renameDiscussion(id, title);
        case _DiscussionAction.editTags:
          // The tag picker the composer has, on the discussion's tags and the forum's rules.
          final tags = await _forum.tags();
          if (!mounted) return;
          final chosen = await TagPickerPage.open(context, tags: tags, rules: _forum.info?.tagRules, selected: discussion.tags);
          if (chosen == null) return;
          final ids = [for (final tag in chosen) tag.id];
          if ({...ids}.length == discussion.tags.length && discussion.tags.every((t) => ids.contains(t.id))) return;
          await api.setDiscussionTags(id, ids);
        case _DiscussionAction.lock || _DiscussionAction.unlock:
          await api.setLocked(id, action == _DiscussionAction.lock);
        case _DiscussionAction.stick || _DiscussionAction.unstick:
          await api.setSticky(id, action == _DiscussionAction.stick);
        case _DiscussionAction.hide || _DiscussionAction.restore:
          await api.setDiscussionHidden(id, action == _DiscussionAction.hide);
        case _DiscussionAction.deleteForever:
          if (!await _sure(flarumL10n(context).deleteForeverConfirm)) return;
          await api.deleteDiscussion(id);
          if (mounted) Navigator.of(context).pop();
          return;
      }
      // Where it was opened: the forum's answer doesn't say where an event post went.
      if (mounted) _reload(at: _near ?? 1);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  bool _canEditTags(FlarumDiscussion d) => d.canTag && _forum.extensions.tags && !d.isPrivate;

  Future<String?> _askTitle(String title) =>
      showDialog<String>(context: context, builder: (_) => _RenameDialog(title: title));

  Future<void> _flag(FlarumPost post) async {
    if (await FlagPostPage.open(context, widget.site, post) && mounted) {
      SnackbarHelper.showInfo(context, flarumL10n(context).flagSent);
    }
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
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
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

  /// Opens the thread again at post [number], loaded afresh: a new reply, an edited post, a post
  /// outside the window. The list starts again (a new key) only once the new window is in, so it
  /// opens at the post: started before, it took its first row from the old window, where the post
  /// isn't, and stayed at the top of the new one, about half a page above it.
  Future<void> _reload({required int at, bool flash = true}) async {
    _near = at;
    await _model.open(near: at);
    if (!mounted) return;
    if (_model.error case final error? when _model.discussion != null) {
      // The old window stays; say why the new one didn't come.
      SnackbarHelper.showError(context, describeError(context, error));
      return;
    }
    setState(() {
      _generation++;
      if (flash) _flash(at);
    });
  }

  /// Scrolls to post [number], reopening the thread there if it isn't loaded.
  void _goTo(int number) {
    final index = _model.indexOfNumber(number);
    // Loaded, or missing from the window's middle (deleted): the next one stands in. A post before
    // the window is not loaded, though the window's first post is the first with a number above it.
    final loaded = index > 0 || (index == 0 && (_model.posts.first.number == number || !_model.hasPrevious));
    if (loaded && _scroll.isAttached) {
      // The first post, with the discussion's header above it.
      _scroll.scrollTo(index: _rowOf(index), duration: const Duration(milliseconds: 300));
      setState(() => _flash(number));
      return;
    }
    _reload(at: number);
  }

  @visibleForTesting
  void goTo(int number) => _goTo(number);

  /// The first post on screen, from 1, once the list has drawn.
  int? _position;

  /// Takes the reader to the post at [index] (0 for the first), as the scrubber moves: scrolled to
  /// where it's loaded, else the thread opened around it.
  Future<void> _goToIndex(int index) async {
    final total = _model.total;
    if (total == 0) return;
    index = index.clamp(0, total - 1);
    if (index >= _model.start && index < _model.end && _scroll.isAttached) {
      _scroll.scrollTo(index: _rowOf(index - _model.start), duration: const Duration(milliseconds: 300));
      setState(() => _flash(_model.posts[index - _model.start].number));
      return;
    }
    await _model.openAtIndex(index);
    if (!mounted) return;
    if (_model.error case final error? when _model.discussion != null) {
      SnackbarHelper.showError(context, describeError(context, error));
      return;
    }
    final at = index - _model.start;
    if (at < 0 || at >= _model.posts.length) return;
    final number = _model.posts[at].number;
    setState(() {
      _near = number;
      _generation++;
      _flash(number);
    });
  }

  /// The web's post scrubber: Original Post, a slider over the whole discussion, and Now.
  Future<void> _scrub() async {
    final total = _model.total;
    final l10n = flarumL10n(context);
    var value = ((_position ?? _model.start + 1).clamp(1, total)).toDouble();
    final target = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: StatefulBuilder(
          builder: (sheet, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(sheet, 0),
                  icon: const Icon(Icons.vertical_align_top),
                  label: Text(l10n.scrubberOriginalPost),
                ),
                Text(l10n.scrubberPosition(value.round(), total),
                    textAlign: TextAlign.center, style: Theme.of(sheet).textTheme.titleMedium),
                if (total > 1)
                  Slider(
                    value: value,
                    min: 1,
                    max: total.toDouble(),
                    divisions: total - 1,
                    label: l10n.scrubberPosition(value.round(), total),
                    onChanged: (v) => setSheet(() => value = v),
                    onChangeEnd: (v) => Navigator.pop(sheet, v.round() - 1),
                  ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(sheet, total - 1),
                  icon: const Icon(Icons.vertical_align_bottom),
                  label: Text(l10n.scrubberNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (target != null && mounted) _goToIndex(target);
  }

  /// The post the reader was just taken to, lit up for a moment as the web does (`flashItem`).
  int? _flashNumber;
  int _flashes = 0;

  void _flash(int number) {
    _flashNumber = number;
    _flashes++;
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
        title: _header && _heroOnScreen
            ? null
            : Text(discussion?.title ?? widget.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          if (discussion != null)
            Builder(
              builder: (button) => IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: l10n.share,
                onPressed: () =>
                    shareFrom(button, WebLinks.discussion(widget.site, widget.discussionId, slug: discussion.slug)),
              ),
            ),
          if (_signedIn && discussion != null && _forum.extensions.bookmarks)
            IconButton(
              icon: Icon(discussion.bookmarked ? Icons.bookmark : Icons.bookmark_border),
              tooltip: discussion.bookmarked ? l10n.removeBookmark : l10n.bookmark,
              onPressed: _bookmarkDiscussion,
            ),
          if (_signedIn && discussion != null) _FollowMenu(level: discussion.subscription, onChanged: _setSubscription),
          if (discussion != null && _ModerationMenu.offersAny(discussion, canEditTags: _canEditTags(discussion)))
            _ModerationMenu(discussion: discussion, onSelected: _moderate, canEditTags: _canEditTags(discussion)),
        ],
      ),
      // Where the reader is ("12 of 340", opening the scrubber) and Reply, as the web's bar under
      // a discussion on a phone: "Log In to Reply" for a guest, "Can't Reply" where they may not.
      bottomNavigationBar: discussion == null || _model.total == 0
          ? null
          : _ThreadBar(
              key: const ValueKey('thread-bar'),
              position: (_position ?? _model.start + 1).clamp(1, _model.total),
              total: _model.total,
              onScrub: _scrub,
              action: _canReply
                  ? FilledButton.icon(
                      onPressed: _reply,
                      icon: const Icon(Icons.reply),
                      label: Text(kitL10n(context).reply),
                    )
                  : _guestCouldReply
                      ? FilledButton.tonalIcon(
                          onPressed: _logInToReply,
                          icon: const Icon(Icons.login),
                          label: Text(l10n.logInToReply),
                        )
                      : OutlinedButton(onPressed: null, child: Text(l10n.cannotReply)),
            ),
      body: switch (_model) {
        ThreadModel(discussion: null, error: final error?) => EmptyStateView.error(
            message: l10n.threadLoadFailed,
            hint: describeError(context, error),
            onRetry: () => _model.open(near: _near),
          ),
        ThreadModel(discussion: null) => const Center(child: CircularProgressIndicator()),
        // Pulled down at the top: the posts on screen again, with what's changed.
        _ => RefreshIndicator(
            onRefresh: () => _reload(at: _firstShownPost(), flash: false),
            child: ScrollablePositionedList.separated(
              key: ValueKey(_generation),
              itemScrollController: _scroll,
              itemPositionsListener: _positions,
              itemCount: _rowCount,
              initialScrollIndex: _initialRow(),
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, row) => _row(context, row, l10n),
            ),
          ),
      },
    );
  }

  int _initialRow() {
    final near = _near;
    if (near == null) return 0;
    final index = _model.indexOfNumber(near);
    return index < 0 ? 0 : _rowOf(index);
  }

  /// The list's row for the loaded post at [index]: the discussion's header for its first post,
  /// so the header shows with it rather than just above the screen.
  int _rowOf(int index) => index == 0 && _header ? 0 : _leading + index;

  Widget _row(BuildContext context, int row, FlarumLocalizations l10n) {
    if (_header && row == 0) return _DiscussionHero(discussion: _model.discussion!, recipients: _recipients);
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
      final tile = PostTile(
        key: ValueKey(post.id),
        site: widget.site,
        post: post,
        callbacks: _callbacksFor(post),
        onAuthorTap: (author) => _openUser(author.slug ?? author.username),
        onOpenReply: _openReply,
        tags: _tags,
        isBestAnswer: post.id == _model.discussion!.bestAnswerPostId,
        onGoToBestAnswer: post.number == 1 && _bestAnswerElsewhere ? _goToBestAnswer : null,
        bestAnswerPreview: post.number == 1 && _bestAnswerElsewhere ? _bestAnswerPreview() : null,
        onReply: _canReply
            ? () => _reply(initial: replyTo(post, l10n))
            : _guestCouldReply
                ? () => _logInToReply(initial: replyTo(post, l10n), at: post.number)
                : null,
        onQuote: _canReply ? () => _reply(initial: quoteOf(post, l10n)) : null,
        onEdit: post.canEdit ? () => _edit(post) : null,
        readerId: _readerId,
        reactions: _forum.info?.reactions ?? const [],
        onLike: _signedIn && post.canLike ? () => _like(post) : null,
        onReact: _signedIn && post.canReact ? (reaction) => _react(post, reaction) : null,
        onBookmark: _signedIn && _forum.extensions.bookmarks ? () => _bookmarkPost(post) : null,
        onChooseBestAnswer: post.canSelectAsBestAnswer && post.number > 1 ? () => _chooseBestAnswer(post) : null,
        onFlag: post.canFlag ? () => _flag(post) : null,
        authorIgnored: _ignored.isIgnored(post.author),
        onIgnore: _ignored.canIgnore(post.author) ? () => toggleIgnore(context, widget.site, post.author!) : null,
        onHide: post.canHide ? () => _hidePost(post) : null,
        onDeleteForever: post.canDelete && post.isHidden ? () => _deletePostForever(post) : null,
        onApprove: post.canApprove && !post.isApproved ? () => _approvePost(post) : null,
        onPollChanged: _signedIn ? (poll) => _pollChanged(post.id, poll) : null,
        link: WebLinks.discussion(widget.site, widget.discussionId, slug: _model.discussion?.slug, near: post.number),
      );
      final shown = post.number == _flashNumber ? _Flash(key: ValueKey(_flashes), child: tile) : tile;
      final gap = index > 0 ? timeLapsed(_model.posts[index - 1].createdAt, post.createdAt, l10n) : null;
      if (gap == null) return shown;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [TimeGap(text: gap), shown],
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
    return const SizedBox(height: DesignTokens.spacingXXXL);
  }
}

/// A tint behind [child] that fades out, to show which post the reader was taken to. Still when
/// the phone asks for less motion: the post is at the top of the list either way.
class _Flash extends StatefulWidget {
  const _Flash({super.key, required this.child});

  final Widget child;

  @override
  State<_Flash> createState() => _FlashState();
}

class _FlashState extends State<_Flash> with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade.value = 1;
    } else if (!_fade.isAnimating && _fade.value == 0) {
      _fade.forward();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, child) => ColoredBox(
        color: Color.lerp(tint, tint.withValues(alpha: 0), Curves.easeIn.transform(_fade.value))!,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// The web's discussion hero: the discussion's badges, tags and title on its first tag's colour
/// (a plain band without one), and who a private one is with.
class _DiscussionHero extends StatelessWidget {
  const _DiscussionHero({required this.discussion, this.recipients});

  final FlarumDiscussion discussion;
  final List<FlarumUser>? recipients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = flarumL10n(context);
    final tags = tagsInWebOrder(discussion.tags);
    final color = tags.isEmpty ? null : flarumTagColor(tags.first);
    final background = color ?? theme.colorScheme.surfaceContainer;
    final foreground = color == null
        ? theme.colorScheme.onSurface
        : (ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87);
    final badges = discussionBadges(context, discussion);
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXL),
      child: Column(
        children: [
          if (badges.isNotEmpty || tags.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: DesignTokens.spacingXS,
              runSpacing: DesignTokens.spacingXS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...badges,
                for (final tag in tags) TagLabel(tag: tag),
              ],
            ),
          const SizedBox(height: DesignTokens.spacingS),
          Semantics(
            header: true,
            child: Text(discussion.title,
                textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(color: foreground)),
          ),
          if (recipients case final people? when people.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingXS),
            Text(l10n.privateWith(people.map((user) => user.displayName).join(', ')),
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: foreground)),
          ],
        ],
      ),
    );
  }
}

/// The bar under a discussion: where the reader is, which opens the scrubber, and [action] (Reply).
class _ThreadBar extends StatelessWidget {
  const _ThreadBar({super.key, required this.position, required this.total, required this.onScrub, required this.action});

  final int position;
  final int total;
  final VoidCallback onScrub;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingXS),
          child: Row(
            children: [
              Flexible(
                child: TextButton.icon(
                  onPressed: onScrub,
                  icon: const Icon(Icons.unfold_more),
                  label: Text(flarumL10n(context).scrubberPosition(position, total), overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingS),
              action,
            ],
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
}

/// How the reader follows the discussion (flarum/subscriptions), as the web's menu offers it.
enum _DiscussionAction { rename, editTags, lock, unlock, stick, unstick, hide, restore, deleteForever }

/// Asks for a discussion's new title; pops it, or null.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.title});

  final String title;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _field = TextEditingController(text: widget.title);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(flarumL10n(context).renameDiscussionTitle),
        content: TextField(controller: _field, autofocus: true, textCapitalization: TextCapitalization.sentences),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(kitL10n(context).cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_field.text.trim().isEmpty ? null : _field.text.trim()),
            child: Text(flarumL10n(context).renameDiscussion),
          ),
        ],
      );
}

/// What a moderator may do to the discussion, as the web's discussion controls offer it. Its author
/// may rename it too, and delete it while nobody has replied: for an author who isn't a moderator
/// the menu is a plain ⋮, not the moderator's shield.
class _ModerationMenu extends StatelessWidget {
  const _ModerationMenu({required this.discussion, required this.onSelected, this.canEditTags = false});

  final FlarumDiscussion discussion;
  final void Function(_DiscussionAction action) onSelected;

  /// Whether Edit Tags is offered: the reader may tag it, on a forum with flarum/tags.
  final bool canEditTags;

  static bool offersAny(FlarumDiscussion d, {bool canEditTags = false}) =>
      d.canRename || canEditTags || d.canLock || d.canSticky || d.canHide || d.canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final kit = kitL10n(context);
    PopupMenuItem<_DiscussionAction> item(_DiscussionAction action, IconData icon, String label) => PopupMenuItem(
          value: action,
          child: Row(children: [Icon(icon), const SizedBox(width: DesignTokens.spacingM), Flexible(child: Text(label))]),
        );
    final d = discussion;
    final moderator = d.canLock || d.canSticky || d.canDelete;
    return PopupMenuButton<_DiscussionAction>(
      icon: Icon(moderator ? Icons.shield_outlined : Icons.more_vert),
      tooltip: moderator ? l10n.moderate : MaterialLocalizations.of(context).showMenuTooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        if (d.canRename) item(_DiscussionAction.rename, Icons.edit_outlined, l10n.renameDiscussion),
        if (canEditTags) item(_DiscussionAction.editTags, Icons.sell_outlined, l10n.editTags),
        if (d.canLock)
          d.isLocked
              ? item(_DiscussionAction.unlock, Icons.lock_open, l10n.unlockDiscussion)
              : item(_DiscussionAction.lock, Icons.lock_outline, l10n.lockDiscussion),
        if (d.canSticky)
          d.isSticky
              ? item(_DiscussionAction.unstick, Icons.push_pin_outlined, l10n.unstickDiscussion)
              : item(_DiscussionAction.stick, Icons.push_pin, l10n.stickDiscussion),
        if (d.canHide)
          d.isHidden
              ? item(_DiscussionAction.restore, Icons.restore, l10n.restore)
              : item(_DiscussionAction.hide, Icons.delete_outline, kit.delete),
        if (d.canDelete && d.isHidden) item(_DiscussionAction.deleteForever, Icons.delete_forever_outlined, l10n.deleteForever),
      ],
    );
  }
}

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
    // flarum/subscriptions' own icons: an empty star, a star, a crossed-out eye; and the level's
    // name, as the web's button says it (Follow while not following).
    return PopupMenuButton<String>(
      icon: Icon(switch (level) {
        'follow' => Icons.star,
        'ignore' => Icons.visibility_off,
        _ => Icons.star_border,
      }),
      tooltip: switch (level) {
        'follow' => l10n.following,
        'ignore' => l10n.ignoring,
        _ => l10n.follow,
      },
      onSelected: (value) => onChanged(value == _none ? null : value),
      itemBuilder: (_) => [
        item(_none, Icons.star_border, l10n.notFollowing, l10n.notFollowingHint),
        item('follow', Icons.star, l10n.following, l10n.followingHint),
        item('ignore', Icons.visibility_off, l10n.ignoring, l10n.ignoringHint),
      ],
    );
  }
}
