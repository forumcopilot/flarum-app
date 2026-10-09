import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A forum's sign-in: the API token (Flarum's long-lived remember token) and
/// the forum's cookie prefix, which sign-out needs.
typedef FlarumCredentials = ({String token, String cookiePrefix});

/// Where each forum's sign-in is kept between launches, keyed by the forum's
/// address. [instance] is the Keychain / Keystore; tests swap in [memory].
abstract class FlarumTokenStore {
  static FlarumTokenStore instance = SecureFlarumTokenStore();

  /// A store that forgets everything when the process ends, for tests.
  static FlarumTokenStore memory() => _MemoryFlarumTokenStore();

  Future<FlarumCredentials?> read(String forumUrl);
  Future<void> write(String forumUrl, FlarumCredentials credentials);
  Future<void> delete(String forumUrl);
}

class SecureFlarumTokenStore implements FlarumTokenStore {
  SecureFlarumTokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _key(String forumUrl) => 'flarum_session:$forumUrl';

  @override
  Future<FlarumCredentials?> read(String forumUrl) async {
    final raw = await _storage.read(key: _key(forumUrl));
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (token: json['token'] as String, cookiePrefix: json['cookiePrefix'] as String? ?? 'flarum');
  }

  @override
  Future<void> write(String forumUrl, FlarumCredentials credentials) => _storage.write(
        key: _key(forumUrl),
        value: jsonEncode({'token': credentials.token, 'cookiePrefix': credentials.cookiePrefix}),
      );

  @override
  Future<void> delete(String forumUrl) => _storage.delete(key: _key(forumUrl));
}

class _MemoryFlarumTokenStore implements FlarumTokenStore {
  final _entries = <String, FlarumCredentials>{};

  @override
  Future<FlarumCredentials?> read(String forumUrl) async => _entries[forumUrl];

  @override
  Future<void> write(String forumUrl, FlarumCredentials credentials) async => _entries[forumUrl] = credentials;

  @override
  Future<void> delete(String forumUrl) async => _entries.remove(forumUrl);
}
