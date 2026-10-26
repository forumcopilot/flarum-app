import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../flapp_relay.dart';
import '../flarum_exception.dart';
import 'flarum_forum.dart';

/// What an app with push gives flarum_core: Flapp, with Firebase. A build without push (flarum-app's
/// own) sets none, and nothing here runs.
abstract class FlarumPushDevice {
  /// `android` or `ios`.
  String get platform;

  /// The app, as forums record it: `flapp`.
  String get app;

  String? get appVersion;

  /// The phone's language, such as `de` or `pt-BR`.
  String? get locale;

  /// The phone's push token, or null while it has none.
  Future<String?> token();

  /// Whether the system lets the app show notifications.
  Future<bool> notificationsPermitted();

  /// The phone's identity on the relays, made once and kept.
  Future<FlappInstallation> installation();
}

/// Where this phone gets a forum's pushes: the relay, the handle it gave the phone for the forum,
/// and the device the forum keeps for the reader.
typedef FlappRegistration = ({String relay, String handle, String deviceId});

/// Push through the Flapp extension, per forum: a forum whose `GET /api` announces `flappPush`
/// gets the phone registered when the reader signs in, and unregistered when they sign out. A
/// forum without the extension is left alone; the phone's own checks and the doorbell cover it.
abstract final class FlarumPush {
  /// Set by a host with push before the first sign-in.
  static FlarumPushDevice? device;

  /// Where registrations are kept, so sign-out can undo them.
  static FlappRegistrationStore store = SecureFlappRegistrationStore();

  /// The relay's HTTP client; tests answer for the relay through it.
  static Dio Function() newDio = Dio.new;

  /// The forums registered in this run: once a run is enough, as the forum and relay both keep
  /// a registration and answer the same handle and device for the same phone.
  static final _registeredThisRun = <String>{};

  /// Registers the phone for the signed-in reader's pushes from [forum], if the host has push, the
  /// phone has a token and the forum runs the extension. Returns the registration, or null when
  /// there is none to make. Failures are left to the caller; [registerQuietly] swallows them.
  static Future<FlappRegistration?> register(FlarumForum forum) async {
    final device = FlarumPush.device;
    if (device == null || !forum.isSignedIn) return null;
    if (_registeredThisRun.contains(forum.baseUrl)) return store.read(forum.baseUrl);

    final push = (await forum.current()).flappPush;
    if (push == null) {
      // Disconnected or uninstalled since: nothing to push through.
      await store.delete(forum.baseUrl);
      return null;
    }
    final token = await device.token();
    if (token == null) return null;

    final relay = FlappRelayClient(push.relay, await device.installation(), dio: newDio());
    await relay.updateInstallation(
      deviceToken: token,
      platform: device.platform,
      notificationsPermitted: await device.notificationsPermitted(),
      appVersion: device.appVersion,
      locale: device.locale,
    );
    final handle = await relay.handleFor(push.forumId);
    final deviceId = await forum.api.registerFlappDevice(
      handle: handle,
      platform: device.platform,
      app: device.app,
      locale: device.locale,
    );

    final registration = (relay: push.relay, handle: handle, deviceId: deviceId);
    await store.write(forum.baseUrl, registration);
    _registeredThisRun.add(forum.baseUrl);
    return registration;
  }

  /// [register], with a failure (no network, a relay that's down) leaving the forum unregistered
  /// until the next sign-in or launch rather than failing the caller.
  static Future<FlappRegistration?> registerQuietly(FlarumForum forum) async {
    try {
      return await register(forum);
    } on Object catch (e) {
      if (e is! FlarumApiException && e is! FlappRelayException && e is! DioException && e is! StateError) rethrow;
      debugPrint('Flapp push: not registered with ${forum.baseUrl}: $e');
      return null;
    }
  }

