import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';

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
/// with "Remember me" ticked, and the reader signs in there (a CAPTCHA or an
/// OAuth provider works as on the website). As soon as the remember cookie
/// appears, the page closes and the app is signed in with it. Pops true when
/// signed in.
///
/// The forum's cookies are cleared first, so an old web session can't stand
/// in for the sign-in. Proven on a Pixel in Phase 0 (tool/spikes/signin_app).
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.site});

  final SiteContext site;

  /// Opens the page; true once the reader is signed in.
  static Future<bool> open(BuildContext context, SiteContext site) async =>
      await Navigator.of(context).push<bool>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SignInPage(site: site),
      )) ??
      false;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Timer? _poll;
  bool _cleared = false;
  bool _done = false;
  String? _error;

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
      if (mounted) setState(() => _error = describeFlarumError(e));
    }
  }

  Future<void> _start(InAppWebViewController controller, WebUri? url) async {
    await controller.evaluateJavascript(source: await rootBundle.loadString('packages/flarum_ui/assets/signin.js'));
    await controller.evaluateJavascript(source: 'window.flarumAppSignIn.start(null)');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: Column(
        children: [
          if (error != null)
            MaterialBanner(
              content: Text(l10n.signInFailedReason(error)),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel))],
            ),
          Expanded(
            child: _cleared
                ? InAppWebView(
                    initialUrlRequest: URLRequest(url: _url),
                    onLoadStop: _start,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
