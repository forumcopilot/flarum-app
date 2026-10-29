import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flarum_core/testing.dart';

/// The handle tool/record_flapp_fixtures.dart registered.
const _handle = 'fixture-handle-0123456789abcdef';

/// The id both forums gave the recorded device; it changes each time the fixtures are recorded.
const _deviceId = '5';

const _installation = FlappInstallation(id: 'install-0123456789abcdef', secret: 'secret-0123456789abcdef0123456789abcdef');

void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
    FlarumPush.resetForTesting();
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}', () {
      test('a forum running the Flapp extension announces its relay; one without it, none', () async {
        final push = (await FixtureForum(version, states: {'flapp'}).api().forumInfo()).flappPush!;
        expect(push.relay, 'https://staging-push.flarumapp.com');
        expect(push.forumId, startsWith('f_'));
        expect(push.version, 1);
        expect((await FixtureForum(version).api().forumInfo()).flappPush, isNull);
      });

      test('registerFlappDevice registers the phone under the header token; deleteFlappDevice takes it away', () async {
        final forum = FixtureForum(version, states: {'flapp'});
        final api = forum.api();

        final id = await api.registerFlappDevice(handle: _handle, platform: 'android', app: 'flapp', locale: 'de');
        expect(id, _deviceId);
        await api.deleteFlappDevice(id);
        // Already gone: the forum's 404 counts as deleted.
        await api.deleteFlappDevice(id);

        final [register, delete, deleteAgain] = forum.requests;
        expect(register.method, 'POST');
        expect(register.path, '/flapp-push/devices');
        expect(register.headers['Authorization'], 'Token fixture-token');
        expect(register.data, {'handle': _handle, 'platform': 'android', 'app': 'flapp', 'locale': 'de'});
        expect([delete.method, delete.path], ['DELETE', '/flapp-push/devices/$_deviceId']);
        expect([deleteAgain.method, deleteAgain.path], ['DELETE', '/flapp-push/devices/$_deviceId']);
      });

      test('register tells the relay of the phone, asks it for a handle, and registers that with the forum', () async {
        final fixtures = FixtureForum(version, states: {'flapp'});
        final forum = fixtures.forum();
        final relay = _relay();

        final registration = await FlarumPush.register(forum);

        final push = (await forum.current()).flappPush!;
        expect(registration, (relay: push.relay, forumId: push.forumId, handle: _handle, deviceId: _deviceId));
        expect(await FlarumPush.forumUrlFor(push.forumId), forum.baseUrl);
        expect(await FlarumPush.store.read(forum.baseUrl), registration);
        final [installation, handle] = relay.requests;
        expect([installation.method, installation.uri.toString()], ['PUT', 'https://staging-push.flarumapp.com/v1/installation']);
        expect(installation.headers['Authorization'], 'Bearer ${_installation.id}:${_installation.secret}');
        expect(installation.data, {
          'device_token': 'fcm-token',
          'device_platform': 'android',
          'notifications_permitted': true,
          'app_version': '1.0.0+7',
          'locale': 'de',
        });
        expect([handle.method, handle.path, handle.data], ['POST', '/v1/handles', {'forumId': push.forumId}]);
        expect(fixtures.requests.where((r) => r.path == '/flapp-push/devices').single.data,
            {'handle': _handle, 'platform': 'android', 'app': 'flapp', 'locale': 'de'});

        // Once a run is enough.
        expect(await FlarumPush.register(forum), registration);
        expect(relay.requests, hasLength(2));
      });

      test('unregister deletes the device on the forum and the handle on the relay', () async {
        final fixtures = FixtureForum(version, states: {'flapp'});
        final forum = fixtures.forum();
        final relay = _relay(more: [(204, null)]);
        await FlarumPush.register(forum);

        await FlarumPush.unregister(forum);

        expect(fixtures.requests.last.method, 'DELETE');
        expect(fixtures.requests.last.path, '/flapp-push/devices/$_deviceId');
        expect([relay.requests.last.method, relay.requests.last.path], ['DELETE', '/v1/handles/$_handle']);
        expect(await FlarumPush.store.read(forum.baseUrl), isNull);
        expect(await FlarumPush.forumUrlFor((await forum.current()).flappPush!.forumId), isNull);
      });

      test('signing in registers the phone; signing out unregisters it before revoking the token', () async {
        final fixtures = FixtureForum(version, states: {'flapp'});
        final forum = fixtures.forum(signedIn: false);
        _relay(more: [(204, null)]);

        await forum.signIn('fixture-token');
        await pumpEventQueue();
        expect((await FlarumPush.store.read(forum.baseUrl))?.deviceId, _deviceId);

        await forum.signOut();

        final paths = [for (final r in fixtures.requests) '${r.method} ${r.path}'];
        expect(paths.indexOf('DELETE /flapp-push/devices/$_deviceId'), lessThan(paths.indexOf('GET /access-tokens')));
        expect(await FlarumPush.store.read(forum.baseUrl), isNull);
      });

      test('a forum without the extension is left alone', () async {
        final forum = FixtureForum(version).forum();
        final relay = _relay();

        expect(await FlarumPush.register(forum), isNull);
        expect(relay.requests, isEmpty);
      });
    });
  }

  group('FlarumPush', () {
    test('does nothing in an app without push', () async {
      final forum = FixtureForum(FlarumVersion.v2, states: {'flapp'}).forum();
      final relay = _relay();
      FlarumPush.device = null;

      expect(await FlarumPush.register(forum), isNull);
      expect(relay.requests, isEmpty);
    });

    test('waits for a push token', () async {
      final forum = FixtureForum(FlarumVersion.v2, states: {'flapp'}).forum();
      final relay = _relay();
      FlarumPush.device = _Device(token: null);

      expect(await FlarumPush.register(forum), isNull);
      expect(relay.requests, isEmpty);
    });

    test('a relay that is down leaves the forum unregistered, quietly', () async {
      final fixtures = FixtureForum(FlarumVersion.v2, states: {'flapp'});
      final forum = fixtures.forum();
      FlarumPush.device = _Device();
      final relay = ScriptedAdapter([(503, {'error': 'Service Unavailable'})]);
      FlarumPush.newDio = relay.dio;

      expect(await FlarumPush.registerQuietly(forum), isNull);
      expect(await FlarumPush.store.read(forum.baseUrl), isNull);
      expect(fixtures.requests.where((r) => r.path == '/flapp-push/devices'), isEmpty);
    });

    test('updateInstallations tells each relay once of a new token', () async {
      FlarumPush.device = _Device(token: 'new-token');
      final relay = ScriptedAdapter([(200, {'ok': true, 'handles': 2})]);
      FlarumPush.newDio = relay.dio;
      await FlarumPush.store.write('https://a.test', (relay: 'https://push.test', forumId: 'f_a', handle: _handle, deviceId: '1'));
      await FlarumPush.store.write(
          'https://b.test', (relay: 'https://push.test', forumId: 'f_b', handle: 'another-handle-0123456', deviceId: '4'));

      await FlarumPush.updateInstallations();

      final update = relay.requests.single;
      expect(update.uri.toString(), 'https://push.test/v1/installation');
      expect((update.data as Map)['device_token'], 'new-token');
    });
  });

  group('FlappRelayClient', () {
    test('reads the relay\'s refusal', () async {
      final relay = ScriptedAdapter([(403, {'error': 'Installation secret does not match'})]);
      final client = FlappRelayClient('https://push.test/', _installation, dio: relay.dio());

      await expectLater(
        client.handleFor('f_1'),
        throwsA(isA<FlappRelayException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Installation secret does not match')),
      );
      expect(relay.requests.single.uri.toString(), 'https://push.test/v1/handles');
    });

    test('a handle the relay no longer has counts as deleted; no token clears it', () async {
      final relay = ScriptedAdapter([(404, {'error': 'Not Found'}), (200, {'ok': true, 'handles': 0})]);
      final client = FlappRelayClient('https://push.test', _installation, dio: relay.dio());

      await client.deleteHandle(_handle);
      await client.updateInstallation(deviceToken: null, platform: 'ios', notificationsPermitted: false);

      expect(relay.requests.last.data, {'device_token': '', 'device_platform': 'ios', 'notifications_permitted': false});
    });
  });
}

/// Answers for the relay: the installation update and the handle, then [more].
ScriptedAdapter _relay({List<ScriptedReply> more = const []}) {
  FlarumPush.device ??= _Device();
  final relay = ScriptedAdapter([
    (200, {'ok': true, 'handles': 0}),
    (201, {'handle': _handle}),
    ...more,
  ]);
  FlarumPush.newDio = relay.dio;
  return relay;
}

class _Device implements FlarumPushDevice {
  _Device({String? token = 'fcm-token'}) : _token = token;

  final String? _token;

  @override
  String get platform => 'android';

  @override
  String get app => 'flapp';

  @override
  String? get appVersion => '1.0.0+7';

  @override
  String? get locale => 'de';

  @override
  Future<String?> token() async => _token;

  @override
  Future<bool> notificationsPermitted() async => true;

  @override
  Future<FlappInstallation> installation() async => _installation;
}
