import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// A forum that moved to a new address (flarum20.betterdiscourse.app to flarumapp.com/flarum, 14
/// Nov 2026): what the phone keeps for it goes along.
void main() {
  const from = 'https://old.test';
  const to = 'https://new.test/forum';
  const registration = (relay: 'https://relay.test', forumId: 'f_1', handle: 'h_1', deviceId: '7');

  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
    FlarumPush.resetForTesting();
  });

  test('the sign-in and the push registration move to the new address', () async {
    await FlarumTokenStore.instance.write(from, (token: 't0k3n', cookiePrefix: 'flarum'));
    await FlarumPush.store.write(from, registration);
    final old = FlarumForum.forUrl(from);

    await FlarumForum.move('$from/', to);

    expect(await FlarumTokenStore.instance.read(to), (token: 't0k3n', cookiePrefix: 'flarum'));
    expect(await FlarumTokenStore.instance.read(from), isNull);
    expect(await FlarumPush.store.read(to), registration);
    expect(await FlarumPush.store.read(from), isNull);
    // A push for the forum now names its new address.
    expect(await FlarumPush.forumUrlFor('f_1'), to);
    // The old address is a fresh forum, signed out.
    expect(FlarumForum.forUrl(from), isNot(same(old)));
    await FlarumForum.forUrl(from).restoreSession();
    expect(FlarumForum.forUrl(from).isSignedIn, isFalse);
    await FlarumForum.forUrl(to).restoreSession();
    expect(FlarumForum.forUrl(to).api.client.token, 't0k3n');
  });

  test('what the new address already has is kept, and the old copy dropped', () async {
    await FlarumTokenStore.instance.write(from, (token: 'old', cookiePrefix: 'flarum'));
    await FlarumTokenStore.instance.write(to, (token: 'new', cookiePrefix: 'flarum'));
    await FlarumPush.store.write(from, registration);
    await FlarumPush.store.write(to, (relay: 'https://relay.test', forumId: 'f_1', handle: 'h_2', deviceId: '8'));

    await FlarumForum.move(from, to);

    expect((await FlarumTokenStore.instance.read(to))?.token, 'new');
    expect(await FlarumTokenStore.instance.read(from), isNull);
    expect((await FlarumPush.store.read(to))?.handle, 'h_2');
    expect(await FlarumPush.store.all(), hasLength(1));
  });

  test('a forum with nothing kept, or moved to where it is, is left alone', () async {
    await FlarumForum.move(from, to);
    expect(await FlarumTokenStore.instance.read(to), isNull);

    await FlarumTokenStore.instance.write(from, (token: 't', cookiePrefix: 'flarum'));
    await FlarumForum.move(from, '$from/');
    expect(await FlarumTokenStore.instance.read(from), isNotNull);
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}', () {
      test('recheckSession keeps a sign-in the forum accepts at its new address', () async {
        FixtureForum(version).forum(url: to, signedIn: false);
        await FlarumTokenStore.instance.write(to, (token: 'fixture-token', cookiePrefix: 'flarum'));

        await FlarumForum.forUrl(to).recheckSession();

        expect(FlarumForum.forUrl(to).isSignedIn, isTrue);
        expect(FlarumForum.forUrl(to).info?.actor, isNotNull);
        expect(await FlarumTokenStore.instance.read(to), isNotNull);
      });

      test('recheckSession signs out where the forum reads the token as a guest\'s', () async {
        final fixtures = FixtureForum(version);
        fixtures.replies['GET '] = _guestForum(version);
        fixtures.forum(url: to, signedIn: false);
        await FlarumTokenStore.instance.write(to, (token: 'unknown-here', cookiePrefix: 'flarum'));

        await FlarumForum.forUrl(to).recheckSession();

        expect(FlarumForum.forUrl(to).isSignedIn, isFalse);
        expect(await FlarumTokenStore.instance.read(to), isNull);
      });

      test('recheckSession changes nothing while the forum doesn\'t answer', () async {
        FixtureForum(version)
          ..offline = true
          ..forum(url: to, signedIn: false);
        await FlarumTokenStore.instance.write(to, (token: 'fixture-token', cookiePrefix: 'flarum'));

        await FlarumForum.forUrl(to).recheckSession();

        expect(FlarumForum.forUrl(to).isSignedIn, isTrue);
        expect(await FlarumTokenStore.instance.read(to), isNotNull);
      });
    });
  }
}

/// `GET /api` as a guest reads it, as recorded.
Object _guestForum(FlarumVersion version) =>
    (jsonDecode(File('test/fixtures/${version.name}/forum_guest.json').readAsStringSync()) as Map)['body'] as Object;
