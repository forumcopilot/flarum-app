import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';

/// The forum home's lists, as the web's view menu offers them: All Discussions, and the
/// reader's Following, Bookmarks (fof/bookmarks) and Private Discussions (fof/byobu).
enum DiscussionView { all, following, bookmarks, private }

/// A list of discussions for a view, in a sort, optionally of one tag or started by one user,
/// loaded a page at a time.
class DiscussionListModel extends ChangeNotifier {
  DiscussionListModel(this.forum,
      {this.view = DiscussionView.all,
      this.sort = DiscussionSort.latest,
      this.tagSlug,
      this.author,
      bool bookmarked = false,
      bool private = false,
      this.pageSize = 20})
      : bookmarked = bookmarked || view == DiscussionView.bookmarks,
        private = private || view == DiscussionView.private;

  final FlarumForum forum;
  final DiscussionView view;
  final DiscussionSort sort;
  final String? tagSlug;

  /// A username: only the discussions they started.
  final String? author;

  /// The reader's bookmarked discussions (fof/bookmarks).
  final bool bookmarked;

  /// The reader's private discussions (fof/byobu).
  final bool private;
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

  /// Loads the next page, unless one is loading or there is none. Not after a failure, until
  /// [retryMore]: the list's end would ask again with every scroll.
  Future<void> loadMore() async {
    if (loading || !hasMore || error != null) return;
    await _load(reset: false);
  }

  /// The list end's Retry: the next page, after a failure.
  Future<void> retryMore() async {
    if (loading) return;
    error = null;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    loading = true;
    if (reset) error = null;
    _notify();
    try {
      if (reset && signedIn) markedAllAsReadAt = (await forum.current()).actor?.markedAllAsReadAt;
      final page = await forum.api.discussions(
        sort: sort,
        following: view == DiscussionView.following,
        tagSlug: tagSlug,
        author: author,
        bookmarked: bookmarked,
        private: private,
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
  /// puts it in its place in the list, or takes it out where it no longer
  /// belongs: ignored (Flarum leaves those out of every list), or no longer
  /// bookmarked or followed in those lists.
  Future<void> reload(String id) async {
    final index = items.indexWhere((d) => d.id == id);
    if (index < 0) return;
    try {
      final fresh = await forum.api.discussion(id);
      final at = items.indexWhere((d) => d.id == id);
      if (at >= 0) {
        final gone = fresh.subscription == 'ignore' ||
            (bookmarked && !fresh.bookmarked) ||
            (view == DiscussionView.following && fresh.subscription != 'follow');
        if (gone) {
          items.removeAt(at);
        } else {
          items[at] = fresh;
        }
      }
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

  final Map<String, String?> _excerpts = {};

  /// A sticky discussion's opening words, under its row while the reader hasn't opened it, as
  /// flarum/sticky shows a forum's rules (on 2.0 when the forum shows excerpts). 2.0 sends them
  /// with the list; on 1.x the first post is read once, and the row shows them when they come.
  String? excerptOf(FlarumDiscussion d) {
    if (!d.isSticky || (d.lastReadPostNumber ?? 0) > 0 || !(forum.info?.showsExcerpts ?? true)) return null;
    if (d.firstPostExcerpt case final known?) return known;
    if (_excerpts.containsKey(d.id)) return _excerpts[d.id];
    _excerpts[d.id] = null;
    forum.api.firstPost(d.id).then((post) {
      _excerpts[d.id] = flarumExcerpt(post?.contentHtml);
      _notify();
    }, onError: (Object _) {});
    return null;
  }

  final Map<String, List<FlarumUser>> _recipients = {};
  final Set<String> _readingRecipients = {};

  /// Who private discussion [d] is with (fof/byobu): in the list where it was asked for (the
  /// Private Discussions page), else read once for its row, which shows it when it comes.
  List<FlarumUser> recipientsOf(FlarumDiscussion d) {
    if (!d.isPrivate) return const [];
    // The others, as the web names them: never the reader.
    List<FlarumUser> others(List<FlarumUser> users) =>
        [for (final user in users) if (user.id != forum.info?.actor?.id) user];
    if (d.recipients.isNotEmpty) return others(d.recipients);
    if (_recipients[d.id] case final known?) return others(known);
    if (_readingRecipients.add(d.id)) {
      forum.api.recipients(d.id).then((users) {
        _recipients[d.id] = users;
        _notify();
      }, onError: (Object _) {});
    }
    return const [];
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
