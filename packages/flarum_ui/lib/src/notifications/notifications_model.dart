import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';

/// The reader's notifications, a page at a time.
///
/// Listing them resets the "new" badge the website shows the reader, as
/// opening the website's notification menu does.
class NotificationsModel extends ChangeNotifier {
  NotificationsModel(this.forum, {this.pageSize = 20});

  final FlarumForum forum;
  final int pageSize;

  final List<FlarumNotification> items = [];
  bool hasMore = true;
  bool loading = false;
  Object? error;

  Future<void> refresh() => _load(reset: true);

  Future<void> loadMore() async {
    if (loading || !hasMore || error != null) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    loading = true;
    if (reset) error = null;
    _notify();
    try {
      final page = await forum.api.notifications(offset: reset ? 0 : items.length, limit: pageSize);
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

  /// Marks [n] read, here at once and then on the forum.
  Future<void> markRead(FlarumNotification n) async {
    if (n.isRead) return;
    _replace(n, read: true);
    try {
      await forum.api.markNotificationRead(n.id);
    } catch (_) {
      _replace(n, read: false);
    }
  }

  /// Marks every notification read. Returns whether the forum did.
  Future<bool> markAllRead() async {
    final before = List.of(items);
    for (final n in before) {
      _replace(n, read: true);
    }
    try {
      await forum.api.markAllNotificationsRead();
      return true;
    } catch (_) {
      items
        ..clear()
        ..addAll(before);
      _notify();
      return false;
    }
  }

  void _replace(FlarumNotification n, {required bool read}) {
    final i = items.indexWhere((x) => x.id == n.id);
    if (i < 0) return;
    final old = items[i];
    items[i] = FlarumNotification(
      id: old.id,
      contentType: old.contentType,
      content: old.content,
      createdAt: old.createdAt,
      isRead: read,
      fromUser: old.fromUser,
      subject: old.subject,
      discussionId: old.discussionId,
      discussionTitle: old.discussionTitle,
      discussionSlug: old.discussionSlug,
      postId: old.postId,
      postNumber: old.postNumber,
    );
    _notify();
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
