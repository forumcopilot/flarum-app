// Phase 0 spike: sign in to a Flarum forum through an in-app web view, capture
// the long-lived <prefix>_remember cookie, use it as the API token, then sign
// out by revoking it. Every step is logged with the prefix SIGNIN_SPIKE, so a
// run can be followed with `adb logcat | grep SIGNIN_SPIKE`.
//
// Build with --dart-define=FLARUM_TEST_USER=… --dart-define=FLARUM_TEST_PASSWORD=…
// to have the log-in form filled in; the "Log In" tap is always the reader's.

import 'dart:async';
import 'dart:convert';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const _testUser = String.fromEnvironment('FLARUM_TEST_USER');
const _testPassword = String.fromEnvironment('FLARUM_TEST_PASSWORD');

/// The test forums, reached on the phone through `adb reverse`.
const _forums = {
  'http://127.0.0.1:8081': 'Flarum 1.8 · Turnstile',
  'http://127.0.0.1:8082': 'Flarum 2.0',
};

void main() => runApp(const SpikeApp());

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flarum sign-in spike',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF3B5A85)),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _url = TextEditingController(text: _forums.keys.first);
  final _log = <String>[];
  FlarumApi? _api;
  bool _busy = false;

  void _write(String message) {
    debugPrint('SIGNIN_SPIKE: $message');
    if (mounted) setState(() => _log.add(message));
  }

  Future<void> _run(Future<void> Function() step) async {
    setState(() => _busy = true);
    try {
      await step();
    } catch (e) {
      _write('error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signIn() => _run(() async {
        final baseUrl = _url.text.trim().replaceAll(RegExp(r'/+$'), '');
        final navigator = Navigator.of(context);
        _write('--- sign in to $baseUrl');
        await CookieManager.instance().deleteAllCookies();
        final result = await navigator.push<SignInResult>(
          MaterialPageRoute(builder: (_) => SignInPage(baseUrl: baseUrl, log: _write)),
        );
        if (result == null) {
          _write('closed without a remember cookie');
          return;
        }
        _write('captured ${result.cookieName} (${result.token.substring(0, 6)}…) '
            '${result.elapsed.inMilliseconds} ms after opening the page');

        final api = FlarumApi(FlarumClient(baseUrl, token: result.token, cookiePrefix: result.prefix));
        final info = await api.forumInfo();
        _write('GET /api with it: Flarum ${info.version.name}, signed in as ${info.actor?.username ?? 'nobody'}');
        if (info.actor != null) setState(() => _api = api);
      });

  Future<void> _signOut() => _run(() async {
        final api = _api!;
        final token = api.client.token!;
        _write('--- sign out of ${api.client.baseUrl}');
        _write('logOut revoked the token: ${await api.logOut()}');
        try {
          await FlarumApi(FlarumClient(api.client.baseUrl, token: token)).notifications();
          _write('FAIL: the old token still works');
        } on FlarumApiException catch (e) {
          _write('old token now gets HTTP ${e.statusCode}${e.isUnauthorized ? ': revoked' : ''}');
        }
        setState(() => _api = null);
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Flarum sign-in spike')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final MapEntry(key: url, value: label) in _forums.entries)
                    ActionChip(label: Text(label), onPressed: () => _url.text = url),
                ],
              ),
              TextField(
                controller: _url,
                decoration: const InputDecoration(labelText: 'Forum address'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || _api != null ? null : _signIn,
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy || _api == null ? null : _signOut,
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final line in _log) SelectableText(line, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class SignInResult {
  const SignInResult({required this.token, required this.cookieName, required this.elapsed});

  final String token;
  final String cookieName;
  final Duration elapsed;

  /// The forum's cookie prefix (`cookie.name` in its config.php), e.g. `flarum`.
  String get prefix => cookieName.substring(0, cookieName.length - '_remember'.length);
}

/// The forum's own page in a web view, with its log-in modal opened and
/// "Remember me" ticked. Closes as soon as a `*_remember` cookie appears.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.baseUrl, required this.log});

  final String baseUrl;
  final void Function(String) log;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _opened = Stopwatch()..start();
  Timer? _poll;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(milliseconds: 500), (_) => _checkCookie());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkCookie() async {
    if (_done) return;
    final cookies = await CookieManager.instance().getCookies(url: WebUri(widget.baseUrl));
    for (final cookie in cookies) {
      final value = '${cookie.value ?? ''}';
      if (cookie.name.endsWith('_remember') && value.isNotEmpty) {
        _done = true;
        _poll?.cancel();
        if (mounted) {
          Navigator.of(context).pop(SignInResult(token: value, cookieName: cookie.name, elapsed: _opened.elapsed));
        }
        return;
      }
    }
  }

  Future<void> _inject(InAppWebViewController controller, WebUri? url) async {
    widget.log('page loaded: $url');
    await controller.evaluateJavascript(source: await rootBundle.loadString('assets/signin.js'));
    final fill = _testUser.isEmpty ? null : {'identification': _testUser, 'password': _testPassword};
    await controller.evaluateJavascript(source: 'window.flarumAppSignIn.start(${jsonEncode(fill)})');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.baseUrl)),
          onWebViewCreated: (controller) => controller.addJavaScriptHandler(
            handlerName: 'signinStatus',
            callback: (args) => widget.log('page: ${args.isEmpty ? '' : args.first}'),
          ),
          onLoadStop: _inject,
          onReceivedError: (controller, request, error) =>
              widget.log('load error ${error.type}: ${error.description} (${request.url})'),
        ),
      );
}
