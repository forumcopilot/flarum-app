import 'package:dio/dio.dart';

import 'flarum_exception.dart';
import 'json_api.dart';

/// Low-level HTTP access to one forum's `/api`.
///
/// Signs requests with `Authorization: Token <token>`, which Flarum accepts
/// in place of the session cookie and which skips its CSRF check. Failed
/// requests throw [FlarumApiException] with the server's `errors[]`.
///
/// Callers must send only query parameters Flarum knows: 2.0 answers an
/// unknown one with HTTP 400 ("Invalid query parameter"), while 1.x ignores it.
class FlarumClient {
  FlarumClient(String baseUrl, {this.token, String userAgent = defaultUserAgent, Dio? dio})
      : baseUrl = _trimSlash(baseUrl),
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = '${this.baseUrl}/api'
      ..responseType = ResponseType.json
      ..headers['Accept'] = 'application/vnd.api+json'
      ..headers['User-Agent'] = userAgent;
  }

  /// Our own agent rather than Dart's default: fof/discussion-views ignores
  /// `Dart/…` and `okhttp` agents, so the app's reads wouldn't count as views.
  static const defaultUserAgent = 'flarum-app/0.1 (+https://github.com/forumcopilot/flarum-app)';

  /// The forum's address without a trailing slash, e.g. `https://discuss.flarum.org`.
  final String baseUrl;

  /// The signed-in reader's API token, or null for a guest.
  String? token;

  final Dio _dio;

  /// GETs a JSON:API document. [path] is relative to `/api`; `''` is the forum itself.
  Future<JsonApiDocument> get(String path, {Map<String, String> query = const {}}) async =>
      JsonApiDocument.fromJson(await _send('GET', path, query: query) ?? const {});

  /// POSTs a JSON:API document and returns the response document.
  Future<JsonApiDocument> post(String path, Map<String, dynamic> body) async =>
      JsonApiDocument.fromJson(await _send('POST', path, body: body, jsonApi: true) ?? const {});

  /// PATCHes a JSON:API document and returns the response document.
  Future<JsonApiDocument> patch(String path, Map<String, dynamic> body) async =>
      JsonApiDocument.fromJson(await _send('PATCH', path, body: body, jsonApi: true) ?? const {});

  Future<void> delete(String path) => _send('DELETE', path);

  /// POSTs plain JSON (not JSON:API), for endpoints such as `/token`.
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async =>
      await _send('POST', path, body: body, jsonApi: false) ?? const {};

  Future<Map<String, dynamic>?> _send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    bool jsonApi = true,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          contentType: body == null ? null : (jsonApi ? 'application/vnd.api+json' : 'application/json'),
          headers: {if (token != null) 'Authorization': 'Token $token'},
        ),
      );
      final data = response.data;
      return data is Map ? data.cast<String, dynamic>() : null;
    } on DioException catch (e) {
      throw FlarumApiException.fromResponse(
        e.response?.statusCode,
        e.response?.data,
        method: method,
        path: path,
        cause: e.response == null ? e : null,
      );
    }
  }
}

String _trimSlash(String url) => url.endsWith('/') ? url.substring(0, url.length - 1) : url;
