import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../flarum_core.dart';

/// Recorded responses from one Flarum version's test forum (flarum_core's
/// test/fixtures/v1 or v2, written by tool/record_fixtures.dart), served to a
/// [FlarumApi] in place of the network. For tests only: flarum_core's own, and
/// flarum_ui's, which pass [root] as the path to flarum_core's fixtures.
class FixtureForum {
  FixtureForum(this.version, {String root = 'test/fixtures', this.states = const {}})
      : _fixtures = [
          for (final file in Directory('$root/${version.name}').listSync().whereType<File>().toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
            if (!file.path.endsWith('seed.json')) _Fixture(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>),
        ],
        seed = jsonDecode(File('$root/${version.name}/seed.json').readAsStringSync()) as Map<String, dynamic>;

  final FlarumVersion version;
  final List<_Fixture> _fixtures;

  /// The states the forum is in, such as `ignoring` (the reader ignores bob): fixtures recorded
  /// in one are served only when it's on, in place of the same request's plain fixture.
  final Set<String> states;

  /// The fixtures served so far, for requests recorded more than once.
  final _served = <_Fixture>{};

  /// The ids the seed script created: `discussions`, `users`, `tags`.
  final Map<String, dynamic> seed;

  /// Every request the APIs from [api] have sent, in order.
  final requests = <RequestOptions>[];

  /// Answers (200) given in place of the fixtures, by method and path (`GET /dialogs`): a reader
  /// whose list is empty, say, where only a full one was recorded.
  final replies = <String, Object>{};

  /// Every request fails as it does with no connection (Dio's connection error, no response).
  bool offline = false;

  /// A guest's read with no guest recording gets the member's: the page reads the same, and what
  /// the app offers a guest (Log In to Reply) depends on its being signed out, not on the data.
  bool guestReadsMember = false;

  /// How long each answer takes. Zero answers before the next frame, which no network does: a test
  /// of what the reader sees while a page loads sets a real delay.
  Duration latency = Duration.zero;

  String discussionId(String name) => (seed['discussions'] as Map)[name] as String;
  String userId(String name) => (seed['users'] as Map)[name] as String;
  String tagId(String name) => (seed['tags'] as Map)[name] as String;

  /// An API over the fixtures, signed in as alice unless [signedIn] is false.
  FlarumApi api({bool signedIn = true}) =>
      FlarumApi(FlarumClient(baseUrl, token: signedIn ? 'fixture-token' : null, dio: _dio()));

  /// The registry's forum at [url] ([baseUrl] unless a test hosts several
  /// forums), answered from the fixtures, signed in as alice unless
  /// [signedIn] is false. Replaces any earlier one.
  FlarumForum forum({bool signedIn = true, String url = baseUrl}) {
    final forum = FlarumForum.forTesting(url, _dio());
    if (signedIn) forum.api.client.token = 'fixture-token';
    return forum;
  }

  static const baseUrl = 'https://forum.test';

  Dio _dio() => Dio()..httpClientAdapter = _FixtureAdapter(this);
}

class _Fixture {
  _Fixture(Map<String, dynamic> json)
      : method = json['request']['method'] as String,
        path = json['request']['path'] as String,
        query = (json['request']['query'] as Map).map((key, value) => MapEntry('$key', '$value')),
        signedIn = json['request']['signedIn'] as bool,
        rememberCookie = json['request']['rememberCookie'] as bool? ?? false,
        state = json['request']['state'] as String?,
        attributes = _attributesOf(json['request']['body']),
        data = json['request']['match'] == 'data' ? _dataOf(json['request']['body']) : null,
        files = switch (json['request']['body']) {
          {'files': final List<dynamic> names} => names.cast<String>(),
          _ => null,
        },
        status = json['status'] as int,
        body = json['body'];

  final String method;
  final String path;
  final Map<String, String> query;
  final bool signedIn;
  final bool rememberCookie;

