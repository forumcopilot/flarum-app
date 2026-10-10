import '../attributes.dart';
import '../json_api.dart';
import 'user.dart';

/// A post. Comments carry rendered [contentHtml]; event posts (a discussion
/// renamed, locked, stickied, tagged…) carry structured [content] instead.
class FlarumPost {
  const FlarumPost({
    required this.id,
    required this.number,
    required this.contentType,
    this.contentHtml,
    this.content,
    this.createdAt,
    this.editedAt,
    this.isHidden = false,
    this.discussionId,
    this.discussionTitle,
    this.author,
    this.canEdit = false,
    this.canDelete = false,
    this.canHide = false,
    this.canFlag = false,
    this.canLike = false,
    this.likesCount = 0,
    this.isApproved = true,
    this.canApprove = false,
    this.bookmarked = false,
    this.mentionedByCount = 0,
    this.canSelectAsBestAnswer = false,
    this.mentionedBy = const [],
  });

  /// [discussion] stands in for the post's own `discussion` relationship when a
  /// response nests the post under its discussion (`mostRelevantPost`).
  factory FlarumPost.fromResource(JsonApiResource resource, JsonApiDocument document, {JsonApiResource? discussion}) {
    final a = resource.attributes;
    final author = document.find(resource.toOne('user'));
    discussion ??= document.find(resource.toOne('discussion'));
    return FlarumPost(
      id: resource.id,
      number: a.integer('number') ?? 0,
      contentType: a.string('contentType') ?? 'comment',
      contentHtml: a.string('contentHtml'),
      content: a['content'],
      createdAt: a.date('createdAt'),
      editedAt: a.date('editedAt'),
      isHidden: a.boolean('isHidden') ?? false,
      discussionId: resource.toOne('discussion')?.id ?? discussion?.id,
      discussionTitle: discussion?.attributes.string('title'),
      author: author == null ? null : FlarumUser.fromResource(author),
      canEdit: a.boolean('canEdit') ?? false,
      canDelete: a.boolean('canDelete') ?? false,
      canHide: a.boolean('canHide') ?? false,
      canFlag: a.boolean('canFlag') ?? false,
      canLike: a.boolean('canLike') ?? false,
      likesCount: a.integer('likesCount') ?? 0,
      isApproved: a.boolean('isApproved') ?? true,
      canApprove: a.boolean('canApprove') ?? false,
      bookmarked: a.boolean('bookmarked') ?? false,
      mentionedByCount: a.integer('mentionedByCount') ?? 0,
      canSelectAsBestAnswer: a.boolean('canSelectAsBestAnswer') ?? false,
      mentionedBy: [
        for (final ref in resource.toMany('mentionedBy')) FlarumPostReply.from(ref, document),
      ],
    );
  }

  final String id;

  /// The post's position in its discussion, from 1.
  final int number;

  /// `comment` for normal posts; event posts use their own types, such as
  /// `discussionRenamed`, `discussionLocked`, `discussionStickied` or `discussionTagged`.
  final String contentType;
  final String? contentHtml;

  /// For a comment, its source text, sent only to readers who may edit it.
  /// For an event post, the event's data (e.g. the old and new title).
  final Object? content;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final bool isHidden;
  final String? discussionId;

  /// Known only when the request included the discussion.
  final String? discussionTitle;
  final FlarumUser? author;
  final bool canEdit;

  /// Delete for good; [canHide] is the soft delete.
  final bool canDelete;
  final bool canHide;

  /// Report it (flarum/flags).
  final bool canFlag;
  final bool canLike;
  final int likesCount;

  /// False while flarum/approval holds it for a moderator.
  final bool isApproved;
  final bool canApprove;

  /// fof/bookmarks: the reader bookmarked it.
  final bool bookmarked;

  /// How many later posts reply to it (flarum/mentions).
  final int mentionedByCount;

  /// The replies, when the request included `mentionedBy` (the posts pages
  /// do): who replied, and where. 2.0 sends at most a handful; the full
  /// number is [mentionedByCount].
  final List<FlarumPostReply> mentionedBy;
  final bool canSelectAsBestAnswer;

  bool get isComment => contentType == 'comment';
}

/// A post that replies to (mentions) another: enough to name its author and
/// open it. It can be in another discussion (a quote of the post elsewhere).
class FlarumPostReply {
  const FlarumPostReply({required this.id, this.number, this.discussionId, this.discussionTitle, this.author});

  factory FlarumPostReply.from(ResourceId ref, JsonApiDocument document) {
    final post = document.find(ref);
    final author = document.find(post?.toOne('user'));
    final discussion = document.find(post?.toOne('discussion'));
    return FlarumPostReply(
      id: ref.id,
      number: post?.attributes.integer('number'),
      discussionId: post?.toOne('discussion')?.id,
      discussionTitle: discussion?.attributes.string('title'),
      author: author == null ? null : FlarumUser.fromResource(author),
    );
  }

  final String id;
  final int? number;
  final String? discussionId;
  final String? discussionTitle;
  final FlarumUser? author;
}
