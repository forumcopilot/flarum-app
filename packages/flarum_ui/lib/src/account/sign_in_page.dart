import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../app/flarum_host.dart';

/// The token in a forum's cookies after signing in on its page: the value of
/// the `<prefix>_remember` cookie, which Flarum sets only when "Remember me"
/// is ticked, and which the API accepts as a token.
({String token, String cookiePrefix})? rememberToken(Iterable<({String name, String value})> cookies) {
  for (final cookie in cookies) {
    if (cookie.name.endsWith('_remember') && cookie.name.length > '_remember'.length && cookie.value.isNotEmpty) {
      return (token: cookie.value, cookiePrefix: cookie.name.substring(0, cookie.name.length - '_remember'.length));
    }
  }
  return null;
}

/// Signing in on the forum's own page, in a web view: its log-in modal opens
/// with "Remember me" ticked (or its sign-up modal, for [signUp]), and the reader
/// signs in there (a CAPTCHA or an OAuth provider works as on the website). As
/// soon as the remember cookie appears, the page closes and the app is signed in
/// with it; Flarum sets it on sign-up too, before the email is confirmed. Pops
/// true when signed in.
///
/// The forum's cookies are cleared first, so an old web session can't stand
/// in for the sign-in. Proven on a Pixel in Phase 0 (tool/spikes/signin_app).
///
/// [open] signs in through the forum's Flapp page in the phone's browser
/// instead, where the forum runs the Flapp extension and the host takes part
/// ([FlarumHost.browserSignIn]).
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.site, this.signUp = false});

  final SiteContext site;

  /// Opens the forum's sign-up modal rather than its log-in modal.
  final bool signUp;

  /// Signs the reader in; true once they are. [signUp] starts with the forum's
  /// sign-up, where the page in the app is used.
  static Future<bool> open(BuildContext context, SiteContext site, {bool signUp = false}) async {
    final host = FlarumHost.browserSignIn;
    if (host != null) {
      final info = await _forumInfo(site);
      if (info?.flappSignIn case final signIn? when context.mounted) {
        final signedIn = await _signInInBrowser(context, site, signIn, host);
        if (signedIn != null) return signedIn;
      }
    }
    if (!context.mounted) return false;
    return await Navigator.of(context).push<bool>(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => SignInPage(site: site, signUp: signUp),
        )) ??
        false;
  }

  /// Stands in for the browser's sign-in sheet in tests: gets the page's
  /// address and the callback scheme, completes with the callback address.
  @visibleForTesting
  static Future<String> Function(String url, String callbackScheme)? debugAuthenticate;

  static bool get _hasSystemSheet =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

  /// The forum's info, read now if it hasn't been; null when the forum can't be reached, so the
  /// page in the app says why.
  static Future<FlarumForumInfo?> _forumInfo(SiteContext site) async {
    try {
      return await FlarumForum.of(site).current();
    } catch (_) {
      return null;
    }
  }

  /// Signs in through the forum's Flapp page in the browser's sign-in sheet
  /// (ASWebAuthenticationSession; a Chrome Custom Tab), as discourse_ui's
  /// DiscourseAuthSession signs in to Discourse. The forum's saved passwords,
  /// passkeys and Google's sign-in work there, a forum the browser is already
  /// signed in to only asks to Authorize, and a new account comes back signed
  /// in. The session shares the browser's sign-ins (not ephemeral).
  ///
  /// True when signed in; false when the reader backed out, or it failed (said
  /// in a snack bar); null when the sheet can't open here, for the page in the
  /// app instead.
  static Future<bool?> _signInInBrowser(
      BuildContext context, SiteContext site, FlappSignInInfo info, ({String app, String callbackScheme}) host) async {
    final authenticate = debugAuthenticate ??
        (_hasSystemSheet
            ? (String url, String scheme) => FlutterWebAuth2.authenticate(
                  url: url,
                  callbackUrlScheme: scheme,
                  options: const FlutterWebAuth2Options(preferEphemeral: false),
                )
            : null);
    if (authenticate == null) return null;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = flarumL10n(context);
    try {
      final request = await _whileWorking(context, FlappSignInRequest.create(info, app: host.app));
      final String callback;
      try {
        callback = await authenticate(request.url.toString(), host.callbackScheme);
      } on PlatformException catch (e) {
        if (e.code == 'CANCELED') return false;
        debugPrint('SignInPage: the browser sign-in sheet is unavailable (${e.code}: ${e.message}); using the page in the app');
        return null;
      }
      final result = request.complete(Uri.parse(callback));
      if (result == null || !context.mounted) return false;
      await _whileWorking(
          context, FlarumUserProxy.completeSignIn(site, result.token, cookiePrefix: result.cookiePrefix));
      return true;
    } catch (e) {
      if (context.mounted) messenger?.showSnackBar(SnackBar(content: Text(l10n.signInFailedReason(describeError(context, e)))));
      return false;
    }
  }

  /// [work], with a spinner over the app until it's done: making the sign-in's key takes a
  /// second or so, and checking the sign-in with the forum a moment.
  static Future<T> _whileWorking<T>(BuildContext context, Future<T> work) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
    );
    unawaited(navigator.push(route));
    try {
      return await work;
    } finally {
      navigator.removeRoute(route);
    }
  }

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Timer? _poll;
  bool _cleared = false;
  bool _done = false;
  String? _error;

  /// Set when the page headed for Google's sign-in, which refuses an app's web view.
  bool _googleRefused = false;

  InAppWebViewController? _web;

  /// Set once the forum's page has drawn: until then a cover in the app's own colours stands
  /// over the web view, which was a white flash in dark mode.
  bool _shown = false;

  void _drawn() {
    if (!_shown && mounted) setState(() => _shown = true);
  }

  /// Back goes back in the page's history first (a Google or GitHub log-in page, Forgot
  /// password), then out of the page.
  Future<void> _back() async {
    final web = _web;
    if (web != null && await web.canGoBack()) {
      await web.goBack();
    } else if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  WebUri get _url => WebUri(widget.site.site.url);

  @override
  void initState() {
    super.initState();
    _clear();
  }

  Future<void> _clear() async {
    await CookieManager.instance().deleteCookies(url: _url);
    if (!mounted) return;
    setState(() => _cleared = true);
    _poll = Timer.periodic(const Duration(milliseconds: 500), (_) => _check());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_done) return;
    final cookies = await CookieManager.instance().getCookies(url: _url);
    final found = rememberToken([for (final c in cookies) (name: c.name, value: '${c.value ?? ''}')]);
    if (found == null || _done) return;
    _done = true;
    _poll?.cancel();
    try {
      await FlarumUserProxy.completeSignIn(widget.site, found.token, cookiePrefix: found.cookiePrefix);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context, e));
    }
  }

  /// Google refuses sign-in inside an app's web view (`disallowed_useragent`): rather than leave
  /// the reader on its error page, say so and go back to the forum's page.
  Future<void> _loadStarted(InAppWebViewController controller, WebUri? url) async {
    if (url?.host != 'accounts.google.com') return;
    if (mounted) setState(() => _googleRefused = true);
    await controller.stopLoading();
    if (await controller.canGoBack()) await controller.goBack();
  }

  Future<void> _start(InAppWebViewController controller, WebUri? url) async {
    _drawn();
    await controller.evaluateJavascript(source: await rootBundle.loadString('packages/flarum_ui/assets/signin.js'));
    await controller.evaluateJavascript(source: 'window.flarumAppSignIn.start(null, ${widget.signUp})');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final error = _error;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.signUp ? l10n.createAccount : l10n.signIn)),
        body: Column(
          children: [
            if (error != null)
              MaterialBanner(
                content: Text(l10n.signInFailedReason(error)),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel))],
              ),
            if (_googleRefused)
              MaterialBanner(
                content: Text(FlarumHost.browserSignIn == null ? l10n.googleSignInRefused : l10n.googleSignInNeedsExtension),
                actions: [TextButton(onPressed: () => setState(() => _googleRefused = false), child: Text(l10n.ok))],
              ),
            Expanded(
              child: Stack(
                children: [
                  if (_cleared)
                    InAppWebView(
                      initialUrlRequest: URLRequest(url: _url),
                      initialSettings: InAppWebViewSettings(transparentBackground: true),
                      onWebViewCreated: (controller) => _web = controller,
                      onPageCommitVisible: (_, __) => _drawn(),
                      onLoadStart: _loadStarted,
                      onLoadStop: _start,
                    ),
                  IgnorePointer(
                    ignoring: _shown,
                    child: AnimatedOpacity(
                      opacity: _shown ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: ColoredBox(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
