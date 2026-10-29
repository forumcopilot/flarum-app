import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Signing in through a forum's Flapp page (the Flapp extension) in the browser's sign-in sheet,
/// which SignInPage.debugAuthenticate stands in for.
void main() {
  late SiteContext site;
  late FlarumForum forum;

  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
    FlarumHost.browserSignIn = (app: 'flapp', callbackScheme: 'flapp');
    // The forum running the extension was recorded with bob signed in; a guest is told of the
    // same sign-in page, so its GET /api answers with that recording.
    const root = '../flarum_core/test/fixtures';
    final fixtures = FixtureForum(FlarumVersion.v2, root: root, states: {'flapp'});
    fixtures.replies['GET '] = (jsonDecode(File('$root/v2/flapp_forum.json').readAsStringSync()) as Map)['body'] as Object;
    forum = fixtures.forum(signedIn: false);
    site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );
  });

  tearDown(() {
    FlarumHost.browserSignIn = null;
    SignInPage.debugAuthenticate = null;
  });

  Future<bool?> signIn(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (c) {
      context = c;
      return const SizedBox();
    }))));
    final result = await tester.runAsync(() => SignInPage.open(context, site));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets("signs in with what the forum's page sends back, in the browser's sheet", (tester) async {
    final opened = <(Uri, String)>[];
    SignInPage.debugAuthenticate = (url, scheme) async {
      opened.add((Uri.parse(url), scheme));
      return flappSignInCallback(Uri.parse(url), token: 'browser-token').toString();
    };

    expect(await signIn(tester), isTrue);

    final [(url, scheme)] = opened;
    expect(scheme, 'flapp');
    expect(url.path, '/flapp/authorize');
    expect(url.queryParameters['app'], 'flapp');
    expect(forum.isSignedIn, isTrue);
    expect(forum.api.client.token, 'browser-token');
    // No spinner left over the app.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('signs in when the screen that asked is gone, as the drawer is once its Log In is tapped',
      (tester) async {
    late BuildContext drawer;
    final open = ValueNotifier(true);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: open,
          builder: (_, isOpen, __) => isOpen
              ? Builder(builder: (c) {
                  drawer = c;
                  return const SizedBox();
                })
              : const SizedBox(),
        ),
      ),
    ));
    SignInPage.debugAuthenticate = (url, scheme) async {
      open.value = false;
      await tester.pump();
      return flappSignInCallback(Uri.parse(url), token: 'browser-token').toString();
    };

    expect(await tester.runAsync(() => SignInPage.open(drawer, site)), isTrue);
    await tester.pumpAndSettle();
    expect(forum.isSignedIn, isTrue);
  });

  testWidgets("Cancel on the forum's page, or backing out of the sheet, signs no one in", (tester) async {
    SignInPage.debugAuthenticate = (url, scheme) async => 'flapp://auth?error=cancelled';
    expect(await signIn(tester), isFalse);
    expect(forum.isSignedIn, isFalse);

    SignInPage.debugAuthenticate = (url, scheme) async => throw PlatformException(code: 'CANCELED');
    expect(await signIn(tester), isFalse);
    expect(forum.isSignedIn, isFalse);
  });

  testWidgets('a sign-in made for another request is refused, and says so', (tester) async {
    SignInPage.debugAuthenticate = (url, scheme) async =>
        flappSignInCallback(Uri.parse(url), token: 'browser-token', nonce: 'another-request-nonce').toString();

    expect(await signIn(tester), isFalse);
    expect(forum.isSignedIn, isFalse);
    expect(find.textContaining("Couldn't log in"), findsOneWidget);
  });
}
