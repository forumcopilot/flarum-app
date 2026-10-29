import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Puts the open forum's colours on a multi-forum app, as discourse_ui's
/// ForumTheme does for ABDA.
///
/// [FlarumForumPage] calls [enter] when a forum opens and [leave] when it
/// closes; the innermost open forum's palette is [current] (and forum_kit's
/// [AppTheme.palette]), and there is none outside a forum, so the host's own
/// screens keep the host's colours. A host builds its `MaterialApp` themes
/// from [current]. Forums are keyed by their address.
///
/// Palettes are remembered on the phone, so a forum opens in its own colours
/// at once rather than the app's until its `GET /api` answers. A host that
/// knows a forum's colours before it was ever opened (a directory) gives
/// them with [update].
abstract final class FlarumForumTheme {
  static const _prefsKey = 'flarum_forum_palettes';

  /// Enough for every forum a reader keeps coming back to; older ones are dropped first.
  static const _remembered = 50;

  // Insertion-ordered: the most recently updated forum is last.
  static final Map<String, ForumPalette> _palettes = {};
  static final List<String> _open = [];
  static final ValueNotifier<ForumPalette?> _current = ValueNotifier(null);
  static Future<void>? _applying;

  /// The open forum's palette, or null when no forum is open (or it has no
  /// colours of its own).
  static ValueListenable<ForumPalette?> get current => _current;

  /// The palette of the forum at [url], when known.
  static ForumPalette? paletteFor(String url) => _palettes[_key(url)];

  /// Loads the palettes remembered on the phone. A host awaits it before its first frame.
  static Future<void> loadRemembered() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw);
      if (json is! Map) return;
      for (final e in json.entries) {
        // A palette learned this run is newer than the stored one. Earlier versions stored
        // Discourse's stock dark scheme with each palette; it's dropped ([flarumPalette] has none).
        if (ForumPalette.fromJson(e.value)?.light case final light?) {
          _palettes.putIfAbsent('${e.key}', () => ForumPalette(light: light));
        }
      }
      await _apply();
    } catch (e) {
      debugPrint('FlarumForumTheme: remembered palettes unreadable: $e');
    }
  }

  /// The forum at [url] is now on screen. The app-wide change lands when the
  /// returned future completes (see [_apply]).
  static Future<void> enter(String url) {
    _open.add(_key(url));
    return _apply();
  }

  /// The forum at [url] has closed.
  static Future<void> leave(String url) {
    final i = _open.lastIndexOf(_key(url));
    if (i >= 0) _open.removeAt(i);
    return _apply();
  }

  /// Records [palette] as the colours of the forum at [url], applies it if
  /// that forum is open, and remembers it. Null forgets them: a forum that
  /// sets no colours of its own.
  static Future<void> update(String url, ForumPalette? palette) async {
    final key = _key(url);
    final unchanged = _palettes[key] == palette;
    _palettes.remove(key);
    if (palette != null) _palettes[key] = palette;
    while (_palettes.length > _remembered) {
      _palettes.remove(_palettes.keys.first);
    }
    await _apply();
    if (unchanged) return;
    try {
      await (await SharedPreferences.getInstance())
          .setString(_prefsKey, jsonEncode(_palettes.map((k, v) => MapEntry(k, v.toJson()))));
    } catch (e) {
      debugPrint('FlarumForumTheme: palette not remembered: $e');
    }
  }

  // enter/leave run from a page's initState/dispose, mid-build, where the
  // host's theme builder (an ancestor) must not be marked dirty. A microtask
  // runs after the build that queued it, so the app-wide change waits for one;
  // the forum's page themes itself meanwhile.
  static Future<void> _apply() => _applying ??= Future.microtask(() {
        _applying = null;
        final palette = _open.isEmpty ? null : _palettes[_open.last];
        _current.value = palette;
        AppTheme.palette.value = palette;
      });

  static String _key(String url) {
    var key = url.trim();
    while (key.endsWith('/')) {
      key = key.substring(0, key.length - 1);
    }
    return key;
  }

  @visibleForTesting
  static void reset() {
    _palettes.clear();
    _open.clear();
    _applying = null;
    _current.value = null;
    AppTheme.palette.value = null;
  }
}
