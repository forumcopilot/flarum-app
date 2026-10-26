import 'package:dio/dio.dart';

/// The phone's identity on a Flapp relay: an id and a secret the app makes once and keeps. The
/// relay files the secret's hash on the first call and wants the same secret on every later one.
class FlappInstallation {
  const FlappInstallation({required this.id, required this.secret});

  /// 16 to 64 of `A-Z a-z 0-9 _ -`.
  final String id;

  /// 32 to 128 of `A-Z a-z 0-9 _ -`.
  final String secret;
}

/// A refused or failed call to the relay. [statusCode] is null when no answer arrived.
class FlappRelayException implements Exception {
  FlappRelayException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => 'FlappRelayException($statusCode): $message';
}

/// The app's calls to a Flapp relay (forumcopilot/flapp-push), made as the phone's
/// [installation]. A forum's `flappPush` names the relay; the forum itself never sees the phone's
/// push token, only the handle the relay makes for it.
class FlappRelayClient {
  FlappRelayClient(String baseUrl, this.installation, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl
      ..responseType = ResponseType.json
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer ${installation.id}:${installation.secret}';
  }

  final FlappInstallation installation;
  final Dio _dio;

  /// Tells the relay where the phone can be reached: its push token (null when it has none), the
  /// [platform] (`android` or `ios`), whether the system lets the app show notifications, the
  /// app's version and the phone's language. One call covers every forum the phone has a handle
  /// on. Creates the installation on first sight.
  Future<void> updateInstallation({
    required String? deviceToken,
    required String platform,
    required bool notificationsPermitted,
    String? appVersion,
    String? locale,
  }) =>
      _send('PUT', '/v1/installation', {
        'device_token': deviceToken ?? '',
        'device_platform': platform,
        'notifications_permitted': notificationsPermitted,
        if (appVersion != null) 'app_version': appVersion,
        if (locale != null) 'locale': locale,
      });

  /// The phone's handle for the forum with [forumId] on this relay: the same handle every time
  /// for the same phone and forum.
  Future<String> handleFor(String forumId) async {
    final answer = await _send('POST', '/v1/handles', {'forumId': forumId});
    final handle = answer['handle'];
    if (handle is! String || handle.isEmpty) throw FlappRelayException(null, 'The relay answered without a handle');
    return handle;
  }

  /// Stops the relay pushing to the phone through [handle]. A handle it no longer has counts as
  /// deleted.
  Future<void> deleteHandle(String handle) async {
    try {
      await _send('DELETE', '/v1/handles/${Uri.encodeComponent(handle)}', null);
    } on FlappRelayException catch (e) {
      if (e.statusCode != 404) rethrow;
    }
  }

  Future<Map<String, dynamic>> _send(String method, String path, Map<String, dynamic>? body) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        options: Options(method: method, contentType: body == null ? null : 'application/json'),
      );
      final data = response.data;
      return data is Map ? data.cast<String, dynamic>() : const {};
    } on DioException catch (e) {
      final data = e.response?.data;
      final error = data is Map ? data['error'] : null;
      throw FlappRelayException(e.response?.statusCode, error is String ? error : (e.message ?? 'The relay could not be reached'));
    }
  }
}
