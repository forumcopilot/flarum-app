import 'package:flutter/material.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../config/app_forum_config.dart';
import 'app_shell.dart';
import 'appearance.dart';
import 'flarum_forum_page.dart';
import 'flarum_host.dart';
import 'forum_theme.dart';

/// The single-forum app: the forum in [site], in its colours, light or dark
/// as the reader chose, in the languages flarum_ui has.
class FlarumApp extends StatelessWidget {
  FlarumApp({super.key, required this.site, Appearance? appearance})
      : appearance = appearance ?? Appearance.unsaved();

  final SiteContext site;
  final Appearance appearance;

  /// Everything the app needs before its first frame: the SDK's HTTP client,
  /// Flarum's proxies, and the reader's sign-in from the last launch. Returns
  /// the forum's [SiteContext].
  static Future<SiteContext> initialize(AppForumConfig config) async {
    await FlarumHost.ensureInitialized();
    final site = await FlarumForumPage.connect(config.toSite());
    await FlarumForumTheme.enter(site.site.pluginUrl);
    return site;
  }

  /// Starts the app afresh on another forum (the debug forum switcher).
  /// Each forum keeps its own sign-in.
  Future<void> restartOn(AppForumConfig config) async {
    await FlarumForumTheme.leave(site.site.pluginUrl);
    final next = await initialize(config);
    runApp(FlarumApp(site: next, appearance: appearance));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appearance,
      builder: (context, mode, _) => ValueListenableBuilder(
        valueListenable: FlarumForumTheme.current,
        builder: (context, palette, _) => _app(mode, palette),
      ),
    );
  }

  Widget _app(ThemeMode mode, ForumPalette? palette) {
    return MaterialApp(
      // Keyed by the forum: after the switcher's runApp, every screen starts afresh on the new one
      // instead of keeping the state (and the forum) it was built with.
      key: ObjectKey(site),
      title: site.site.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(Brightness.light, palette),
      darkTheme: AppTheme.themeFor(Brightness.dark, palette),
      themeMode: mode,
      localizationsDelegates: FlarumHost.localizationsDelegates,
      supportedLocales: FlarumHost.supportedLocales,
      home: AppShell(site: site, appearance: appearance, onSwitchForum: restartOn),
    );
  }
}
