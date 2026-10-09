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
    this.discussionId,
    this.discussionTitle,
    this.discussionSlug,
    this.postId,
    this.postNumber,
  });

  factory FlarumNotification.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final fromUser = document.find(resource.toOne('fromUser'));
    final subjectRef = resource.toOne('subject');
    final subject = document.find(subjectRef);
    // A post subject points at its discussion (when subject.discussion was
    // included); a discussion subject is the discussion itself.
    final discussion = subjectRef?.type == 'discussions' ? subject : document.find(subject?.toOne('discussion'));
    final content = a['content'];
    return FlarumNotification(
      id: resource.id,
      contentType: a.string('contentType') ?? '',
      content: a['content'],
      createdAt: a.date('createdAt'),
      isRead: a.boolean('isRead') ?? false,
      fromUser: fromUser == null ? null : FlarumUser.fromResource(fromUser),
      subject: subjectRef,
      discussionId: discussion?.id ?? (content is Map ? content['discussionId']?.toString() : null),
      discussionTitle: discussion?.attributes.string('title'),
      discussionSlug: discussion?.attributes.nonEmptyString('slug'),
      postId: subjectRef?.type == 'posts' ? subjectRef!.id : null,
      postNumber: subjectRef?.type == 'posts'
          ? subject?.attributes.integer('number')
          : (content is Map ? int.tryParse('${content['postNumber'] ?? ''}') : null),
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

  /// The discussion it's about: the subject itself, or a post subject's discussion.
  final String? discussionId;
  final String? discussionTitle;

  /// Flarum's slug, the whole path segment (`5-welcome`).
  final String? discussionSlug;

  /// The post it's about, when the subject is a post.
  final String? postId;

  /// The post to open at: the subject post's number, or the event's own
  /// (byobu's replies carry `content.postNumber`).
  final int? postNumber;

  /// The post number to open the discussion at: for a post mention, the
  /// reply that made it (`content.replyNumber`; the subject is the reader's
  /// own post), otherwise [postNumber].
  int? get openAt {
    final content = this.content;
    if (contentType == 'postMentioned' && content is Map) {
      final reply = int.tryParse('${content['replyNumber'] ?? ''}');
      if (reply != null) return reply;
    }
    return postNumber;
  }
}
