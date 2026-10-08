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
    this.author,
  });

  factory FlarumPost.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final author = document.find(resource.toOne('user'));
    return FlarumPost(
      id: resource.id,
      number: a.integer('number') ?? 0,
      contentType: a.string('contentType') ?? 'comment',
      contentHtml: a.string('contentHtml'),
      content: a['content'],
      createdAt: a.date('createdAt'),
      editedAt: a.date('editedAt'),
      isHidden: a.boolean('isHidden') ?? false,
      discussionId: resource.toOne('discussion')?.id,
      author: author == null ? null : FlarumUser.fromResource(author),
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
  final FlarumUser? author;

  bool get isComment => contentType == 'comment';
}
