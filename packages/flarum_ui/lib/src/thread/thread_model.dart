import 'dart:async';
import 'dart:math' as math;

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';

import '../render/flarum_html.dart';

/// A discussion as the thread page shows it: a window of its posts, loaded a
/// page at a time either way, and how far the reader has read.
///
/// The discussion's post ids ([FlarumDiscussion.postIds]) say where every
/// post sits, so the thread can open at any post (`page[near]`) and page
/// back and forward by offset from there, on 1.8 and 2.0 alike.
class ThreadModel extends ChangeNotifier {
  ThreadModel(this.forum, this.discussionId,
      {this.pageSize = 20, this.readDelay = const Duration(seconds: 1), this.forumBaseUrl});

  final FlarumForum forum;
  final String discussionId;
  final int pageSize;

  /// The forum's address as the posts are rendered against it: each page's HTML is then prepared
  /// on a worker isolate as it arrives ([FlarumHtml.warm]).
  final String? forumBaseUrl;

  /// How long reading stays still before it's reported to the forum.
  final Duration readDelay;

  FlarumDiscussion? discussion;

  /// The loaded posts, in number order: posts [start] to [end] of the discussion.
  final List<FlarumPost> posts = [];

  /// The index of [posts]' first post in the discussion.
  int start = 0;

  /// Why the thread failed to open, if it did.
  Object? error;

  /// Why the last page failed to load, if it did; the next attempt clears it.
  Object? pageError;

  bool loadingNext = false;
  bool loadingPrevious = false;

  int get end => start + posts.length;
  int get total => discussion?.postIds.length ?? 0;
  bool get hasPrevious => start > 0;
  bool get hasNext => end < total;

  /// Opens the discussion at post number [near], or at its start.
  Future<void> open({int? near}) async {
    error = null;
    notifyListeners();
    try {
      final discussion = await forum.api.discussion(discussionId, withPostIds: true);
      final FlarumPage<FlarumPost> page;
      var first = 0;
      if (near != null && near > 1) {
        page = await forum.api.postsNear(discussionId, near, limit: pageSize);
        if (page.items.isNotEmpty) first = math.max(0, discussion.postIds.indexOf(page.items.first.id));
      } else {
        page = await forum.api.posts(discussionId, limit: pageSize);
      }
      this.discussion = discussion;
      start = first;
      _warm(page.items);
      posts
        ..clear()
        ..addAll(page.items);
      _readUpTo = discussion.lastReadPostNumber ?? 0;
    } catch (e) {
      error = e;
    }
    _notify();
  }

  /// Opens the discussion around its post at [index] (0 for the first), as the web's scrubber jumps
  /// to a position rather than a post number: the page around it, by offset.
  Future<void> openAtIndex(int index) async {
    error = null;
    notifyListeners();
    try {
      final discussion = await forum.api.discussion(discussionId, withPostIds: true);
      final total = discussion.postIds.length;
      final offset = math.max(0, math.min(index - pageSize ~/ 2, total - pageSize));
      final page = await forum.api.posts(discussionId, offset: offset, limit: pageSize);
      this.discussion = discussion;
      start = offset;
      _warm(page.items);
      posts
        ..clear()
        ..addAll(page.items);
      _readUpTo = discussion.lastReadPostNumber ?? 0;
    } catch (e) {
      error = e;
    }
    _notify();
  }

  /// Loads the page after the window.
  Future<void> loadNext() async {
    if (loadingNext || !hasNext || _disposed) return;
    loadingNext = true;
    pageError = null;
    _notify();
    try {
      final page = await forum.api.posts(discussionId, offset: end, limit: pageSize);
      _warm(page.items);
      posts.addAll(page.items);
    } catch (e) {
      pageError = e;
    } finally {
      loadingNext = false;
      _notify();
    }
  }

  /// Loads the page before the window; returns how many posts came, so the
  /// view can keep the reader where they were.
  Future<int> loadPrevious() async {
    if (loadingPrevious || !hasPrevious || _disposed) return 0;
    loadingPrevious = true;
    pageError = null;
    _notify();
    var added = 0;
    try {
      final offset = math.max(0, start - pageSize);
      final page = await forum.api.posts(discussionId, offset: offset, limit: start - offset);
      _warm(page.items);
      posts.insertAll(0, page.items);
      start = offset;
      added = page.items.length;
    } catch (e) {
      pageError = e;
    } finally {
      loadingPrevious = false;
      _notify();
    }
    return added;
  }

  /// Prepares [page]'s HTML off the UI thread, so the frame that first shows a post finds it ready
  /// (flutter_html's own work is then most of that frame). Not awaited: a post shown before its
  /// page is ready prepares its own, as it would anyway.
  void _warm(List<FlarumPost> page) {
    final base = forumBaseUrl;
    if (base == null) return;
    FlarumHtml.warm([for (final post in page) if (post.contentHtml case final html?) html], forumBaseUrl: base).ignore();
  }

  /// The position of post [number] in [posts], or -1 if it isn't loaded.
  int indexOfNumber(int number) => posts.indexWhere((p) => p.number >= number);

  // ---- Reading ----

  int _readUpTo = 0;
  int? _pendingRead;
  Timer? _readTimer;

  /// The reader has seen post [number]. Flarum keeps one mark per discussion
  /// and never lowers it, so only progress is sent, once reading pauses.
  void reportRead(int number) {
    if (!forum.isSignedIn || number <= math.max(_readUpTo, _pendingRead ?? 0)) return;
    _pendingRead = number;
    _readTimer?.cancel();
    _readTimer = Timer(readDelay, _sendRead);
  }

  Future<void> _sendRead() async {
    final number = _pendingRead;
    if (number == null) return;
    _pendingRead = null;
    try {
      await forum.api.markDiscussionRead(discussionId, number);
      _readUpTo = math.max(_readUpTo, number);
    } catch (_) {
      // Next time, then: the mark only moves forward.
    }
  }

  bool _disposed = false;

  /// The loaded post [id], if it's loaded.
  FlarumPost? postById(String id) => posts.where((p) => p.id == id).firstOrNull;

  /// Puts [post] in place of the loaded post with its id: after a like, a reaction, a bookmark.
  void replacePost(FlarumPost post) {
    final i = posts.indexWhere((p) => p.id == post.id);
    if (i < 0) return;
    posts[i] = post;
    _notify();
  }

  /// Changes the discussion in place: following it, its bookmark, its best answer.
  void updateDiscussion(FlarumDiscussion Function(FlarumDiscussion) change) {
    final current = discussion;
    if (current == null) return;
    discussion = change(current);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _readTimer?.cancel();
    // Leaving the thread sends what was read without waiting.
    unawaited(_sendRead());
    super.dispose();
  }
}
