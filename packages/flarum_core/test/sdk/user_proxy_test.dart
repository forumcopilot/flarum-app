import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flarum_core/testing.dart';
import 'site.dart';

void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version));

      test('a web-view sign-in is checked with the forum, kept, and marks the site signed in', () async {
        final forum = fixtures.forum(signedIn: false);
        final site = testSite();

        final result = await FlarumUserProxy.completeSignIn(site, 'fixture-token', cookiePrefix: 'flarum');

        expect(result.result, isTrue);
        expect(result.user?.username, 'alice');
        expect(result.canUploadAttachment, isTrue);
        expect(site.isLoggedIn, isTrue);
        expect(site.currentUserId, fixtures.userId('alice'));
        expect(forum.isSignedIn, isTrue);
        expect(await FlarumTokenStore.instance.read(FixtureForum.baseUrl), (token: 'fixture-token', cookiePrefix: 'flarum'));
      });

      test('the next launch picks the sign-in up again', () async {
        await FlarumTokenStore.instance.write(FixtureForum.baseUrl, (token: 'fixture-token', cookiePrefix: 'myforum'));
        final forum = fixtures.forum(signedIn: false);
        await forum.restoreSession();
        expect(forum.api.client.token, 'fixture-token');
        expect(forum.api.client.cookiePrefix, 'myforum');
      });

      test('signing out revokes the token, forgets it and reads the forum as a guest', () async {
        await FlarumTokenStore.instance.write(FixtureForum.baseUrl, (token: 'fixture-token', cookiePrefix: 'flarum'));
        fixtures.forum();
        final site = testSite();
        await FlarumUserProxy.completeSignIn(site, 'fixture-token');

        await FlarumUserProxy(site).logoutUserAsync();

        expect(site.isLoggedIn, isFalse);
        expect(await FlarumTokenStore.instance.read(FixtureForum.baseUrl), isNull);
        final calls = fixtures.requests.map((r) => '${r.method} ${r.path}').toList();
        expect(calls, contains('GET /access-tokens'));
        expect(calls.where((c) => c.startsWith('DELETE /access-tokens/')), hasLength(1));
        expect(FlarumForum.of(site).info?.actor, isNull);
      });

      test('a user by id or username, and their profile', () async {
        final proxy = FlarumUserProxy(testSite());
        fixtures.forum();
        final byId = await proxy.getUserInfoAsync(null, fixtures.userId('bob'));
        final byName = await proxy.getUserInfoAsync('bob', null);
        for (final info in [byId, byName]) {
          expect(info.result, isTrue);
          expect(info.username, 'bob');
          expect(info.registrationTime, isNotNull);
          expect(info.postCount, greaterThan(0));
        }
      });

      test('what a user started and wrote', () async {
        fixtures.forum();
        final proxy = FlarumUserProxy(testSite());
        final topics = await proxy.getUserTopicAsync('bob', null);
        expect(topics.list.map((t) => t.topicTitle), containsAll(['Feature request: dark mode', 'Long thread for paging tests']));

        final replies = await proxy.getUserReplyPostAsync(0, 19, null, 'bob', null);
        expect(replies.result, isTrue);
        expect(replies.list, hasLength(20));
        expect(replies.list.first.topicTitle, isNotEmpty, reason: 'the discussion comes included');
        expect(replies.total, 21, reason: 'another page exists');
      });

      test('searching users', () async {
        fixtures.forum();
        final result = await FlarumUserProxy(testSite()).searchUserAsync('bo', 1, 20);
        expect(result.list.single.username, 'bob');
        expect(result.hasMore, isFalse);
      });
    });
  }

  group('signing in with a password', () {
    test('a CAPTCHA on the token route sends the reader to the web sign-in', () async {
      final adapter = ScriptedAdapter([(422, errors('422', 'validation_error', pointer: '/data/attributes/turnstileToken'))]);
      FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio());
      final result = await FlarumUserProxy(testSite()).loginAsync('alice', 'secret', false, null);
      expect(result.result, isFalse);
      expect(result.resultText, contains('CAPTCHA'));
    });

    test('a wrong password says so', () async {
      final adapter = ScriptedAdapter([(401, errors('401', 'not_authenticated'))]);
      FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio());
      final result = await FlarumUserProxy(testSite()).loginAsync('alice', 'wrong', false, null);
      expect(result.resultText, 'Wrong username, email or password');
    });

    test('a token the forum doesn\'t accept is not kept', () async {
      final adapter = ScriptedAdapter([
        (200, {'data': {'type': 'forums', 'id': '1', 'attributes': {'title': 'x'}}}),
      ]);
      final forum = FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio());
      await expectLater(forum.signIn('stale'), throwsStateError);
      expect(forum.isSignedIn, isFalse);
      expect(await FlarumTokenStore.instance.read(FixtureForum.baseUrl), isNull);
    });
  });
}
