import 'package:dio/dio.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../flarum_api.dart';
import '../flarum_client.dart';
import '../models/forum_info.dart';
import '../models/tag.dart';
import 'flarum_extensions.dart';
import 'flarum_token_store.dart';

/// One Flarum forum as the app knows it: its API client (with the reader's
/// token once signed in), and what its last `GET /api` said. Shared by every
/// proxy for that forum, keyed by the forum's address.
class FlarumForum {
  FlarumForum._(this.baseUrl, {Dio? dio}) : api = FlarumApi(FlarumClient(baseUrl, dio: dio));

  static final Map<String, FlarumForum> _forums = {};

  /// The forum [site] points at.
  static FlarumForum of(SiteContext site) => forUrl(site.site.pluginUrl);

  static FlarumForum forUrl(String url) {
    final key = _normalise(url);
    return _forums[key] ??= FlarumForum._(key);
  }

  /// Replaces the forum at [url] with one whose requests go through [dio], for tests.
  static FlarumForum forTesting(String url, Dio dio) {
    final key = _normalise(url);
    return _forums[key] = FlarumForum._(key, dio: dio);
  }

  static void resetForTesting() => _forums.clear();

  final String baseUrl;
  final FlarumApi api;

  /// What the last [refresh] read, or null before the first.
  FlarumForumInfo? info;

  FlarumVersion? get version => info?.version;

  /// What [info] reveals; empty until it's loaded. Use [currentExtensions]
  /// unless [current] or [refresh] has run.
  FlarumExtensions get extensions => FlarumExtensions(
        info?.attributes ?? const {},
        actorAttributes: info?.actorAttributes ?? const {},
      );

  /// Reads `GET /api` again and keeps it.
  Future<FlarumForumInfo> refresh() async => info = await api.forumInfo();

  /// The info from the last [refresh], fetching it if there is none yet.
  Future<FlarumForumInfo> current() async => info ?? await refresh();

  /// The forum's extensions, loading its info first if needed.
  Future<FlarumExtensions> currentExtensions() async {
    await current();
    return extensions;
  }

  bool get isSignedIn => api.client.token != null;

  /// Picks up the sign-in kept from an earlier launch, if any. Call before the
  /// first request for this forum.
  Future<void> restoreSession() async {
    final saved = await FlarumTokenStore.instance.read(baseUrl);
    if (saved == null) return;
    api.client
      ..token = saved.token
      ..cookiePrefix = saved.cookiePrefix;
  }

  /// Signs in with a token captured from the forum (the web view's
  /// `<prefix>_remember` cookie, or `POST /api/token`). The token is checked
  /// against `GET /api` before it is kept; a token the forum doesn't accept
  /// throws [StateError] and leaves the forum signed out.
  Future<FlarumForumInfo> signIn(String token, {String cookiePrefix = 'flarum'}) async {
    api.client
      ..token = token
      ..cookiePrefix = cookiePrefix;
    try {
      final info = await refresh();
      if (info.actor == null) throw StateError('The forum did not accept this sign-in');
      await FlarumTokenStore.instance.write(baseUrl, (token: token, cookiePrefix: cookiePrefix));
      return info;
    } catch (_) {
      api.client.token = null;
      rethrow;
    }
  }

  /// Revokes the token on the forum and forgets it here, then reads the forum
  /// again as a guest. Returns whether the forum confirmed the revoke; the
  /// local sign-out happens either way.
  Future<bool> signOut() async {
    var revoked = false;
    try {
      revoked = await api.logOut();
    } catch (_) {
      // No network: still sign out here; the token stays valid on the forum.
    } finally {
      api.client.token = null;
      await FlarumTokenStore.instance.delete(baseUrl);
      _tags = null;
    }
    try {
      await refresh();
    } catch (_) {
      info = null;
    }
    return revoked;
  }

  List<FlarumTag>? _tags;

  /// Every tag the reader can see, read once and kept until [refresh] is true.
  Future<List<FlarumTag>> tags({bool refresh = false}) async =>
      (refresh ? null : _tags) ?? (_tags = await api.tags());

  static String _normalise(String url) => url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
