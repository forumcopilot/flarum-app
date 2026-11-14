import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The phone's preferences that belong to one forum, keyed by its address. A new one goes here, so
/// [FlarumHost.moveForum] carries it to a forum's new address.
abstract final class ForumPrefs {
  /// The welcome message the reader hid (its fingerprint).
  static String welcomeHidden(String forumUrl) => 'flarum_ui.welcome_hidden.$forumUrl';

  /// The reader's last searches.
  static String recentSearches(String forumUrl) => 'flarum_ui.recent_searches.$forumUrl';

  /// The people the reader ignores, where the forum keeps no list.
  static String ignoredUsers(String forumUrl) => 'flarum_ignored_users:$forumUrl';

  static const List<String Function(String)> _all = [welcomeHidden, recentSearches, ignoredUsers];

  /// Keeps [from]'s preferences under [to]; any [to] already has are kept, and [from]'s dropped.
  static Future<void> move(String from, String to) async {
    if (from == to) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _all) {
        final (source, target) = (key(from), key(to));
        final value = prefs.get(source);
        if (value == null) continue;
        if (!prefs.containsKey(target)) {
          switch (value) {
            case String():
              await prefs.setString(target, value);
            case List():
              await prefs.setStringList(target, value.cast<String>());
            case bool():
              await prefs.setBool(target, value);
            case int():
              await prefs.setInt(target, value);
            case double():
              await prefs.setDouble(target, value);
          }
        }
        await prefs.remove(source);
      }
    } catch (e) {
      debugPrint('ForumPrefs: not moved from $from: $e');
    }
  }
}
