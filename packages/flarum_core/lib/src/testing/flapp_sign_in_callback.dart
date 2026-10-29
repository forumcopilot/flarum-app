import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart' as pc;

/// What the Flapp extension sends the app back to after the member's Authorize on [authorizeUrl],
/// a [FlappSignInRequest]'s address: the sign-in, encrypted to the request's public key with
/// RSA-OAEP, as the forum's PHP encrypts it. [nonce] is the request's own unless given.
Uri flappSignInCallback(Uri authorizeUrl,
    {required String token, Object userId = 2, String cookiePrefix = 'flarum', String? nonce}) {
  final pem = authorizeUrl.queryParameters['publicKey']!;
  final der = base64.decode(pem.split('\n').where((line) => !line.startsWith('-----')).join());
  final info = ASN1Parser(Uint8List.fromList(der)).nextObject() as ASN1Sequence;
  final rsa = ASN1Parser((info.elements[1] as ASN1BitString).stringValue as Uint8List).nextObject() as ASN1Sequence;
  final key = pc.RSAPublicKey(
    (rsa.elements[0] as ASN1Integer).valueAsBigInteger,
    (rsa.elements[1] as ASN1Integer).valueAsBigInteger,
  );
  final payload = jsonEncode({
    'v': 1,
    'token': token,
    'userId': userId,
    'nonce': nonce ?? authorizeUrl.queryParameters['nonce'],
    'cookiePrefix': cookiePrefix,
  });
  final oaep = pc.OAEPEncoding(pc.RSAEngine())..init(true, pc.PublicKeyParameter<pc.RSAPublicKey>(key));
  final encrypted = oaep.process(Uint8List.fromList(utf8.encode(payload)));
  return Uri.parse('flapp://auth?payload=${Uri.encodeQueryComponent(base64.encode(encrypted))}');
}
