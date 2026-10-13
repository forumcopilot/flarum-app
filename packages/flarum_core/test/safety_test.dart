import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reporting posts and ignoring users (Milestone 4), replayed from the write fixtures: carol
/// reports bob's answer and ignores him (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      String pathId(String name) => (recorded(name)['request']['path'] as String).split('/').last;
      final bobId = pathId('write_ignore_user');
      final answerId = (recorded('write_flag_post')['request']['body']['data']['relationships']['post']['data']['id']) as String;
      final questionId = recorded('write_question_posts')['request']['query']['filter[discussion]'] as String;

      Future<FlarumApiException> refusal(Future<Object?> call) async {
        try {
          await call;
        } on FlarumApiException catch (e) {
          return e;
        }
        fail('Expected the forum to refuse');
      }

      test('reports a post with a reason; without one, the forum asks for details', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();
        await api.flagPost(answerId, reason: 'off_topic', detail: WriteSamples.flagDetail);
        expect((fixtures.requests.single.data as Map)['data']['attributes'], {
          'reason': 'off_topic',
          'reasonDetail': WriteSamples.flagDetail,
        });

        final e = await refusal(api.flagPost(answerId));
        expect(e.isValidationError, isTrue);
        expect(e.reasons.split('\n').first, 'Please provide some details for our moderators.');
      });

      test('ignores a user, but not themselves, and stops', () async {
        final api = FixtureForum(version).api();
        final ignored = await api.setIgnored(bobId, true);
        expect((ignored.username, ignored.ignored, ignored.canBeIgnored), ('bob', true, true));
        expect((await refusal(api.setIgnored(pathId('write_ignore_self'), true))).isForbidden, isTrue);
        expect((await api.setIgnored(bobId, false)).ignored, isFalse);
      });

      test('while the reader ignores bob, the forum lists him and his posts say so', () async {
        final api = FixtureForum(version, states: {'ignoring'}).api();
        expect((await api.forumInfo()).ignoredUsers?.map((u) => u.username), ['bob']);
        final posts = (await api.posts(questionId)).items;
        expect({for (final post in posts) post.author?.username: post.author?.ignored}, {'carol': false, 'bob': true});
        expect((await api.user(bobId)).ignored, isTrue);
      });

      test('a reader who ignores no one gets an empty list; a guest, none', () async {
        expect((await FixtureForum(version).api().forumInfo()).ignoredUsers, isEmpty);
        expect((await FixtureForum(version).api(signedIn: false).forumInfo()).ignoredUsers, isNull, reason: 'a guest');
      });
    });
  }
}