  /// Undoes [forum]'s registration, while the reader's token still works: the forum deletes the
  /// device and the relay the handle. Failures are ignored: signing out revokes the token, which
  /// takes the device with it on the forum, and a handle with no device reaches nobody.
  static Future<void> unregister(FlarumForum forum) async {
    final device = FlarumPush.device;
    if (device == null) return;
    _registeredThisRun.remove(forum.baseUrl);
    final saved = await store.read(forum.baseUrl);
    if (saved == null) return;
    await store.delete(forum.baseUrl);
    try {
      if (forum.isSignedIn) await forum.api.deleteFlappDevice(saved.deviceId);
    } on Object catch (e) {
      debugPrint('Flapp push: device not deleted on ${forum.baseUrl}: $e');
    }
    try {
      await FlappRelayClient(saved.relay, await device.installation(), dio: newDio()).deleteHandle(saved.handle);
    } on Object catch (e) {
      debugPrint('Flapp push: handle not deleted on ${saved.relay}: $e');
    }
  }

  /// Tells every relay the phone has handles on that its push token or notification permission
  /// changed. One call per relay covers all of its forums.
  static Future<void> updateInstallations() async {
    final device = FlarumPush.device;
    if (device == null) return;
    final relays = {for (final registration in (await store.all()).values) registration.relay};
    if (relays.isEmpty) return;
    final token = await device.token();
    final permitted = await device.notificationsPermitted();
    final installation = await device.installation();
    for (final relay in relays) {
      try {
        await FlappRelayClient(relay, installation, dio: newDio()).updateInstallation(
          deviceToken: token,
          platform: device.platform,
          notificationsPermitted: permitted,
          appVersion: device.appVersion,
          locale: device.locale,
        );
      } on FlappRelayException catch (e) {
        debugPrint('Flapp push: $relay not told of the new token: $e');
      }
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    device = null;
    store = FlappRegistrationStore.memory();
    newDio = Dio.new;
    _registeredThisRun.clear();
  }
}

/// Where [FlarumPush] keeps each forum's registration.
abstract class FlappRegistrationStore {
  static FlappRegistrationStore memory() => _MemoryFlappRegistrationStore();

  Future<FlappRegistration?> read(String forumUrl);
  Future<void> write(String forumUrl, FlappRegistration registration);
  Future<void> delete(String forumUrl);

  /// Every forum's registration, by the forum's address.
  Future<Map<String, FlappRegistration>> all();
}

/// In the Keychain / Keystore, beside the forum's sign-in.
class SecureFlappRegistrationStore implements FlappRegistrationStore {
  SecureFlappRegistrationStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _prefix = 'flapp_push:';

  @override
  Future<FlappRegistration?> read(String forumUrl) async => _decode(await _storage.read(key: '$_prefix$forumUrl'));

  @override
  Future<void> write(String forumUrl, FlappRegistration registration) => _storage.write(
        key: '$_prefix$forumUrl',
        value: jsonEncode({'relay': registration.relay, 'handle': registration.handle, 'deviceId': registration.deviceId}),
      );

  @override
  Future<void> delete(String forumUrl) => _storage.delete(key: '$_prefix$forumUrl');

  @override
  Future<Map<String, FlappRegistration>> all() async => {
        for (final MapEntry(:key, :value) in (await _storage.readAll()).entries)
          if (key.startsWith(_prefix))
            if (_decode(value) case final registration?) key.substring(_prefix.length): registration,
      };

  static FlappRegistration? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (relay: json['relay'] as String, handle: json['handle'] as String, deviceId: json['deviceId'] as String);
    } on Object {
      return null;
    }
  }
}

class _MemoryFlappRegistrationStore implements FlappRegistrationStore {
  final _entries = <String, FlappRegistration>{};

  @override
  Future<FlappRegistration?> read(String forumUrl) async => _entries[forumUrl];

  @override
  Future<void> write(String forumUrl, FlappRegistration registration) async => _entries[forumUrl] = registration;

  @override
  Future<void> delete(String forumUrl) async => _entries.remove(forumUrl);

  @override
  Future<Map<String, FlappRegistration>> all() async => Map.of(_entries);
}
