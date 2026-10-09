@Tags(['live'])
library;

import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:test/test.dart';

/// Checks the client against running test forums seeded with alice, bob and
/// carol. Skipped by default; run with
///
///   FLARUM_V1_URL=http://127.0.0.1:8081 FLARUM_V2_URL=http://127.0.0.1:8082 \
///   FLARUM_TEST_PASSWORD=… dart test --run-skipped -t live
void main() {
  final password = Platform.environment['FLARUM_TEST_PASSWORD'];
  final forums = {
    FlarumVersion.v1: Platform.environment['FLARUM_V1_URL'],
    FlarumVersion.v2: Platform.environment['FLARUM_V2_URL'],
  };

  for (final MapEntry(key: version, value: url) in forums.entries) {
    group('live ${version.name}', () {
      late FlarumApi api;

      setUpAll(() async {
        api = FlarumApi(FlarumClient(url!));
        await api.logIn('alice', password!);
      });

      // Each run signs alice in afresh; revoke the token so her list doesn't grow.
      tearDownAll(() => api.logOut());

      test('detects the version and the reader', () async {
        final info = await api.forumInfo();
        expect(info.version, version);
        expect(info.actor?.username, 'alice');
      });

      test('pages through the long discussion and finds a post by number', () async {
        final long = (await api.discussions()).items.firstWhere((d) => d.title == 'Long thread for paging tests');
        final first = await api.posts(long.id, limit: 50);
        final second = await api.posts(long.id, offset: first.nextOffset!, limit: 50);
        expect(first.items.length + second.items.length, 60);
        expect((await api.postsNear(long.id, 30, limit: 5)).items.map((p) => p.number), contains(30));
      });

      test('searches within a tag', () async {
        final page = await api.discussions(query: 'thread', tagSlug: 'support');
        expect(page.items.map((d) => d.title), ['App crashes when opening a long thread']);
      });

      test('lists notifications', () async {
        expect((await api.notifications()).items, isNotEmpty);
      });

      test('logOut revokes the token on the forum', () async {
        final carol = FlarumApi(FlarumClient(url!));
        final session = await carol.logIn('carol', password!);
        expect(await carol.logOut(), isTrue);

        final stale = FlarumApi(FlarumClient(url, token: session.token));
        await expectLater(
          stale.notifications(),
          throwsA(isA<FlarumApiException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)),
        );
      });
    }, skip: url == null || password == null ? 'set FLARUM_${version.name.toUpperCase()}_URL and FLARUM_TEST_PASSWORD' : false);
  }
}
