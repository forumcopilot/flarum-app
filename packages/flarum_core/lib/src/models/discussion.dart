import '../attributes.dart';
import '../json_api.dart';
import 'tag.dart';
import 'user.dart';

/// A discussion, with its author, last poster and tags when the response included them.
class FlarumDiscussion {
  const FlarumDiscussion({
    required this.id,
    required this.title,
    this.slug,
    this.commentCount = 0,
    this.participantCount = 0,
    this.createdAt,
    this.lastPostedAt,
    this.lastPostNumber,
    this.lastReadPostNumber,
    this.lastReadAt,
    this.isSticky = false,
    this.isLocked = false,
    this.subscription,
    this.canReply = false,
    this.author,
    this.lastPostedUser,
    this.tags = const [],
  });

  factory FlarumDiscussion.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final author = document.find(resource.toOne('user'));
    final lastPostedUser = document.find(resource.toOne('lastPostedUser'));
    return FlarumDiscussion(
      id: resource.id,
      title: a.string('title') ?? '',
      slug: a.nonEmptyString('slug'),
      commentCount: a.integer('commentCount') ?? 0,
      participantCount: a.integer('participantCount') ?? 0,
      createdAt: a.date('createdAt'),
      lastPostedAt: a.date('lastPostedAt'),
      lastPostNumber: a.integer('lastPostNumber'),
      lastReadPostNumber: a.integer('lastReadPostNumber'),
      lastReadAt: a.date('lastReadAt'),
      isSticky: a.boolean('isSticky') ?? false,
      isLocked: a.boolean('isLocked') ?? false,
      subscription: a.nonEmptyString('subscription'),
      canReply: a.boolean('canReply') ?? false,
      author: author == null ? null : FlarumUser.fromResource(author),
      lastPostedUser: lastPostedUser == null ? null : FlarumUser.fromResource(lastPostedUser),
      tags: [for (final tag in document.findAll(resource.toMany('tags'))) FlarumTag.fromResource(tag)],
    );
  }

  final String id;
  final String title;
  final String? slug;

  /// Comments, the first post included (Flarum's count, not including event posts).
  final int commentCount;
  final int participantCount;
  final DateTime? createdAt;
  final DateTime? lastPostedAt;
  final int? lastPostNumber;

  /// The highest post number the reader has read; null for guests or unread discussions.
  final int? lastReadPostNumber;
  final DateTime? lastReadAt;
  final bool isSticky;
  final bool isLocked;

  /// flarum/subscriptions state for the reader: `follow`, `ignore`, or null.
  final String? subscription;
  final bool canReply;
  final FlarumUser? author;
  final FlarumUser? lastPostedUser;
  final List<FlarumTag> tags;
}
