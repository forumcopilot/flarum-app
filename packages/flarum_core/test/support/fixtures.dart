import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flarum_core/flarum_core.dart';

/// Recorded responses from one Flarum version's test forum (test/fixtures/v1
/// or v2, written by tool/record_fixtures.dart), served to a [FlarumApi] in
/// place of the network.
class FixtureForum {
  FixtureForum(this.version)
      : _fixtures = [
          for (final file in Directory('test/fixtures/${version.name}').listSync().whereType<File>())
            if (!file.path.endsWith('seed.json')) _Fixture(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>),
        ],
        seed = jsonDecode(File('test/fixtures/${version.name}/seed.json').readAsStringSync()) as Map<String, dynamic>;

  final FlarumVersion version;
  final List<_Fixture> _fixtures;

  /// The ids the seed script created: `discussions`, `users`, `tags`.
  final Map<String, dynamic> seed;

  /// Every request the APIs from [api] have sent, in order.
  final requests = <RequestOptions>[];

  String discussionId(String name) => (seed['discussions'] as Map)[name] as String;
  String userId(String name) => (seed['users'] as Map)[name] as String;

  /// An API over the fixtures, signed in as alice unless [signedIn] is false.
  FlarumApi api({bool signedIn = true}) {
    final dio = Dio()..httpClientAdapter = _FixtureAdapter(this);
    return FlarumApi(FlarumClient('https://forum.test', token: signedIn ? 'fixture-token' : null, dio: dio));
  }
}

class _Fixture {
  _Fixture(Map<String, dynamic> json)
      : method = json['request']['method'] as String,
        path = json['request']['path'] as String,
        query = (json['request']['query'] as Map).map((key, value) => MapEntry('$key', '$value')),
        signedIn = json['request']['signedIn'] as bool,
        rememberCookie = json['request']['rememberCookie'] as bool? ?? false,
        status = json['status'] as int,
        body = json['body'];

  final String method;
  final String path;
  final Map<String, String> query;
  final bool signedIn;
  final bool rememberCookie;
  final int status;
  final Object? body;

  bool matches(RequestOptions options) =>
      options.method == method &&
      options.path == path &&
      options.headers.containsKey('Authorization') == signedIn &&
      '${options.headers['Cookie'] ?? ''}'.contains('_remember=') == rememberCookie &&
      _sameQuery(options.queryParameters, query);

  static bool _sameQuery(Map<String, dynamic> sent, Map<String, String> recorded) =>
      sent.length == recorded.length && sent.entries.every((e) => recorded[e.key] == '${e.value}');
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.forum);

  final FixtureForum forum;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    forum.requests.add(options);
    for (final fixture in forum._fixtures) {
      if (fixture.matches(options)) {
        return ResponseBody.fromString(
          fixture.body == null ? '' : jsonEncode(fixture.body),
          fixture.status,
          headers: {
            Headers.contentTypeHeader: ['application/vnd.api+json'],
          },
        );
      }
    }
    throw StateError('No ${forum.version.name} fixture for ${options.method} ${options.path} ${options.queryParameters}. '
        'If the request changed on purpose, re-record with tool/record_fixtures.dart.');
  }

  @override
  void close({bool force = false}) {}
}
