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
  FlarumClient(String baseUrl, {this.token, this.cookiePrefix = 'flarum', String userAgent = defaultUserAgent, Dio? dio})
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

  /// The forum's cookie name prefix (`cookie.name` in its config.php): its
  /// cookies are `<prefix>_session` and `<prefix>_remember`. Learned from the
  /// forum when [getWithRememberCookie] finds it differs.
  String cookiePrefix;

  final Dio _dio;

  /// GETs a JSON:API document. [path] is relative to `/api`; `''` is the forum itself.
  Future<JsonApiDocument> get(String path, {Map<String, String> query = const {}}) async =>
      _document(await _send('GET', path, query: query));

  /// POSTs a JSON:API document and returns the response document.
  Future<JsonApiDocument> post(String path, Map<String, dynamic> body) async =>
      _document(await _send('POST', path, body: body, jsonApi: true));

  /// PATCHes a JSON:API document and returns the response document.
  Future<JsonApiDocument> patch(String path, Map<String, dynamic> body) async =>
      _document(await _send('PATCH', path, body: body, jsonApi: true));

  Future<void> delete(String path) => _send('DELETE', path);

  /// POSTs plain JSON (not JSON:API), for endpoints such as `/token`.
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async =>
      _json((await _send('POST', path, body: body, jsonApi: false)).data);

  /// GETs [path] presenting the token as the forum's remember cookie, as the
  /// website does, instead of the Authorization header.
  ///
  /// Flarum then holds the token in a session, which is the only way it marks
  /// a token `isCurrent` in `/access-tokens`: a header token is never current
  /// (and 2.0 rc.8 fails with HTTP 500 listing tokens for one). If the forum
  /// uses another cookie prefix, its 401 response sets `<prefix>_session`;
  /// the prefix is adopted and the request retried once.
  Future<JsonApiDocument> getWithRememberCookie(String path, {Map<String, String> query = const {}}) async {
    try {
      return _document(await _send('GET', path, query: query, rememberCookie: true));
    } on _CookieRejected catch (rejected) {
      if (rejected.prefix == null || rejected.prefix == cookiePrefix) throw rejected.exception;
      cookiePrefix = rejected.prefix!;
      return _document(await _send('GET', path, query: query, rememberCookie: true));
    }
  }

  Future<Response<Object?>> _send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    bool jsonApi = true,
    bool rememberCookie = false,
  }) async {
    final headers = <String, String>{
      if (token != null && rememberCookie) 'Cookie': '${cookiePrefix}_remember=$token',
      if (token != null && !rememberCookie) 'Authorization': 'Token $token',
    };
    try {
      return await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          contentType: body == null ? null : (jsonApi ? 'application/vnd.api+json' : 'application/json'),
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      final response = e.response;
      final exception = FlarumApiException.fromResponse(
        response?.statusCode,
        response?.data,
        method: method,
        path: path,
        cause: response == null ? e : null,
      );
      if (rememberCookie && exception.isUnauthorized) {
        throw _CookieRejected(exception, _sessionCookiePrefix(response?.headers['set-cookie']));
      }
      throw exception;
    }
  }

  static JsonApiDocument _document(Response<Object?> response) => JsonApiDocument.fromJson(_json(response.data));

  static Map<String, dynamic> _json(Object? data) => data is Map ? data.cast<String, dynamic>() : const {};
}

/// A 401 for a remember-cookie request, with the cookie prefix the forum's
/// `Set-Cookie: <prefix>_session=…` revealed, if any.
class _CookieRejected implements Exception {
  _CookieRejected(this.exception, this.prefix);

  final FlarumApiException exception;
  final String? prefix;
}

String? _sessionCookiePrefix(List<String>? setCookies) {
  for (final cookie in setCookies ?? const <String>[]) {
    final match = RegExp(r'^\s*([^=;\s]+)_session=').firstMatch(cookie);
    if (match != null) return match.group(1);
  }
  return null;
}

String _trimSlash(String url) => url.endsWith('/') ? url.substring(0, url.length - 1) : url;
