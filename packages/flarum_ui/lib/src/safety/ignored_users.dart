import 'dart:convert';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whom the reader ignores on a forum: their posts are folded away. Where the forum runs
/// fof/ignore-users it keeps the list, and each post's author says whether they're ignored;
/// elsewhere the app keeps the list on the phone, so a reader can always put someone out of sight
/// (App Store guideline 1.2 asks apps with posts by others for a way to block).
class IgnoredUsers extends ChangeNotifier {
  IgnoredUsers._(this._url);

  static IgnoredUsers of(SiteContext site) => forUrl(site.site.pluginUrl);

  static IgnoredUsers forUrl(String url) {
    final key = FlarumForum.forUrl(url).api.client.baseUrl;
    return _all.putIfAbsent(key, () => IgnoredUsers._(key).._load());
  }

  static final _all = <String, IgnoredUsers>{};

  @visibleForTesting
  static void resetForTesting() => _all.clear();

  final String _url;

  FlarumForum get _forum => FlarumForum.forUrl(_url);

  String get _key => 'flarum_ignored_users:$_url';

  /// Changes made in the app, by user id: they outdate what the forum said with a post's author.
  final _changed = <String, bool>{};

  /// The phone's own list, by user id, where the forum keeps none.
  final _onPhone = <String, FlarumUser>{};

  /// Whether the forum keeps the list: fof/ignore-users, for a signed-in reader.
  bool get forumKeepsList => _forum.info?.ignoredUsers != null;

  bool isIgnored(FlarumUser? user) {
    if (user == null) return false;
    // A guest on a forum with fof/ignore-users is told no one is ignored: the phone's list counts.
    return forumKeepsList ? _changed[user.id] ?? user.ignored ?? false : _onPhone.containsKey(user.id);
  }

  /// Whether the reader may ignore [user]: anyone but themselves, and on a forum with
  /// fof/ignore-users whom it allows (not moderators, by default).
  bool canIgnore(FlarumUser? user) =>
      user != null && user.id != _forum.info?.actor?.id && (!forumKeepsList || (user.canBeIgnored ?? false));

  /// Ignores [user], or stops: on the forum where it keeps the list, else on the phone. Throws the
  /// forum's refusal.
  Future<void> setIgnored(FlarumUser user, bool ignored) async {
    if (forumKeepsList) {
      await _forum.api.setIgnored(user.id, ignored);
      _changed[user.id] = ignored;
      // Its list, for the Ignored users page.
      _forum.refresh().ignore();
    } else {
      if (ignored) {
        _onPhone[user.id] = user;
      } else {
        _onPhone.remove(user.id);
      }
      await _save();
    }
    notifyListeners();
  }

  /// Everyone the reader ignores: the forum's list, read again, or the phone's.
  Future<List<FlarumUser>> list() async {
    final info = await _forum.refresh();
    return info.ignoredUsers ?? [..._onPhone.values];
  }

  Future<void> _load() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      if (saved == null) return;
      for (final json in (jsonDecode(saved) as List).cast<Map<String, dynamic>>()) {
        final user = FlarumUser(
          id: json['id'] as String,
          username: json['username'] as String,
          displayName: json['displayName'] as String,
          slug: json['slug'] as String?,
          avatarUrl: json['avatarUrl'] as String?,
        );
        _onPhone[user.id] = user;
      }
      notifyListeners();
    } catch (_) {
      // A list that can't be read is an empty one.
    }
  }

  Future<void> _save() async {
    final users = [
      for (final user in _onPhone.values)
        {
          'id': user.id,
          'username': user.username,
          'displayName': user.displayName,
          'slug': user.slug,
          'avatarUrl': user.avatarUrl,
        },
    ];
    await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(users));
  }
}
