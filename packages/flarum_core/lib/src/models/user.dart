import '../attributes.dart';
import '../json_api.dart';
import 'group.dart';

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
    this.blocksPd = false,
    this.suspendedUntil,
    this.suspendMessage,
    this.suspendReason,
    this.canSuspend = false,
    this.groups = const [],
    this.bestAnswerCount,
  });

  /// [document] brings the user's groups, where the request included them.
  factory FlarumUser.fromResource(JsonApiResource resource, {JsonApiDocument? document}) {
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
      blocksPd: a.boolean('blocksPd') ?? false,
      suspendedUntil: a.date('suspendedUntil'),
      suspendMessage: a.nonEmptyString('suspendMessage'),
      suspendReason: a.nonEmptyString('suspendReason'),
      canSuspend: a.boolean('canSuspend') ?? false,
      groups: [
        if (document != null)
          for (final group in document.findAll(resource.toMany('groups'))) FlarumGroup.fromResource(group),
      ],
      bestAnswerCount: a.integer('bestAnswerCount'),
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
        blocksPd: blocksPd,
        suspendedUntil: suspendedUntil,
        suspendMessage: suspendMessage,
        suspendReason: suspendReason,
        canSuspend: canSuspend,
        groups: groups,
        bestAnswerCount: bestAnswerCount,
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

  /// The user takes no private discussions (fof/byobu's setting on their account).
  final bool blocksPd;

  /// Until when the user is suspended (flarum/suspend): shown to them and to moderators. Flarum's
  /// web suspends "indefinitely" until 2038 ([isSuspendedIndefinitely]).
  final DateTime? suspendedUntil;

  /// What the suspension says to the user; [suspendReason] is for moderators only.
  final String? suspendMessage;
  final String? suspendReason;

  /// Whether the reader may suspend the user.
  final bool canSuspend;

  /// The groups the web badges them with on their profile (shown ones only, as the web shows).
  final List<FlarumGroup> groups;

  /// Their posts chosen as best answers (fof/best-answer), when the forum counts them.
  final int? bestAnswerCount;

  bool get isSuspended => suspendedUntil?.isAfter(DateTime.now()) ?? false;

  bool get isSuspendedIndefinitely => !(suspendedUntil?.isBefore(indefiniteSuspension) ?? true);

  /// The date Flarum's web suspends someone "indefinitely" until.
  static final indefiniteSuspension = DateTime.utc(2038);
}
