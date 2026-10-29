import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart' as pc;

/// The public key in a request's address, read back as the forum's OpenSSL reads it.
pc.RSAPublicKey _publicKey(String pem) {
  final der = base64.decode(pem.split('\n').where((line) => !line.startsWith('-----')).join());
  final info = ASN1Parser(Uint8List.fromList(der)).nextObject() as ASN1Sequence;
  final bits = info.elements[1] as ASN1BitString;
  final rsa = ASN1Parser(Uint8List.fromList(bits.stringValue)).nextObject() as ASN1Sequence;
  return pc.RSAPublicKey(
    (rsa.elements[0] as ASN1Integer).valueAsBigInteger,
    (rsa.elements[1] as ASN1Integer).valueAsBigInteger,
  );
}

/// What the extension sends back: the sign-in, encrypted to [key] with RSA-OAEP.
Uri _callback(pc.RSAPublicKey key, Map<String, dynamic> payload) {
  final oaep = pc.OAEPEncoding(pc.RSAEngine())..init(true, pc.PublicKeyParameter<pc.RSAPublicKey>(key));
  final encrypted = oaep.process(Uint8List.fromList(utf8.encode(jsonEncode(payload))));
  return Uri.parse('flapp://auth?payload=${Uri.encodeQueryComponent(base64.encode(encrypted))}');
}

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

  test("a request names the app and carries a one-time key and nonce; it reads the forum's answer", () async {
    final request = await FlappSignInRequest.create(info, app: 'flapp');

    expect(request.url.path, '/flapp/authorize');
    expect(request.url.queryParameters['app'], 'flapp');
    expect(request.url.queryParameters['nonce'], request.nonce);
    expect(request.nonce, matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));

    final key = _publicKey(request.url.queryParameters['publicKey']!);
    expect(key.modulus!.bitLength, 2048);

    final result = request.complete(_callback(key, {
      'v': 1,
      'token': 'remember-token',
      'userId': 2,
      'nonce': request.nonce,
      'cookiePrefix': 'flarum18',
    }));
    expect(result, (token: 'remember-token', userId: '2', cookiePrefix: 'flarum18'));

    // A payload for another request, or none.
    expect(() => request.complete(_callback(key, {'token': 't', 'userId': 2, 'nonce': 'another-request-nonce'})),
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
