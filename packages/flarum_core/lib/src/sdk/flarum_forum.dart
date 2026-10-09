import 'package:dio/dio.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../flarum_api.dart';
import '../flarum_client.dart';
import '../models/forum_info.dart';
import '../models/tag.dart';
import 'flarum_extensions.dart';

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

  FlarumExtensions get extensions => FlarumExtensions(
        info?.attributes ?? const {},
        actorAttributes: info?.actorAttributes ?? const {},
      );

  /// Reads `GET /api` again and keeps it.
  Future<FlarumForumInfo> refresh() async => info = await api.forumInfo();

  /// The info from the last [refresh], fetching it if there is none yet.
  Future<FlarumForumInfo> current() async => info ?? await refresh();

  List<FlarumTag>? _tags;

  /// Every tag the reader can see, read once and kept until [refresh] is true.
  Future<List<FlarumTag>> tags({bool refresh = false}) async =>
      (refresh ? null : _tags) ?? (_tags = await api.tags());

  static String _normalise(String url) => url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
