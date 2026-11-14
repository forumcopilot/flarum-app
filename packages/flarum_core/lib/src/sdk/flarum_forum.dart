import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../flarum_api.dart';
import '../flarum_client.dart';
import '../flarum_exception.dart';
import '../models/forum_info.dart';
import '../models/tag.dart';
import 'flarum_extensions.dart';
import 'flarum_push.dart';
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

  /// Whether [a] and [b] are one forum's address, whatever the spelling: the host's case, a
  /// default port, a trailing slash. The scheme counts: http and https are two addresses.
  static bool sameAddress(String a, String b) {
    final (x, y) = (Uri.tryParse(a.trim()), Uri.tryParse(b.trim()));
    if (x == null || y == null) return a.trim() == b.trim();
    String path(Uri u) => u.path.replaceAll(RegExp(r'/+$'), '');
    return x.scheme.toLowerCase() == y.scheme.toLowerCase() &&
        x.host.toLowerCase() == y.host.toLowerCase() &&
        x.port == y.port &&
        path(x) == path(y);
  }

  /// Keeps what is kept for the forum at [from] under [to], for a forum that has moved to a new
  /// address: the reader's sign-in ([FlarumTokenStore]) and the phone's push registration
  /// ([FlarumPush.move]). It is the same install, so its token still signs the reader in there; the
  /// host checks that once the forum answers at [to], and signs out if it doesn't. Whatever [to]
  /// already has is kept and [from]'s copy dropped, so the forum is never kept under both. The
  /// forum at [from] is forgotten for this run: [forUrl] gives a fresh one, signed out.
  static Future<void> move(String from, String to) async {
    final source = _normalise(from);
    final target = _normalise(to);
    if (source == target) return;
    final tokens = FlarumTokenStore.instance;
    if (await tokens.read(source) case final saved?) {
      if (await tokens.read(target) == null) await tokens.write(target, saved);
      await tokens.delete(source);
    }
    try {
      await FlarumPush.move(source, target);
    } on Object catch (e) {
      // The phone registers again at the new address, at the next sign-in or launch.
      debugPrint('FlarumForum: push registration not moved from $source: $e');
    }
    _forums.remove(source);
  }

  final String baseUrl;
  final FlarumApi api;

  /// What the last [refresh] read, or null before the first.
  FlarumForumInfo? get info => _info;
  set info(FlarumForumInfo? value) {
    _info = value;
    _infoChanges.value++;
  }

  FlarumForumInfo? _info;
  final _infoChanges = ValueNotifier(0);

  /// Notifies whenever [info] is read again ([refresh], a sign-in or sign-out), from wherever: the
  /// badges counting what's unread follow it.
  Listenable get infoChanges => _infoChanges;

  final _discussionChanges = StreamController<String>.broadcast();

  /// The id of each discussion the reader has just changed (read in, replied to, followed,
  /// bookmarked), once the forum has it: every list of this forum's discussions shows that row
  /// again, wherever the discussion was opened from.
  Stream<String> get discussionChanges => _discussionChanges.stream;

  /// Says discussion [id] has changed for the reader ([discussionChanges]).
  void discussionChanged(String id) => _discussionChanges.add(id);

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

  /// Reads the forum with the sign-in kept for it and signs out ([signOut]) if the forum doesn't
  /// know the token: for a sign-in [move]d to the forum's new address, so the reader is either
  /// signed in there or plainly signed out, never shown as signed in to a forum that reads them as
  /// a guest. A forum that doesn't answer changes nothing; the next launch asks again.
  Future<void> recheckSession() async {
    await restoreSession();
    if (!isSignedIn) return;
    final FlarumForumInfo info;
    try {
      info = await refresh();
    } on FlarumApiException catch (e) {
      debugPrint('FlarumForum: sign-in at $baseUrl not checked: $e');
      return;
    }
    if (info.actor == null) await signOut();
  }

  /// Signs in with a token captured from the forum (the web view's
  /// `<prefix>_remember` cookie, or `POST /api/token`). The token is checked
  /// against `GET /api` before it is kept; a token the forum doesn't accept
  /// throws [StateError] and leaves the forum signed out.
  Future<FlarumForumInfo> signIn(String token, {String cookiePrefix = 'flarum'}) async {
    api.client
      ..token = token
      ..cookiePrefix = cookiePrefix;
    // The tags were read as a guest: where the reader may start a discussion is theirs now.
    _tags = null;
    try {
      final info = await refresh();
      if (info.actor == null) throw StateError('The forum did not accept this sign-in');
      await FlarumTokenStore.instance.write(baseUrl, (token: token, cookiePrefix: cookiePrefix));
      // Pushes, where the forum runs the Flapp extension; the sign-in doesn't wait for it.
      unawaited(FlarumPush.registerQuietly(this));
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
    // While the token still works: the forum deletes the phone's device and the relay its handle.
    await FlarumPush.unregister(this).timeout(const Duration(seconds: 5), onTimeout: () {});
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
