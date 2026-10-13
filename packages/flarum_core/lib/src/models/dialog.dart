import '../attributes.dart';
import '../json_api.dart';
import 'user.dart';

/// A conversation in flarum/messages (2.0's direct messages): the people in it and its latest
/// message, as the reader sees it.
class FlarumDialog {
  const FlarumDialog({
    required this.id,
    this.title,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.lastMessageId,
    this.lastReadMessageId,
    this.users = const [],
    this.lastMessage,
  });

  factory FlarumDialog.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final last = document.find(resource.toOne('lastMessage'));
    return FlarumDialog(
      id: resource.id,
      title: a.nonEmptyString('title'),
      lastMessageAt: a.date('lastMessageAt'),
      unreadCount: a.integer('unreadCount') ?? 0,
      lastMessageId: a.string('lastMessageId'),
      lastReadMessageId: a.string('lastReadMessageId'),
      users: [for (final user in document.findAll(resource.toMany('users'))) FlarumUser.fromResource(user)],
      lastMessage: last == null ? null : FlarumDialogMessage.fromResource(last, document),
    );
  }

  final String id;

  /// The forum's name for it, as the reader sees it ("Messaging bob").
  final String? title;
  final DateTime? lastMessageAt;

  /// Messages the reader hasn't read.
  final int unreadCount;
  final String? lastMessageId;
  final String? lastReadMessageId;

  /// Everyone in it, the reader included, when the response included them.
  final List<FlarumUser> users;
  final FlarumDialogMessage? lastMessage;

  /// The people in it other than the reader.
  List<FlarumUser> others(String? readerId) => [for (final user in users) if (user.id != readerId) user];
}

/// A message in a [FlarumDialog].
class FlarumDialogMessage {
  const FlarumDialogMessage({
    required this.id,
    required this.number,
    this.contentHtml,
    this.createdAt,
    this.author,
    this.dialogId,
    this.canDelete = false,
  });

  factory FlarumDialogMessage.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    final author = document.find(resource.toOne('user'));
    return FlarumDialogMessage(
      id: resource.id,
      number: a.integer('number') ?? 0,
      contentHtml: a.string('contentHtml'),
      createdAt: a.date('createdAt'),
      author: author == null ? null : FlarumUser.fromResource(author),
      dialogId: resource.toOne('dialog')?.id,
      canDelete: a.boolean('canDelete') ?? false,
    );
  }

  final String id;

  /// Its place in the dialog, from 1.
  final int number;
  final String? contentHtml;
  final DateTime? createdAt;
  final FlarumUser? author;
  final String? dialogId;
  final bool canDelete;
}
