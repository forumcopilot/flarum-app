import '../attributes.dart';
import '../json_api.dart';

/// A Flarum user as the API shows it to the current reader. Counts and
/// notification fields are only present for the reader's own account or
/// where the forum exposes them.
class FlarumUser {
  const FlarumUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.slug,
    this.avatarUrl,
    this.joinTime,
    this.lastSeenAt,
    this.discussionCount,
    this.commentCount,
    this.unreadNotificationCount,
    this.newNotificationCount,
    this.markedAllAsReadAt,
  });

  factory FlarumUser.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    final username = a.string('username') ?? '';
    return FlarumUser(
      id: resource.id,
      username: username,
      displayName: a.nonEmptyString('displayName') ?? username,
      slug: a.nonEmptyString('slug'),
      avatarUrl: a.nonEmptyString('avatarUrl'),
      joinTime: a.date('joinTime'),
      lastSeenAt: a.date('lastSeenAt'),
      discussionCount: a.integer('discussionCount'),
      commentCount: a.integer('commentCount'),
      unreadNotificationCount: a.integer('unreadNotificationCount'),
      newNotificationCount: a.integer('newNotificationCount'),
      markedAllAsReadAt: a.date('markedAllAsReadAt'),
    );
  }

  final String id;
  final String username;

  /// The name to show: the nickname when the forum uses nicknames, else the username.
  final String displayName;
  final String? slug;
  final String? avatarUrl;
  final DateTime? joinTime;
  final DateTime? lastSeenAt;
  final int? discussionCount;
  final int? commentCount;

  /// Notifications the reader hasn't read. Own account only.
  final int? unreadNotificationCount;

  /// Notifications since the reader last opened the list (the web's badge). Own account only.
  final int? newNotificationCount;

  /// When the reader last marked everything read; discussions with no
  /// activity since then count as read. Own account only.
  final DateTime? markedAllAsReadAt;
}
