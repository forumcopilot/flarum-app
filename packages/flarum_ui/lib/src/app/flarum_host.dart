import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../config/app_forum_config.dart';
import '../../l10n/flarum_l10n.dart';
import '../account/forum_web_page.dart';
import '../render/flarum_content.dart';
import 'forum_prefs.dart';
import 'forum_theme.dart';

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

  /// Where a link in a post or message that leads off its forum goes first. A host with several
  /// forums opens another Flarum forum's link in the app and answers true; false, or no handler,
  /// opens it in the browser. Links the reader asked to see on the web (View on Web) don't come
  /// here.
  static Future<bool> Function(BuildContext context, String url)? openOtherForumLink;

  /// How this app signs in through a forum's Flapp page in the phone's browser, on forums running
  /// the Flapp extension (`flappSignIn`): the app's name as the extension lists it, and the link
  /// scheme the page returns to (Flapp: `flapp`, returning to `flapp://auth`). Null, as in
  /// flarum-app's own builds, signs in on the forum's page inside the app everywhere.
  static ({String app, String callbackScheme})? browserSignIn;

  /// A forum whose `GET /api` names another address than the one it was opened at: its `baseUrl`
  /// in [info], read as [FlarumForumPage] connects, before the forum is shown. A host that keeps
  /// forums by address checks that the new address answers as the same forum, moves what it keeps
  /// for it (and [moveForum] what flarum_ui keeps), and answers the forum's [site] at the new
  /// address, which the page then opens: after a move, requests other than GET don't follow the
  /// old address's redirect (a reply, signing in or out), so the forum works only at the new one.
  /// Null, or no handler (flarum-app's single forum, chosen at build time), stays where it was.
  static Future<Site?> Function(Site site, FlarumForumInfo info)? forumMoved;

  /// Carries what flarum_ui and flarum_core keep for the forum at [from] to [to], its new address:
  /// the reader's sign-in and the phone's push registration ([FlarumForum.move]), its colours
  /// ([FlarumForumTheme.move]), the welcome message hidden, recent searches and the people ignored.
  /// What [to] already has is kept. The web view's cookies for [from] are cleared: pages opened
  /// in it set the reader's login for the address they open ([ForumWebPage]).
  static Future<void> moveForum(String from, String to) async {
    await FlarumForum.move(from, to);
    await FlarumForumTheme.move(from, to);
    await ForumPrefs.move(from, to);
    await forgetWebLoginAt(from);
  }
}
