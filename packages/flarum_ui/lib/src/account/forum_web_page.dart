import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/links.dart';

/// The cookie that keeps a browser logged in to the forum as the reader: their token as Flarum's
/// "Remember me" cookie (`<prefix>_remember`), as the web view handed it over at Log In. Null for
/// a guest.
({String name, String value})? rememberCookie(FlarumForum forum) {
  final token = forum.api.client.token;
  if (token == null) return null;
  return (name: '${forum.api.client.cookiePrefix}_remember', value: token);
}

/// Forgets the forum's login in the app's web view, after Log Out: a page opened in it later
/// opens as a guest's.
Future<void> forgetWebLogin(SiteContext site) async {
  try {
    await CookieManager.instance().deleteCookies(url: WebUri(site.site.url));
  } catch (e) {
    debugPrint('forgetWebLogin: $e');
  }
}

/// A page of the forum's website in the app, logged in as the reader, for what the app has no
/// screen of its own for: the forum's settings (email, password, privacy). Chrome, where the
/// reader usually isn't logged in, showed "You do not have permission to access this page".
/// Back goes back in the page first; the top bar opens it in the browser.
class ForumWebPage extends StatefulWidget {
  const ForumWebPage({super.key, required this.site, required this.path, required this.title});

  final SiteContext site;

  /// The page's path on the forum, `/settings`.
  final String path;
  final String title;

  static Future<void> open(BuildContext context, SiteContext site, {required String path, required String title}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ForumWebPage(site: site, path: path, title: title)));

  /// For tests, which have no web view: what stands in for it, given the address and the cookie.
  @visibleForTesting
  static Widget Function(Uri url, ({String name, String value})? cookie)? webViewForTesting;

  @override
  State<ForumWebPage> createState() => _ForumWebPageState();
}

class _ForumWebPageState extends State<ForumWebPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  InAppWebViewController? _web;
  bool _ready = false;

  /// Set once the page has drawn: until then a cover in the app's colours stands over the web view.
  bool _shown = false;

  Uri get _url => Uri.parse('${widget.site.site.url.replaceAll(RegExp(r'/+$'), '')}${widget.path}');

  @override
  void initState() {
    super.initState();
    _logIn();
  }

  /// The reader's login, set as the page's cookie before it loads.
  Future<void> _logIn() async {
    final cookie = rememberCookie(_forum);
    if (ForumWebPage.webViewForTesting == null && cookie != null) {
      final base = Uri.parse(widget.site.site.url);
      try {
        await CookieManager.instance().setCookie(
          url: WebUri(widget.site.site.url),
          name: cookie.name,
          value: cookie.value,
          path: base.path.isEmpty ? '/' : base.path,
          isSecure: base.scheme == 'https',
          isHttpOnly: true,
        );
      } catch (e) {
        debugPrint('ForumWebPage: $e');
      }
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _back() async {
    final web = _web;
    if (web != null && await web.canGoBack()) {
      await web.goBack();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _drawn() {
    if (!_shown && mounted) setState(() => _shown = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final testing = ForumWebPage.webViewForTesting;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: l10n.viewOnWeb,
              onPressed: () => openExternally('$_url'),
            ),
          ],
        ),
        body: !_ready
            ? const Center(child: CircularProgressIndicator())
            : testing != null
                ? testing(_url, rememberCookie(_forum))
                : Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(url: WebUri('$_url')),
                        initialSettings: InAppWebViewSettings(transparentBackground: true),
                        onWebViewCreated: (controller) => _web = controller,
                        onPageCommitVisible: (_, __) => _drawn(),
                        onLoadStop: (_, __) => _drawn(),
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
    );
  }
}
