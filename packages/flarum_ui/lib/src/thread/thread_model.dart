import 'dart:async';
import 'dart:math' as math;

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';

/// A discussion as the thread page shows it: a window of its posts, loaded a
/// page at a time either way, and how far the reader has read.
///
/// The discussion's post ids ([FlarumDiscussion.postIds]) say where every
/// post sits, so the thread can open at any post (`page[near]`) and page
/// back and forward by offset from there, on 1.8 and 2.0 alike.
class ThreadModel extends ChangeNotifier {
  ThreadModel(this.forum, this.discussionId, {this.pageSize = 20, this.readDelay = const Duration(seconds: 1)});

  final FlarumForum forum;
  final String discussionId;
  final int pageSize;

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
