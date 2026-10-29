import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final info = FlappSignInInfo.fromAttributes({
    'flappSignIn': {'version': 1, 'authorizeUrl': 'https://forum.example/flapp/authorize'},
  })!;

  test('a forum running the Flapp extension announces its sign-in page; one without it, none', () {
    expect(info.authorizeUrl, Uri.parse('https://forum.example/flapp/authorize'));
    expect(info.version, 1);
    expect(FlappSignInInfo.fromAttributes({}), isNull);
    expect(FlappSignInInfo.fromAttributes({'flappSignIn': {'authorizeUrl': 'javascript:alert(1)'}}), isNull);
  });

  for (final version in FlarumVersion.values) {
    test('Flarum ${version.name}: the Flapp extension announces its sign-in page; a forum without it, none', () async {
      final signIn = (await FixtureForum(version, states: {'flapp'}).api().forumInfo()).flappSignIn!;
      expect(signIn.authorizeUrl.path, '/flapp/authorize');
      expect(signIn.version, 1);
      expect((await FixtureForum(version).api().forumInfo()).flappSignIn, isNull);
    });
  }

  test("a request names the app and carries a one-time key and nonce; it reads the forum's answer", () async {
    final request = await FlappSignInRequest.create(info, app: 'flapp');

    expect(request.url.path, '/flapp/authorize');
    expect(request.url.queryParameters['app'], 'flapp');
    expect(request.url.queryParameters['nonce'], request.nonce);
    expect(request.nonce, matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));

    expect(request.url.queryParameters['publicKey'], startsWith('-----BEGIN PUBLIC KEY-----\n'));

    final result = request.complete(flappSignInCallback(request.url, token: 'remember-token', cookiePrefix: 'flarum18'));
    expect(result, (token: 'remember-token', userId: '2', cookiePrefix: 'flarum18'));

    // A payload for another request, or none.
    expect(() => request.complete(flappSignInCallback(request.url, token: 't', nonce: 'another-request-nonce')),
        throwsA(isA<FlappSignInException>()));
    expect(() => request.complete(Uri.parse('flapp://auth?payload=bm90IGEga2V5')), throwsA(isA<FlappSignInException>()));
    expect(() => request.complete(Uri.parse('flapp://auth')), throwsA(isA<FlappSignInException>()));

    // Cancel on the forum's page.
    expect(request.complete(Uri.parse('flapp://auth?error=cancelled')), isNull);
  });

  test("reads a sign-in as the extension's PHP encrypts it", () {
    final sample = jsonDecode(File('test/fixtures/flapp_sign_in/php_payload.json').readAsStringSync()) as Map<String, dynamic>;
    BigInt hex(String key) => BigInt.parse(sample[key] as String, radix: 16);

    final request = FlappSignInRequest.forTesting(
      url: Uri.parse('https://forum.example/flapp/authorize'),
      nonce: sample['nonce'] as String,
      modulus: hex('modulus'),
      privateExponent: hex('privateExponent'),
      p: hex('p'),
      q: hex('q'),
    );

    expect(request.complete(Uri.parse(sample['callback'] as String)),
        (token: 'abcdefghijklmnopqrstuvwxyz0123456789ABCD', userId: '2', cookiePrefix: 'flarum'));
  });
}
