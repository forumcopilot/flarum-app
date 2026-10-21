import '../attributes.dart';
import '../json_api.dart';
import 'post.dart';
import 'user.dart';

/// A report of a post to the forum's moderators (flarum/flags), as the Flagged Posts list has it:
/// who reported it and why, with the post, its author and its discussion.
class FlarumFlag {
  const FlarumFlag({required this.id, this.type, this.reason, this.reasonDetail, this.createdAt, this.user, this.post});

  factory FlarumFlag.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final user = document.find(resource.toOne('user'));
    final post = document.find(resource.toOne('post'));
    return FlarumFlag(
      id: resource.id,
      type: a.nonEmptyString('type'),
      reason: a.nonEmptyString('reason'),
      reasonDetail: a.nonEmptyString('reasonDetail'),
      createdAt: a.date('createdAt'),
      user: user == null ? null : FlarumUser.fromResource(user),
      post: post == null ? null : FlarumPost.fromResource(post, document),
    );
  }

  final String id;

  /// `user` for a member's report; extensions add their own (an approval queue's, say).
  final String? type;

  /// `off_topic`, `inappropriate`, `spam`, or null for "Other" ([reasonDetail] says).
  final String? reason;
  final String? reasonDetail;
  final DateTime? createdAt;

  /// Who reported it.
  final FlarumUser? user;

  /// The post, with its author and discussion.
  final FlarumPost? post;
}
