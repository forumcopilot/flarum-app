import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';

/// The forum home's views, as the web's sort menu and sidebar offer them.
enum DiscussionView { latest, top, newest, following }

/// A list of discussions for a view, optionally of one tag or started by one
/// user, loaded a page at a time.
class DiscussionListModel extends ChangeNotifier {
  DiscussionListModel(this.forum, {this.view = DiscussionView.latest, this.tagSlug, this.author, this.pageSize = 20});

  final FlarumForum forum;
  final DiscussionView view;
  final String? tagSlug;

  /// A username: only the discussions they started.
  final String? author;
  final int pageSize;

  final List<FlarumDiscussion> items = [];
  bool hasMore = true;
  bool loading = false;
  Object? error;

  /// When the reader last marked everything read, which counts as reading
  /// every discussion older than it.
  DateTime? markedAllAsReadAt;

  bool get signedIn => forum.isSignedIn;

  /// Loads the first page again.
  Future<void> refresh() => _load(reset: true);

  /// Loads the next page, unless one is loading or there is none.
  Future<void> loadMore() async {
    if (loading || !hasMore || error != null) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    loading = true;
    if (reset) error = null;
    _notify();
    try {
      if (reset && signedIn) markedAllAsReadAt = (await forum.current()).actor?.markedAllAsReadAt;
      final page = await forum.api.discussions(
        sort: switch (view) {
          DiscussionView.top => DiscussionSort.top,
          DiscussionView.newest => DiscussionSort.newest,
          _ => DiscussionSort.latest,
        },
        following: view == DiscussionView.following,
        tagSlug: tagSlug,
        author: author,
        offset: reset ? 0 : items.length,
        limit: pageSize,
      );
      if (reset) items.clear();
      items.addAll(page.items);
      hasMore = page.hasMore;
      error = null;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      _notify();
    }
  }

  /// Fetches discussion [id] again (after the reader has been in it) and
  /// puts it in its place in the list.
  Future<void> reload(String id) async {
    final index = items.indexWhere((d) => d.id == id);
    if (index < 0) return;
    try {
      final fresh = await forum.api.discussion(id);
      final at = items.indexWhere((d) => d.id == id);
      if (at >= 0) items[at] = fresh;
      _notify();
    } catch (_) {
      // The row keeps what it showed.
    }
  }

  /// Posts the reader hasn't read in [d], as the web counts them.
  int unreadIn(FlarumDiscussion d) => unreadCount(d, markedAllAsReadAt, signedIn: signedIn);

  /// The post to open [d] at: the first the reader hasn't read, as the web
  /// links a discussion; its start for a guest or a read discussion.
  int? openAt(FlarumDiscussion d) {
    if (unreadIn(d) == 0) return null;
    final next = (d.lastReadPostNumber ?? 0) + 1;
    final last = d.lastPostNumber;
    return last == null || next <= last ? next : last;
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
