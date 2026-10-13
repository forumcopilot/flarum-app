import 'package:dio/dio.dart';

/// Saves the responses to the requests that follow [names], one fixture per name, in order: the
/// request as FlarumApi sent it (with its body), the status and the body. Requests sent while
/// [names] is empty aren't kept.
class FixtureRecorder extends Interceptor {
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
