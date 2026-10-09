import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../config/app_forum_config.dart';
import '../../l10n/flarum_l10n.dart';
import 'app_shell.dart';
import 'appearance.dart';

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
    initializeTimeAgo();
    await ForumcopilotSdk.ensureInitialized();
    FlarumProxyFactory.register();
    final site = SiteContext(siteType: FlarumProxyFactory.siteType, site: config.toSite());
    SiteProxyFactory.initialize(site);
    final forum = FlarumForum.of(site);
    try {
      await forum.restoreSession();
      final info = await forum.current();
      AppTheme.palette.value = flarumPalette(info);
      if (info.actor != null) site.setLoginData(FlarumUserProxy.loginResult(info));
    } catch (_) {
      // Offline or the forum is down: the screens say so and retry.
    }
    return site;
  }

  /// Starts the app afresh on another forum (the debug forum switcher).
  /// Each forum keeps its own sign-in.
  Future<void> restartOn(AppForumConfig config) async {
    AppTheme.palette.value = null;
    final next = await initialize(config);
    runApp(FlarumApp(site: next, appearance: appearance));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appearance,
      builder: (context, mode, _) => _app(mode),
    );
  }

  Widget _app(ThemeMode mode) {
    return MaterialApp(
      title: site.site.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      localizationsDelegates: const [
        FlarumLocalizations.delegate,
        KitLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: FlarumLocalizations.supportedLocales,
      home: AppShell(site: site, appearance: appearance, onSwitchForum: restartOn),
    );
  }
}
