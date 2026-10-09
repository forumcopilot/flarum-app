import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flarum_core/testing.dart';

void main() {
  for (final version in FlarumVersion.values) {
    test('Flarum ${version.name}: logOut finds the current token through the remember cookie and deletes it', () async {
      final forum = FixtureForum(version);
      final api = forum.api();

      expect(await api.logOut(), isTrue);
      expect(api.client.token, isNull);

      final [list, delete] = forum.requests;
      expect(list.path, '/access-tokens');
      expect(list.queryParameters, {'page[offset]': '0', 'page[limit]': '50'});
      expect(list.headers['Cookie'], 'flarum_remember=fixture-token');
      expect(list.headers.containsKey('Authorization'), isFalse);
      expect(delete.method, 'DELETE');
      expect(delete.path, matches(RegExp(r'^/access-tokens/\d+$')));
      expect(delete.headers['Authorization'], 'Token fixture-token');
    });
  }

  group('logOut', () {
    test('learns a custom cookie prefix from the 401 and retries once', () async {
      final adapter = _ScriptedAdapter([
        _unauthorized(setCookie: 'myforum_session=abc; path=/; httponly'),
        _ok({
          'data': [
            _token('6', isCurrent: false),
            _token('7', isCurrent: true),
          ],
        }),
        (204, null, const {}),
      ]);
      final api = _api(adapter);

      expect(await api.logOut(), isTrue);
      expect(api.client.cookiePrefix, 'myforum');
      expect(adapter.requests[0].headers['Cookie'], 'flarum_remember=t');
      expect(adapter.requests[1].headers['Cookie'], 'myforum_remember=t');
      expect(adapter.requests[2].path, '/access-tokens/7');
    });

    test('pages through the token list to find the current one', () async {
      final adapter = _ScriptedAdapter([
        _ok({
          'links': {'next': 'https://forum.test/access-tokens?page%5Boffset%5D=50&page%5Blimit%5D=50'},
          'data': [for (var id = 1; id <= 50; id++) _token('$id', isCurrent: false)],
        }),
        _ok({
          'links': <Object>[],
          'data': [_token('51', isCurrent: false), _token('52', isCurrent: true)],
        }),
        (204, null, const {}),
      ]);
      final api = _api(adapter);

      expect(await api.logOut(), isTrue);
      expect(adapter.requests[0].queryParameters, {'page[offset]': '0', 'page[limit]': '50'});
      expect(adapter.requests[1].queryParameters, {'page[offset]': '50', 'page[limit]': '50'});
      expect(adapter.requests[1].headers['Cookie'], 'flarum_remember=t');
      expect(adapter.requests[2].path, '/access-tokens/52');
    });

    test('a token the forum already rejects counts as revoked', () async {
      final adapter = _ScriptedAdapter([_unauthorized()]);
      final api = _api(adapter);

      expect(await api.logOut(), isTrue);
      expect(api.client.token, isNull);
      expect(adapter.requests, hasLength(1));
    });

    test('reports false when no token is marked current, and deletes nothing', () async {
      final adapter = _ScriptedAdapter([
        _ok({
          'data': [_token('6', isCurrent: false)],
        }),
      ]);
      final api = _api(adapter);

      expect(await api.logOut(), isFalse);
      expect(api.client.token, isNull);
      expect(adapter.requests, hasLength(1));
    });

    test('keeps the token when the forum can\'t be reached, so the caller can retry', () async {
      final adapter = _ScriptedAdapter([(503, null, const {})]);
      final api = _api(adapter);

      await expectLater(api.logOut(), throwsA(isA<FlarumApiException>()));
      expect(api.client.token, 't');
    });
  });
}

FlarumApi _api(_ScriptedAdapter adapter) =>
    FlarumApi(FlarumClient('https://forum.test', token: 't', dio: Dio()..httpClientAdapter = adapter));

typedef _Reply = (int status, Object? body, Map<String, List<String>> headers);

_Reply _ok(Object body) => (200, body, const {});

_Reply _unauthorized({String? setCookie}) => (
      401,
      {
        'errors': [
          {'status': '401', 'code': 'not_authenticated'},
        ],
      },
      {
        if (setCookie != null) 'set-cookie': [setCookie],
      },
    );

Map<String, Object> _token(String id, {required bool isCurrent}) => {
      'type': 'access-tokens',
      'id': id,
      'attributes': {'isCurrent': isCurrent, 'isSessionToken': true},
    };

/// Answers requests with [replies] in order.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.replies);

  final List<_Reply> replies;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final (status, body, headers) = replies[requests.length];
    requests.add(options);
    return ResponseBody.fromString(body == null ? '' : jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/vnd.api+json'],
      ...headers,
    });
  }

  @override
  void close({bool force = false}) {}
}
