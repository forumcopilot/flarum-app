// Records API responses from a live test forum into test/fixtures/v1 or v2,
// which the offline tests replay.
//
// Run from packages/flarum_core against a forum seeded by the test-forum seed
// script (alice, bob and carol, and the discussions in its ids file):
//
//   FLARUM_TEST_PASSWORD=… dart run tool/record_fixtures.dart http://127.0.0.1:8081 seed-v1.json
//
// The fixture folder (v1 or v2) is chosen from the forum's detected version.
// Each fixture holds the request as FlarumApi sent it, the status and the body.
// The log-in responses are not recorded: they contain tokens.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flarum_core/api.dart';

Future<void> main(List<String> args) async {
  final password = Platform.environment['FLARUM_TEST_PASSWORD'];
  if (args.length != 2 || password == null) {
    stderr.writeln('usage: FLARUM_TEST_PASSWORD=… dart run tool/record_fixtures.dart <forum url> <seed ids json>');
    exit(64);
  }
  final seed = jsonDecode(File(args[1]).readAsStringSync()) as Map<String, dynamic>;
  final discussions = (seed['discussions'] as Map).cast<String, String>();
  final users = (seed['users'] as Map).cast<String, String>();
  final welcomePosts = ((seed['posts'] as Map)['welcome'] as List).cast<String>();

  final recorder = _Recorder();
  final guest = FlarumApi(FlarumClient(args[0], dio: Dio()..interceptors.add(recorder)));
  final api = FlarumApi(FlarumClient(args[0], dio: Dio()..interceptors.add(recorder)));

  /// Records the responses [call] gets, one fixture per name, in order.
  Future<void> recordAll(List<String> names, Future<Object?> Function() call) async {
    recorder.names.addAll(names);
    try {
      await call();
    } on FlarumApiException {
      // Error responses are fixtures too.
    }
    if (recorder.names.isNotEmpty) throw StateError('${recorder.names.join(', ')}: no response recorded');
  }

  Future<void> record(String name, Future<Object?> Function() call) => recordAll([name], call);

  final version = (await guest.forumInfo()).version;
  await record('forum_guest', guest.forumInfo);
  await record('notifications_guest', guest.notifications);

  await api.logIn('alice', password);
  await record('forum', api.forumInfo);
  await record('discussions_latest', api.discussions);
  await record('discussions_tag_support', () => api.discussions(tagSlug: 'support'));
  await record('discussions_following', () => api.discussions(following: true));
  await record('discussions_newest', () => api.discussions(sort: DiscussionSort.newest));
  await record('discussions_top_support', () => api.discussions(tagSlug: 'support', sort: DiscussionSort.top));
  await record('discussions_sticky', () => api.discussions(sticky: true));
  await record('discussions_unread', () => api.discussions(unread: true));
  await record('discussions_author_bob', () => api.discussions(author: 'bob'));
  // A search within a tag: gambits in q on 1.x, separate filter keys on 2.0.
  await record('discussions_search_in_tag', () => api.discussions(query: 'thread', tagSlug: 'support'));
  await record('discussion_welcome', () => api.discussion(discussions['welcome']!));
  await record('discussion_not_found', () => api.discussion('999999'));
  await record('posts_welcome', () => api.posts(discussions['welcome']!));
  await record('posts_long_0', () => api.posts(discussions['long']!, limit: 50));
  await record('posts_long_50', () => api.posts(discussions['long']!, offset: 50, limit: 50));
  await record('posts_long_near_30', () => api.postsNear(discussions['long']!, 30, limit: 5));
  await record('user_bob', () => api.user(users['bob']!));
  await record('tags', api.tags);
  await record('post_welcome_2', () => api.post(welcomePosts[1]));
  await record('post_number_welcome_2', () => api.postIdByNumber(discussions['welcome']!, 2));
  await record('notifications', api.notifications);
  // The version difference behind FlarumClient's "known parameters only" rule.
  await record('unknown_query_param', () => api.client.get('/posts', query: {'filter[discussion]': discussions['welcome']!, 'foo': 'bar'}));
  await record('start_discussion_invalid', () => api.client.post('/discussions', {
        'data': {
          'type': 'discussions',
          'attributes': {'title': '', 'content': ''},
        },
      }));

  // Sign-out lists the account's tokens with the remember cookie, then deletes the current one.
  // carol signs in afresh so the tokens the fixtures above used stay valid.
  final carol = FlarumApi(FlarumClient(args[0], dio: Dio()..interceptors.add(recorder)));
  await carol.logIn('carol', password);
  await recordAll(['logout_list_tokens', 'logout_delete_token'], carol.logOut);

  // Not recorded: revokes alice's token from this run so her token list doesn't grow.
  await api.logOut();

  final dir = Directory('test/fixtures/${version.name}')..createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  for (final MapEntry(key: name, value: fixture) in recorder.recorded.entries) {
    File('${dir.path}/$name.json').writeAsStringSync('${encoder.convert(fixture)}\n');
  }
  File('${dir.path}/seed.json').writeAsStringSync('${encoder.convert(seed)}\n');
  stdout.writeln('Recorded ${recorder.recorded.length} fixtures into ${dir.path}');
}

class _Recorder extends Interceptor {
  final names = <String>[];
  final recorded = <String, Map<String, Object?>>{};

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _save(response.requestOptions, response.statusCode, response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) _save(err.requestOptions, response.statusCode, response.data);
    handler.next(err);
  }

  void _save(RequestOptions options, int? status, Object? body) {
    if (names.isEmpty) return;
    recorded[names.removeAt(0)] = {
      'request': {
        'method': options.method,
        'path': options.path,
        'query': options.queryParameters,
        'signedIn': options.headers.containsKey('Authorization'),
        'rememberCookie': '${options.headers['Cookie'] ?? ''}'.contains('_remember='),
        if (options.data != null) 'body': options.data,
      },
      'status': status,
      'body': body,
    };
  }
}
