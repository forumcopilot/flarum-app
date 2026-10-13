import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// flarum/messages, 2.0's direct messages, replayed from the write fixtures: carol writes to bob
/// and he answers (tool/record_write_fixtures.dart). 1.x has no such extension.
void main() {
  Map<String, dynamic> recorded(String name) =>
      jsonDecode(File('test/fixtures/v2/$name.json').readAsStringSync()) as Map<String, dynamic>;
  final bobId = (recorded('write_ignore_user')['request']['path'] as String).split('/').last;
  final dialogId = recorded('write_message_reply')['request']['body']['data']['relationships']['dialog']['data']['id'] as String;

  test('a first message to someone starts a dialog; a reply goes into it', () async {
    final fixtures = FixtureForum(FlarumVersion.v2);
    final api = fixtures.api();
    final sent = await api.sendMessage(WriteSamples.message, userIds: [bobId]);
    expect((sent.number, sent.contentHtml, sent.dialogId), (1, '<p>${WriteSamples.message}</p>', dialogId));
    expect((fixtures.requests.last.data as Map)['data']['attributes']['users'], [
      {'id': bobId},
    ]);

    final reply = await api.sendMessage(WriteSamples.messageReply, dialogId: dialogId);
    expect((reply.number, reply.dialogId), (2, dialogId));
  });

  test('lists the reader\'s dialogs with their people and last message, and reads one', () async {
    final api = FixtureForum(FlarumVersion.v2).api();
    final dialog = (await api.dialogs()).items.single;
    expect((dialog.id, dialog.unreadCount), (dialogId, 1));
    expect([for (final user in dialog.users) user.username]..sort(), ['bob', 'carol']);
    expect([for (final user in dialog.others(bobId)) user.username], ['carol']);
    expect(dialog.lastMessage?.contentHtml, '<p>${WriteSamples.messageReply}</p>');

    final messages = (await api.dialogMessages(dialogId)).items;
    expect([for (final m in messages) m.author?.username], ['bob', 'carol'], reason: 'the newest first');
    expect((await api.dialog(dialogId)).users, hasLength(2));
    await api.markDialogRead(dialogId, messages.first.id);
  });

  test('the reader\'s count of dialogs with something unread', () async {
    expect((await FixtureForum(FlarumVersion.v2, states: {'messages'}).api().forumInfo()).unreadDialogCount, 1);
    expect((await FixtureForum(FlarumVersion.v1).api().forumInfo()).unreadDialogCount, isNull, reason: 'no flarum/messages');
  });
}
