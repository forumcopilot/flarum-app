import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// fof/drafts, replayed from the write fixtures: carol saves a reply, a new discussion and a
/// private one, lists them, changes the reply and deletes them (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      final bobId = (recorded('write_ignore_user')['request']['path'] as String).split('/').last;
      final questionId = (recorded('write_start_question')['body']['data'] as Map)['id'] as String;
      final v2 = version == FlarumVersion.v2;

      /// What a draft is for, where the version keeps it in the request: 2.0 in an attribute, 1.x in
      /// JSON:API's own relationships.
      Map<String, dynamic>? relationshipsSent(FixtureForum fixtures) {
        final data = (fixtures.requests.last.data as Map)['data'] as Map;
        return (v2 ? (data['attributes'] as Map)['relationships'] : data['relationships']) as Map<String, dynamic>?;
      }

      test('saves a reply, a new discussion and a private one, each with what it\'s for', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();

        final reply = await api.saveDraft(content: WriteSamples.draftReply, discussionId: questionId);
        expect((reply.isReply, reply.discussionId, reply.content, reply.title), (true, questionId, WriteSamples.draftReply, null));
        expect(relationshipsSent(fixtures), {
          'discussion': {
            'data': {'type': 'discussions', 'id': questionId},
          },
        });

        final discussion = await api.saveDraft(
            title: WriteSamples.draftTitle, content: WriteSamples.draftContent, tagIds: [fixtures.tagId('general')]);
        expect((discussion.isReply, discussion.isPrivateDiscussion, discussion.title), (false, false, WriteSamples.draftTitle));
        expect(discussion.tagIds, [fixtures.tagId('general')]);

        final private = await api.saveDraft(
            title: WriteSamples.draftPrivateTitle, content: WriteSamples.draftPrivateContent, recipientIds: [bobId]);
        expect(private.isPrivateDiscussion, isTrue);
        expect(private.recipientIds, [bobId]);
        // Besides the forum's own, read once for its version.
        expect(fixtures.requests.where((r) => r.path != '').map((r) => '${r.method} ${r.path}'), everyElement('POST /drafts'));
      });

      test('lists the reader\'s drafts, the latest first, and how many there are', () async {
        final fixtures = FixtureForum(version);
        final drafts = (await fixtures.api().drafts()).items;
        expect([for (final draft in drafts) draft.content],
            [WriteSamples.draftPrivateContent, WriteSamples.draftContent, WriteSamples.draftReply]);
        if (v2) expect(fixtures.requests.last.queryParameters['sort'], '-updatedAt');
        expect((await FixtureForum(version, states: {'drafts'}).api().forumInfo()).draftCount, 3);
      });

      test('a draft saved again changes; one posted or thrown away is deleted', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();
        final id = (recorded('write_draft_update')['request']['path'] as String).split('/').last;
        final changed = await api.saveDraft(id: id, content: WriteSamples.draftReplyEdited, discussionId: questionId);
        expect(fixtures.requests.last.method, 'PATCH');
        expect((changed.id, changed.content, changed.discussionId), (id, WriteSamples.draftReplyEdited, questionId));

        await api.deleteDraft(id);
        expect('${fixtures.requests.last.method} ${fixtures.requests.last.path}', 'DELETE /drafts/$id');
      });
    });
  }
}
