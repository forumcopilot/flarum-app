// Records the composer's writes on a live test forum into test/fixtures/v1 or v2 (write_*.json),
// which the offline tests replay: starting a discussion, replying, editing, and the forum's
// refusals (no tags, the posting throttle, someone else's post).
//
// carol starts the discussion and bob replies, so alice's state, which the other fixtures depend
// on, stays as seeded; an admin deletes the discussion at the end. The texts are WriteSamples'.
//
//   FLARUM_TEST_PASSWORD=… FLARUM_ADMIN_USER=admin FLARUM_ADMIN_PASSWORD=… \
//     dart run tool/record_write_fixtures.dart http://127.0.0.1:8081

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flarum_core/api.dart';
import 'package:flarum_core/src/testing/write_samples.dart';

import 'fixture_recorder.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final password = env['FLARUM_TEST_PASSWORD'];
  final adminUser = env['FLARUM_ADMIN_USER'];
  final adminPassword = env['FLARUM_ADMIN_PASSWORD'];
  if (args.length != 1 || password == null || adminUser == null || adminPassword == null) {
    stderr.writeln('usage: FLARUM_TEST_PASSWORD=… FLARUM_ADMIN_USER=… FLARUM_ADMIN_PASSWORD=… '
        'dart run tool/record_write_fixtures.dart <forum url>');
    exit(64);
  }
  final url = args[0];
  final recorder = FixtureRecorder();
  FlarumApi member(Interceptor recorder) => FlarumApi(FlarumClient(url, dio: Dio()..interceptors.add(recorder)));
  final carol = member(recorder);
  final bob = member(recorder);
  final admin = FlarumApi(FlarumClient(url, dio: Dio()));
  await carol.logIn('carol', password);
  await bob.logIn('bob', password);
  await admin.logIn(adminUser, adminPassword);

  /// Records the response [call] gets as fixture [name], refusals included; returns its value.
  Future<T?> record<T>(String name, Future<T> Function() call) async {
    recorder.names.add(name);
    try {
      return await call();
    } on FlarumApiException {
      return null;
    } finally {
      if (recorder.names.isNotEmpty) throw StateError('$name: no response recorded');
    }
  }

  final version = (await carol.forumInfo()).version;
  final general = (await carol.tags()).firstWhere((t) => t.slug == 'general').id;
  // The refusals that come before any post: a post would set off the throttle for what follows.
  await record('write_start_discussion_no_tags', () => carol.startDiscussion(WriteSamples.title, WriteSamples.noTagsContent));
  final discussion = await record(
      'write_start_discussion', () => carol.startDiscussion(WriteSamples.title, WriteSamples.content, tagIds: [general]));
  if (discussion == null) throw StateError('The discussion was not started');
  try {
    final reply = await record('write_reply', () => bob.reply(discussion.id, WriteSamples.reply));
    if (reply == null) throw StateError('The reply was not posted');
    await record('write_reply_throttled', () => bob.reply(discussion.id, WriteSamples.throttledReply));
    await record('write_edit_post', () => bob.editPost(reply.id, WriteSamples.edit));
    await record('write_edit_post_not_theirs', () => carol.editPost(reply.id, WriteSamples.editByOther));
  } finally {
    await admin.client.delete('/discussions/${discussion.id}');
    for (final api in [carol, bob, admin]) {
      await api.logOut();
    }
  }

  final dir = Directory('test/fixtures/${version.name}')..createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  for (final MapEntry(key: name, value: fixture) in recorder.recorded.entries) {
    File('${dir.path}/$name.json').writeAsStringSync('${encoder.convert(fixture)}\n');
  }
  stdout.writeln('Recorded ${recorder.recorded.length} write fixtures into ${dir.path}');
}
