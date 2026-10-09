import '../attributes.dart';
import '../json_api.dart';
import 'post.dart';
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
    this.canRename = false,
    this.canDelete = false,
    this.canHide = false,
    this.canTag = false,
    this.canLock = false,
    this.canSticky = false,
    this.isApproved = true,
    this.isHidden = false,
    this.isPrivate = false,
    this.hasPoll = false,
    this.hasBestAnswer = false,
    this.bookmarked = false,
    this.author,
    this.lastPostedUser,
    this.tags = const [],
    this.mostRelevantPost,
    this.postIds = const [],
  });

  factory FlarumDiscussion.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final author = document.find(resource.toOne('user'));
    final lastPostedUser = document.find(resource.toOne('lastPostedUser'));
    final relevant = document.find(resource.toOne('mostRelevantPost'));
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
      canRename: a.boolean('canRename') ?? false,
      canDelete: a.boolean('canDelete') ?? false,
      canHide: a.boolean('canHide') ?? false,
      canTag: a.boolean('canTag') ?? false,
      canLock: a.boolean('canLock') ?? false,
      canSticky: a.boolean('canSticky') ?? false,
      isApproved: a.boolean('isApproved') ?? true,
      isHidden: a.boolean('isHidden') ?? false,
      isPrivate: a.boolean('isPrivateDiscussion') ?? false,
      hasPoll: a.boolean('hasPoll') ?? false,
      hasBestAnswer: a.boolean('hasBestAnswer') ?? false,
      bookmarked: a.boolean('bookmarked') ?? false,
      author: author == null ? null : FlarumUser.fromResource(author),
      lastPostedUser: lastPostedUser == null ? null : FlarumUser.fromResource(lastPostedUser),
      tags: [for (final tag in document.findAll(resource.toMany('tags'))) FlarumTag.fromResource(tag)],
      mostRelevantPost: relevant == null ? null : FlarumPost.fromResource(relevant, document, discussion: resource),
      postIds: [for (final ref in resource.toMany('posts')) ref.id],
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
  final bool canRename;

  /// Delete for good; [canHide] is the soft delete.
  final bool canDelete;
  final bool canHide;

  /// Change its tags, i.e. move it.
  final bool canTag;
  final bool canLock;
  final bool canSticky;

  /// False while flarum/approval holds it for a moderator.
  final bool isApproved;

  /// Soft-deleted; only moderators see these.
  final bool isHidden;

  /// A fof/byobu private discussion.
  final bool isPrivate;
  final bool hasPoll;

  /// fof/best-answer chose an answer.
  final bool hasBestAnswer;

  /// fof/bookmarks: the reader bookmarked it.
  final bool bookmarked;
  final FlarumUser? author;
  final FlarumUser? lastPostedUser;
  final List<FlarumTag> tags;

  /// In search results, the post that best matches the query.
  final FlarumPost? mostRelevantPost;

  /// Every post the reader can see, comments and events, in number order:
  /// from [FlarumApi.discussion] with `withPostIds`, empty otherwise. A post's
  /// index here is its offset in [FlarumApi.posts].
  final List<String> postIds;
}
