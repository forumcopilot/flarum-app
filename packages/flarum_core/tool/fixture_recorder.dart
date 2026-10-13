import 'package:dio/dio.dart';

/// Saves the responses to the requests that follow [names], one fixture per name, in order: the
/// request as FlarumApi sent it (with its body), the status and the body. Requests sent while
/// [names] is empty aren't kept.
class FixtureRecorder extends Interceptor {
  final names = <String>[];

  /// Fixtures to replay only for a request with the same whole `data` (see FixtureForum).
  final matchData = <String>{};

  /// Fixtures that show the forum in a state (`ignoring`: the reader ignores someone), replayed
  /// only to tests that ask for it, in place of the same request's plain fixture.
  final states = <String, String>{};
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
    final name = names.removeAt(0);
    recorded[name] = {
      'request': {
        if (matchData.contains(name)) 'match': 'data',
        if (states[name] case final state?) 'state': state,
        'method': options.method,
        'path': options.path,
        'query': options.queryParameters,
        'signedIn': options.headers.containsKey('Authorization'),
        'rememberCookie': '${options.headers['Cookie'] ?? ''}'.contains('_remember='),
        // A multipart upload is kept as the names of its files: the form itself isn't JSON.
        if (options.data case final FormData form)
          'body': {'files': [for (final f in form.files) f.value.filename]}
        else if (options.data != null)
          'body': options.data,
      },
      'status': status,
      'body': body,
    };
  }
}
