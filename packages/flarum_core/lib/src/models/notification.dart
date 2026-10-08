import '../attributes.dart';
import '../json_api.dart';
import 'user.dart';

/// One of the reader's notifications.
class FlarumNotification {
  const FlarumNotification({
    required this.id,
    required this.contentType,
    this.content,
    this.createdAt,
    this.isRead = false,
    this.fromUser,
    this.subject,
  });

  factory FlarumNotification.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final fromUser = document.find(resource.toOne('fromUser'));
    return FlarumNotification(
      id: resource.id,
      contentType: a.string('contentType') ?? '',
      content: a['content'],
      createdAt: a.date('createdAt'),
      isRead: a.boolean('isRead') ?? false,
      fromUser: fromUser == null ? null : FlarumUser.fromResource(fromUser),
      subject: resource.toOne('subject'),
    );
  }

  final String id;

  /// The notification type, e.g. `newPost`, `postLiked`, `userMentioned`,
  /// `postMentioned`, `discussionRenamed`, or an extension's own type.
  final String contentType;

  /// Type-specific data, such as the reply number for `newPost`.
  final Object? content;
  final DateTime? createdAt;
  final bool isRead;
  final FlarumUser? fromUser;

  /// What the notification is about, e.g. `(type: 'posts', id: '12')`.
  final ResourceId? subject;
}
