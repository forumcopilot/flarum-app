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
    this.ignored,
    this.canBeIgnored,
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
      ignored: a.boolean('ignored'),
      canBeIgnored: a.boolean('canBeIgnored'),
    );
  }

  /// This user after the reader ignored or stopped ignoring them.
  FlarumUser copyWith({bool? ignored}) => FlarumUser(
        id: id,
        username: username,
        displayName: displayName,
        slug: slug,
        avatarUrl: avatarUrl,
        joinTime: joinTime,
        lastSeenAt: lastSeenAt,
        discussionCount: discussionCount,
        commentCount: commentCount,
        unreadNotificationCount: unreadNotificationCount,
        newNotificationCount: newNotificationCount,
        markedAllAsReadAt: markedAllAsReadAt,
        ignored: ignored ?? this.ignored,
        canBeIgnored: canBeIgnored,
      );

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

  /// Whether the reader ignores this user (fof/ignore-users): the web folds their posts away.
  /// Null on forums without the extension.
  final bool? ignored;

  /// Whether the reader may ignore this user: not themselves, nor a moderator by default. Null on
  /// forums without fof/ignore-users.
  final bool? canBeIgnored;
}
