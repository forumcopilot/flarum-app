import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flarum_core/flarum_core.dart' show FlarumApiException, FlarumForum;
import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';

/// Who may see the reader's token when the app fetches a post's pictures,
/// videos and files: the forum's own file downloads, and nothing else.
///
/// fof/upload stores files under `/assets/files/`, which the web server hands
/// to anyone, so pictures and videos go without it. A file shown as a
/// download button (`div.ButtonGroup[data-fof-upload-download-uuid]`) comes
/// from `GET /api/fof/download/{uuid}`, which answers only a reader with the
/// forum's download permission (`fof-upload.download`): that request carries
/// `Authorization: Token`, as the API does. The token goes only to the
/// forum's origin (its scheme, host and port) and only to that path: never
/// to an image host or a CDN, and not to the forum's static files either.
@immutable
class ForumMediaAuth {
  const ForumMediaAuth({required this.siteUrl, this.credentials = const {}});

  /// The signed-in reader of [site]; no credentials for a guest.
  factory ForumMediaAuth.of(SiteContext site) {
    final token = FlarumForum.of(site).api.client.token;
    return ForumMediaAuth(
      siteUrl: site.site.url,
      credentials: token == null ? const {} : {'Authorization': 'Token $token'},
    );
  }

  /// The forum's address, as the app was configured with it.
  final String siteUrl;

  /// `Authorization`, or none.
  final Map<String, String> credentials;

  static const List<String> _privatePaths = ['/api/fof/download/'];

  /// The headers a request for [url] may carry: the credentials for one of
  /// the forum's file downloads, nothing for any other address.
  Map<String, String> headersFor(String url) {
    if (credentials.isEmpty) return const {};
    final path = _pathOnForum(url);
    if (path == null || !_privatePaths.any(path.startsWith)) return const {};
    return credentials;
  }

  /// Whether [url] needs the token on the first request: a download always
  /// does, since the API refuses guests by default.
  bool mustAuthenticate(String url) => headersFor(url).isNotEmpty;

  /// [url]'s path below the forum's base path when [url] is on the forum's
  /// origin, else null. Same scheme, host and port: a look-alike host
  /// (`forum.example.com.evil.com`, `forum.example.com@evil.com`) is another
  /// origin.
  String? _pathOnForum(String url) {
    final target = Uri.tryParse(url.trim());
    final site = Uri.tryParse(siteUrl.trim());
    if (target == null || site == null) return null;
    if (!target.hasAuthority || !site.hasAuthority) return null;
    if (target.scheme != 'http' && target.scheme != 'https') return null;
    if (target.scheme != site.scheme ||
        target.host != site.host ||
        target.port != site.port) {
      return null;
    }
    var base = site.path;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    final path = target.path;
    if (base.isEmpty) return path;
    return path.startsWith('$base/') ? path.substring(base.length) : null;
  }

  @override
  bool operator ==(Object other) =>
      other is ForumMediaAuth &&
      other.siteUrl == siteUrl &&
      mapEquals(other.credentials, credentials);

  @override
  int get hashCode => Object.hash(
        siteUrl,
        Object.hashAllUnordered(credentials.keys),
        Object.hashAllUnordered(credentials.values),
      );
}

/// A video or audio address ready for a player, with the headers to play it
/// with.
@immutable
class PlayableMedia {
  const PlayableMedia(this.url, [this.headers = const {}]);

  final Uri url;
  final Map<String, String> headers;
}

/// Fetches the forum's media with [ForumMediaAuth]'s rules.
///
/// Redirects are followed here, one hop at a time, rather than by the HTTP
/// client: dart:io copies custom headers onto every redirect, wherever it
/// leads, so a download stored on S3 (fof/upload can use it) would have
/// carried the token there. Each hop is judged on its own address, and a
/// download on the forum is asked for with the token.
class ForumMedia {
  ForumMedia._();

  /// Tests put a Dio with a fake adapter here.
  @visibleForTesting
  static Dio? debugDio;

  static const int _maxRedirects = 5;

  static Future<Dio> _dio() async {
    final override = debugDio;
    if (override != null) return override;
    await FCDioClient.instance.initialize();
    return FCDioClient.instance.dio;
  }

  /// Redirects and refusals come back as responses, so each hop is judged
  /// here instead of by the client.
  static Options _options(Map<String, String> headers, {ResponseType? responseType}) => Options(
        headers: headers,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        responseType: responseType,
      );