  /// The state the forum was recorded in, if any (FixtureForum.states).
  final String? state;

  /// A write's `data.attributes` as recorded (a reply's text, a discussion's title): told apart by
  /// them, a reply that worked and one the throttle refused share a method and path.
  final Object? attributes;

  /// The write's whole `data`, for fixtures recorded to match on it: 2.0's best answer (empty
  /// attributes, the post in `relationships`) and 1.x's tag level (`data.subscription`).
  final Object? data;

  /// An upload's file names: two uploads to the same route are told apart by them.
  final List<String>? files;
  final int status;
  final Object? body;

  bool matches(RequestOptions options, {bool asMember = false}) =>
      options.method == method &&
      options.path == path &&
      (asMember || options.headers.containsKey('Authorization')) == signedIn &&
      '${options.headers['Cookie'] ?? ''}'.contains('_remember=') == rememberCookie &&
      _sameQuery(options.queryParameters, query) &&
      (files != null
          ? options.data is FormData &&
              _canonical([for (final f in (options.data as FormData).files) f.value.filename]) == _canonical(files)
          : data != null
              ? _canonical(_dataOf(options.data)) == _canonical(data)
              : attributes == null || _canonical(_attributesOf(options.data)) == _canonical(attributes));

  static Object? _dataOf(Object? body) => body is Map ? body['data'] : null;

  static Object? _attributesOf(Object? body) {
    final data = body is Map ? body['data'] : null;
    return data is Map ? data['attributes'] : null;
  }

  /// [value] as JSON with its keys sorted, to compare maps whatever their order.
  static String _canonical(Object? value) {
    Object? sorted(Object? v) => switch (v) {
          Map() => {for (final key in v.keys.map((k) => '$k').toList()..sort()) key: sorted(v[key])},
          List() => [for (final e in v) sorted(e)],
          _ => v,
        };
    return jsonEncode(sorted(value));
  }

  static bool _sameQuery(Map<String, dynamic> sent, Map<String, String> recorded) =>
      sent.length == recorded.length && sent.entries.every((e) => recorded[e.key] == '${e.value}');
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.forum);

  final FixtureForum forum;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    forum.requests.add(options);
    if (forum.latency > Duration.zero) await Future<void>.delayed(forum.latency);
    if (forum.offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Failed host lookup',
        error: const SocketException('Failed host lookup'),
      );
    }
    if (forum.replies['${options.method} ${options.path}'] case final body?) {
      return ResponseBody.fromString(jsonEncode(body), 200, headers: {
        Headers.contentTypeHeader: ['application/vnd.api+json'],
      });
    }
    // Where the same request was recorded more than once (a reaction, then the same reaction
    // again to take it back), each is served once, in file-name order, the last one after that.
    List<_Fixture> matchingAs({bool asMember = false}) => [
          for (final fixture in forum._fixtures)
            if (fixture.matches(options, asMember: asMember) && (fixture.state == null || forum.states.contains(fixture.state)))
              fixture,
        ];
    var matching = matchingAs();
    if (matching.isEmpty && forum.guestReadsMember && !options.headers.containsKey('Authorization')) {
      matching = matchingAs(asMember: true);
    }
    if (matching.any((f) => f.state != null)) matching = [for (final f in matching) if (f.state != null) f];
    final fixture = matching.where((f) => !forum._served.contains(f)).firstOrNull ?? matching.lastOrNull;
    if (fixture != null) {
      forum._served.add(fixture);
      return ResponseBody.fromString(
        fixture.body == null ? '' : jsonEncode(fixture.body),
        fixture.status,
        headers: {
          Headers.contentTypeHeader: ['application/vnd.api+json'],
        },
      );
    }
    throw StateError('No ${forum.version.name} fixture for ${options.method} ${options.path} ${options.queryParameters}. '
        'If the request changed on purpose, re-record with tool/record_fixtures.dart.');
  }

  @override
  void close({bool force = false}) {}
}
