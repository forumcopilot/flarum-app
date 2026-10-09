import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The forum's colours as the app's palette: Flarum's primary colour is the
/// accent (links, buttons, the selected tab), its secondary the navigation
/// accent; everything else is the kit's stock light and dark schemes, and
/// the kit keeps the accent legible in both. Null when the forum sets none.
ForumPalette? flarumPalette(FlarumForumInfo info) {
  final primary = info.primaryColor;
  if (primary == null) return null;
  final colours = {'tertiary': primary, 'quaternary': info.secondaryColor ?? primary};
  return ForumPalette(
    light: DiscourseScheme.fromHex(colours),
    dark: DiscourseScheme.fromHex(colours, fallback: DiscourseScheme.dark),
  );
}

/// Light, dark, or as the phone is: the reader's choice, kept on the phone.
class Appearance extends ValueNotifier<ThemeMode> {
  Appearance._(super.value);

  static const _key = 'flarum_app.theme_mode';

  /// The choice saved last time, or the phone's setting.
  static Future<Appearance> load() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      return Appearance._(ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.system);
    } catch (_) {
      return Appearance._(ThemeMode.system);
    }
  }

  /// An appearance that isn't saved: a test's, or the default when a host
  /// gives none.
  Appearance.unsaved([super.value = ThemeMode.system]);

  Future<void> choose(ThemeMode mode) async {
    value = mode;
    try {
      await (await SharedPreferences.getInstance()).setString(_key, mode.name);
    } catch (_) {
      // Kept for this run only.
    }
  }
}
