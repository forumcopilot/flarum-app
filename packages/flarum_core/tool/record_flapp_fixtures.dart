// Records the calls the app makes to a forum running the Flapp extension (forumcopilot/flarum-flapp)
// into test/fixtures/v1 or v2 (flapp_*.json): the forum announcing `flappPush`, and bob registering
// a phone for pushes and deleting it again. The forum must be connected to a relay.
//
//   FLARUM_TEST_PASSWORD=… dart run tool/record_flapp_fixtures.dart http://127.0.0.1:8081
//
// The forum doesn't check a handle with the relay, so the recorder registers a made-up one; the
// device is deleted before the recorder signs bob out.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flarum_core/api.dart';

import 'fixture_recorder.dart';

/// The handle the fixtures register, which the tests send.
const fixtureHandle = 'fixture-handle-0123456789abcdef';

Future<void> main(List<String> args) async {
  final password = Platform.environment['FLARUM_TEST_PASSWORD'];
  if (args.length != 1 || password == null) {
    stderr.writeln('usage: FLARUM_TEST_PASSWORD=… dart run tool/record_flapp_fixtures.dart <forum url>');
    exit(64);
  }
  final recorder = FixtureRecorder();
  final bob = FlarumApi(FlarumClient(args[0], dio: Dio()..interceptors.add(recorder)));
  await bob.logIn('bob', password);

  Future<T> record<T>(String name, Future<T> Function() call) async {
    recorder.names.add(name);
    try {
      return await call();
    } finally {
      if (recorder.names.isNotEmpty) throw StateError('$name: no response recorded');
    }
  }

  try {
    recorder.states['flapp_forum'] = 'flapp';
    final info = await record('flapp_forum', bob.forumInfo);
    if (info.flappPush == null) throw StateError('The forum announces no flappPush: is it connected to a relay?');
    final id = await record(
        'flapp_register_device',
        () => bob.registerFlappDevice(handle: fixtureHandle, platform: 'android', app: 'flapp', locale: 'de'));
    await record('flapp_delete_device', () => bob.deleteFlappDevice(id));
    // Gone already: the forum answers 404, which counts as deleted.
    await record('flapp_delete_device_gone', () => bob.deleteFlappDevice(id));

    final dir = Directory('test/fixtures/${info.version.name}')..createSync(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    for (final MapEntry(key: name, value: fixture) in recorder.recorded.entries) {
      File('${dir.path}/$name.json').writeAsStringSync('${encoder.convert(fixture)}\n');
    }
    stdout.writeln('Recorded ${recorder.recorded.length} Flapp fixtures into ${dir.path}');
  } finally {
    await bob.logOut();
  }
}
