import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart' as pc;

import 'models/flapp_sign_in.dart';

/// The sign-in a forum hands the app through its Flapp page: a remember token (as "Remember me"
/// makes, and the API takes as a header token), its reader, and the forum's cookie prefix.
typedef FlappSignInResult = ({String token, String userId, String cookiePrefix});

/// One sign-in through a forum's Flapp page (`flappSignIn`), in the phone's browser: the page's
/// address, carrying the app's name, a one-time RSA public key and a nonce, and the key that
/// reads what the forum sends back to the app's redirect. The forum encrypts the sign-in to that
/// key (RSA-OAEP), so only this request can read it, whoever catches the redirect.
///
/// The key handling is discourse_core's for Discourse's User API Keys (DiscourseAuthManager),
/// copied rather than shared, as flarum_ui copies its screens.
class FlappSignInRequest {
  FlappSignInRequest._(this.url, this.nonce, this._privateKey);

  /// A request whose key was made elsewhere (its private half as RSA numbers), for tests.
  FlappSignInRequest.forTesting({
    required this.url,
    required this.nonce,
    required BigInt modulus,
    required BigInt privateExponent,
    required BigInt p,
    required BigInt q,
  }) : _privateKey = pc.RSAPrivateKey(modulus, privateExponent, p, q);

  /// A new request for [app], as the extension lists it (`flapp`). Making the key takes a second
  /// or so, so it is made away from the UI.
  static Future<FlappSignInRequest> create(FlappSignInInfo info, {required String app}) async {
    final pair = await Isolate.run(_generateKeyPair);
    final nonce = _randomToken(24);
    final url = info.authorizeUrl.replace(queryParameters: {
      ...info.authorizeUrl.queryParameters,
      'app': app,
      'publicKey': _publicKeyToPem(pair.publicKey),
      'nonce': nonce,
    });
    return FlappSignInRequest._(url, nonce, pair.privateKey);
  }

  /// The page to open.
  final Uri url;

  final String nonce;

  final pc.RSAPrivateKey _privateKey;

  /// The sign-in in [callback], the app's redirect as the page sent it, or null when the member
  /// cancelled there. Throws [FlappSignInException] for anything else, such as a payload made for
  /// another request.
  FlappSignInResult? complete(Uri callback) {
    final params = callback.queryParameters;
    if (params['error'] != null) return null;
    final payload = params['payload'];
    if (payload == null) throw const FlappSignInException('no payload');

    final Map<String, dynamic> json;
    try {
      final oaep = pc.OAEPEncoding(pc.RSAEngine())..init(false, pc.PrivateKeyParameter<pc.RSAPrivateKey>(_privateKey));
      final decoded = jsonDecode(utf8.decode(oaep.process(base64.decode(payload))));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      json = decoded;
    } catch (_) {
      throw const FlappSignInException('a payload that is not for this request');
    }
    if (json['nonce'] != nonce) throw const FlappSignInException('a payload for another request');
    final token = json['token'];
    final userId = json['userId'];
    if (token is! String || token.isEmpty || userId == null) throw const FlappSignInException('no token');
    final cookiePrefix = json['cookiePrefix'];
    return (
      token: token,
      userId: '$userId',
      cookiePrefix: cookiePrefix is String && cookiePrefix.isNotEmpty ? cookiePrefix : 'flarum',
    );
  }

  static pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey> _generateKeyPair() {
    final random = pc.FortunaRandom()..seed(pc.KeyParameter(_randomBytes(32)));
    final generator = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64), random));
    final pair = generator.generateKeyPair();
    return pc.AsymmetricKeyPair(pair.publicKey as pc.RSAPublicKey, pair.privateKey as pc.RSAPrivateKey);
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList([for (var i = 0; i < length; i++) random.nextInt(256)]);
  }

  /// Unpadded base64url, which the extension's nonce rule accepts.
  static String _randomToken(int bytes) => base64Url.encode(_randomBytes(bytes)).replaceAll('=', '');

  /// X.509 SubjectPublicKeyInfo, PEM, as OpenSSL reads it.
  static String _publicKeyToPem(pc.RSAPublicKey key) {
    final algorithm = ASN1Sequence()
      // rsaEncryption, 1.2.840.113549.1.1.1, and its NULL parameters.
      ..add(ASN1Object.fromBytes(Uint8List.fromList(const [0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01])))
      ..add(ASN1Object.fromBytes(Uint8List.fromList(const [0x05, 0x00])));
    final rsaKey = ASN1Sequence()
      ..add(ASN1Integer(key.modulus!))
      ..add(ASN1Integer(key.exponent!));
    final info = ASN1Sequence()
      ..add(algorithm)
      ..add(ASN1BitString(Uint8List.fromList(rsaKey.encodedBytes)));
    final data = base64.encode(info.encodedBytes);
    final lines = [for (var i = 0; i < data.length; i += 64) data.substring(i, min(i + 64, data.length))];
    return '-----BEGIN PUBLIC KEY-----\n${lines.join('\n')}\n-----END PUBLIC KEY-----';
  }
}

/// A sign-in through a forum's Flapp page that came back unusable.
class FlappSignInException implements Exception {
  const FlappSignInException(this.reason);

  final String reason;

  @override
  String toString() => 'FlappSignInException: $reason';
}
