import '../attributes.dart';
import '../json_api.dart';

/// A draft saved with fof/drafts: a reply to a discussion, a new discussion with its tags, or a
/// private discussion (fof/byobu) with its people. The forum keeps what it's for as a JSON:API
/// `relationships` object in an attribute of that name.
class FlarumDraft {
  const FlarumDraft({
    required this.id,
    this.title,
    this.content = '',
    this.discussionId,
    this.tagIds = const [],
    this.recipientIds = const [],
    this.updatedAt,
  });

  factory FlarumDraft.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    // An object, or what an empty one was stored as: [], "" or null.
    final relationships = switch (a['relationships']) {
      final Map<String, dynamic> map => map,
      _ => const <String, dynamic>{},
    };
    List<String> ids(String key) => switch (relationships[key]) {
          {'data': final List<dynamic> data} => [
              for (final item in data)
                if (item is Map && item['id'] != null) '${item['id']}',
            ],
          _ => const [],
        };
    return FlarumDraft(
      id: resource.id,
      title: a.nonEmptyString('title'),
      content: a.string('content') ?? '',
      discussionId: switch (relationships['discussion']) {
        {'data': {'id': final Object id}} => '$id',
        _ => null,
      },
      tagIds: ids('tags'),
      recipientIds: ids('recipientUsers'),
      updatedAt: a.date('updatedAt'),
    );
  }

  final String id;

  /// A new discussion's title; null for a reply.
  final String? title;
  final String content;

  /// The discussion a reply is to.
  final String? discussionId;
  final List<String> tagIds;

  /// The people a private discussion is with (fof/byobu), the writer aside.
  final List<String> recipientIds;
  final DateTime? updatedAt;

  bool get isReply => discussionId != null;
  bool get isPrivateDiscussion => !isReply && recipientIds.isNotEmpty;

  /// What it's for, as the forum stores it: the discussion replied to, a new discussion's tags, or
  /// a private one's people. Empty for a new discussion without tags.
  static Map<String, Object> relationshipsFor({String? discussionId, List<String> tagIds = const [], List<String> recipientIds = const []}) => {
        if (discussionId != null)
          'discussion': {
            'data': {'type': 'discussions', 'id': discussionId},
          },
        if (discussionId == null && tagIds.isNotEmpty)
          'tags': {
            'data': [
              for (final id in tagIds) {'type': 'tags', 'id': id},
            ],
          },
        if (discussionId == null && recipientIds.isNotEmpty)
          'recipientUsers': {
            'data': [
              for (final id in recipientIds) {'type': 'users', 'id': id},
            ],
          },
      };
}
