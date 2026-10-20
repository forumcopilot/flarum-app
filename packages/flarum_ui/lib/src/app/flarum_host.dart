import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../config/app_forum_config.dart';
import '../../l10n/flarum_l10n.dart';
import 'forum_theme.dart';
import '../render/flarum_content.dart';

/// What an app that holds many forums (Flapp) needs to host flarum_ui's
/// screens, as ABDA hosts discourse_ui's. The single-forum [FlarumApp] uses
/// the same pieces.
///
/// A host calls [ensureInitialized] once before `runApp`, gives its
/// `MaterialApp` [localizationsDelegates] and [supportedLocales] and builds
/// its themes from [FlarumForumTheme.current], and opens a forum by pushing
/// a [FlarumForumPage] with the forum's [site]. Everything below that page
/// is flarum_ui. Each forum keeps its own sign-in, caches and colours,
/// keyed by its address.
abstract final class FlarumHost {
  /// The SDK, Flarum's proxies, relative times, the forums' colours
  /// remembered from earlier runs, and a post that fails to draw shown as its
  /// text rather than Flutter's grey error box ([installPostBodyErrorFallback]).
  static Future<void> ensureInitialized() async {
    initializeTimeAgo();
    await ForumcopilotSdk.ensureInitialized();
    FlarumProxyFactory.register();
    await FlarumForumTheme.loadRemembered();
    if (!_fallbackInstalled) {
      installPostBodyErrorFallback();
      _fallbackInstalled = true;
    }
  }

  static bool _fallbackInstalled = false;

  /// The localizations flarum_ui's screens use, for the host's `MaterialApp`
  /// (with the host's own in front, if it has any).
  static const List<LocalizationsDelegate<Object>> localizationsDelegates = [
    FlarumLocalizations.delegate,
    KitLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// The languages flarum_ui's screens are translated into.
  static List<Locale> get supportedLocales => FlarumLocalizations.supportedLocales;

  /// The SDK's description of the forum at [url] (scheme, host and any
  /// folder), called [name] until its own title has loaded.
  static Site site({required String name, required String url}) =>
      AppForumConfig(name: name, baseUrl: url).toSite();
}