  /// Sends [send] to [url] and on through its redirects. With
  /// [stopOffForum], stops at the first address off the forum and returns
  /// its redirect (a player follows the rest on its own, and a signed S3
  /// address answers only the request it was signed for).
  static Future<({Response<T> response, Uri url, Map<String, String> headers})> _follow<T>(
    ForumMediaAuth? auth,
    String url,
    Future<Response<T>> Function(Uri url, Map<String, String> headers) send, {
    bool stopOffForum = false,
  }) async {
    var current = Uri.parse(url);
    for (var hop = 0;; hop++) {
      final key = auth?.headersFor(current.toString()) ?? const <String, String>{};
      final upFront = key.isNotEmpty && auth!.mustAuthenticate(current.toString());
      var sent = upFront ? key : const <String, String>{};
      var response = await send(current, sent);
      final refused = response.statusCode == 403 || response.statusCode == 404;
      if (!upFront && key.isNotEmpty && refused) {
        sent = key;
        response = await send(current, sent);
      }
      final status = response.statusCode ?? 0;
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (status < 300 || status >= 400 || location == null || location.isEmpty || hop >= _maxRedirects) {
        return (response: response, url: current, headers: sent);
      }
      final next = current.resolve(location);
      final onForum = auth?.headersFor(next.toString()).isNotEmpty ?? false;
      if (stopOffForum && !onForum) {
        return (response: response, url: next, headers: const <String, String>{});
      }
      current = next;
    }
  }

  /// GETs [url]'s bytes. The response's status says whether it worked.
  static Future<Response<List<int>>> getBytes(
    ForumMediaAuth? auth,
    String url, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final dio = await _dio();
    final result = await _follow<List<int>>(
      auth,
      url,
      (u, headers) => dio.getUri<List<int>>(
        u,
        options: _options(headers, responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      ),
    );
    return result.response;
  }

  /// Where a player should fetch [url] from, and with which headers.
  ///
  /// Players follow redirects themselves and keep their headers on the way,
  /// so the forum's hops are walked here first (HEAD requests, no body): a
  /// download that redirects off the forum plays from there with no token.
  /// Anything else — a guest, a public file, another site — plays as given.
  static Future<PlayableMedia> resolvePlayable(ForumMediaAuth? auth, String url) async {
    final given = Uri.parse(url);
    if (auth == null || auth.headersFor(url).isEmpty) return PlayableMedia(given);
    try {
      final dio = await _dio();
      final result = await _follow<void>(
        auth,
        url,
        (u, headers) => dio.headUri<void>(u, options: _options(headers)),
        stopOffForum: true,
      );
      return PlayableMedia(result.url, result.headers);
    } catch (e) {
      debugPrint('ForumMedia.resolvePlayable: $e');
      // The player gets its own chance, as before.
      return PlayableMedia(given);
    }
  }

  /// Downloads [url] into a file named [filename] in a fresh temporary
  /// folder, reporting progress as it goes. Throws when the forum does not
  /// hand the file over.
  static Future<File> download(
    ForumMediaAuth? auth,
    String url,
    String filename, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final dio = await _dio();
    final folder = await Directory.systemTemp.createTemp('forum_file_');
    final file = File('${folder.path}/${safeFileName(filename)}');
    try {
      final result = await _follow<dynamic>(
        auth,
        url,
        (u, headers) => dio.downloadUri(
          u,
          file.path,
          options: _options(headers),
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
        ),
      );
      final status = result.response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw FlarumApiException(status, const [], method: 'GET', path: result.url.path);
      }
      return file;
    } on DioException catch (e) {
      await folder.delete(recursive: true).catchError((_) => folder);
      if (CancelToken.isCancel(e)) rethrow;
      final timedOut = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      throw FlarumApiException(
        e.response?.statusCode,
        const [],
        method: 'GET',
        path: e.requestOptions.uri.path,
        cause: timedOut ? 'Timeout' : e.message,
      );
    } catch (_) {
      await folder.delete(recursive: true).catchError((_) => folder);
      rethrow;
    }
  }

  /// [name] as a file name any platform accepts: no path separators or
  /// control characters, never empty.
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
    return cleaned.isEmpty || cleaned == '.' || cleaned == '..' ? 'download' : cleaned;
  }
}
