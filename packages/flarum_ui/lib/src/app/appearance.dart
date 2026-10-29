import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The forum's colours as the app's palette: Flarum's primary colour is the
/// accent (links, buttons, the selected tab), its secondary the navigation
/// accent, on the kit's stock light scheme; the kit keeps the accent legible.
/// Null when the forum sets none.
///
/// No dark scheme: Flarum has none to give, so dark mode is the kit's, as
/// ABDA's for a Discourse forum without one (Material's dark neutral, with
/// a hint of the accent). Discourse's stock "Dark" stood in for it before,
/// and kept every Flarum forum on its #222 grey.
ForumPalette? flarumPalette(FlarumForumInfo info) => flarumPaletteOf(info.primaryColor, info.secondaryColor);

/// [flarumPalette] from the two colours alone, as a host's directory keeps
/// them (hex, with or without the `#`), for a forum not yet opened.
ForumPalette? flarumPaletteOf(String? primary, String? secondary) {
  if (primary == null || primary.trim().isEmpty) return null;
  return ForumPalette(light: DiscourseScheme.fromHex({'tertiary': primary, 'quaternary': secondary ?? primary}));
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
