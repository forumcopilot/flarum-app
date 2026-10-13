import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Private discussions (fof/byobu), replayed from the write fixtures: carol starts one with bob, and
/// he replies (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      final bobId = (recorded('write_ignore_user')['request']['path'] as String).split('/').last;
      final privateId = recorded('write_start_private')['body']['data']['id'] as String;

      Future<FlarumApiException> refusal(Future<Object?> call) async {
        try {
          await call;
        } on FlarumApiException catch (e) {
          return e;
        }
        fail('Expected the forum to refuse');
      }

      test('starts a private discussion with one other member, and not two', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();
        final started = await api.startPrivateDiscussion(WriteSamples.privateTitle, WriteSamples.privateContent, [bobId]);
        expect((started.title, started.isPrivate), (WriteSamples.privateTitle, true));
        expect(started.tags, isEmpty);
        expect({for (final user in started.recipients) user.username}, {'bob', 'carol'}, reason: 'the reader is one of them');
        expect(started.canEditRecipients, isFalse, reason: 'members may not change who\'s in it');

        final e = await refusal(api.startPrivateDiscussion(
            WriteSamples.privateTitle, WriteSamples.privateContent, [bobId, fixtures.userId('alice')]));
        expect(e.isForbidden, isTrue);
      });

      test('lists the reader\'s private discussions, with who each is with', () async {
        final fixtures = FixtureForum(version);
        final page = await fixtures.api().discussions(private: true);
        expect(page.items.single.id, privateId);
        expect({for (final user in page.items.single.recipients) user.username}, {'bob', 'carol'});
        final query = fixtures.requests.last.queryParameters;
        expect(version == FlarumVersion.v1 ? query['filter[q]'] : query['filter[private]'],
            version == FlarumVersion.v1 ? 'is:private' : '1');
      });

      test('reads who\'s in one; a member may not change it', () async {
        final api = FixtureForum(version).api();
        expect({for (final user in await api.recipients(privateId)) user.username}, {'bob', 'carol'});
        final carolId = recorded('write_private_set_recipients')['request']['body']['data']['relationships']
            ['recipientUsers']['data'][0]['id'] as String;
        expect((await refusal(api.setRecipients(privateId, [carolId]))).isForbidden, isTrue);
      });
    });
  }
}
