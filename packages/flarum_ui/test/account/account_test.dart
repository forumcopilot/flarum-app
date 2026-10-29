import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/account/forum_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  group('the remember cookie', () {
    test('is the token, and its name gives the forum\'s cookie prefix', () {
      expect(rememberToken([(name: 'flarum_session', value: 's'), (name: 'myforum_remember', value: 'abc')]),
          (token: 'abc', cookiePrefix: 'myforum'));
    });

    test('an empty one, or none, is no sign-in', () {
      expect(rememberToken([(name: 'flarum_remember', value: '')]), isNull);
      expect(rememberToken([(name: 'flarum_session', value: 's')]), isNull);
      expect(rememberToken([(name: '_remember', value: 'x')]), isNull);
    });
  });

  test('the forum\'s colours become the palette\'s accents', () {
    FlarumForumInfo info({String? primary, String? secondary}) => FlarumForumInfo(
          version: FlarumVersion.v2,
          baseUrl: 'https://forum.test',
          apiUrl: 'https://forum.test/api',
          title: 'x',
          attributes: const {},
          primaryColor: primary,
          secondaryColor: secondary,
        );
    final palette = flarumPalette(info(primary: '#4D698E', secondary: '#B72A2A'));
    expect(palette!.light!.tertiary, const Color(0xFF4D698E));
    expect(palette.light!.quaternary, const Color(0xFFB72A2A));
    // Dark mode is the kit's own, as ABDA's for a Discourse forum without a dark scheme: darker
    // than Discourse's stock "Dark" page, which every Flarum forum used to get.
    expect(palette.dark, isNull);
    final dark = AppTheme.themeFor(Brightness.dark, palette).colorScheme;
    expect(dark.surface.computeLuminance(), lessThan(DiscourseScheme.dark.secondary.computeLuminance()));
    expect(dark.secondaryContainer, isNot(DiscourseScheme.dark.selected), reason: 'not Discourse\'s teal');
    expect(flarumPalette(info()), isNull);
  });

  testWidgets('the appearance is chosen on the profile tab', (tester) async {
    FlarumForum.resetForTesting();
    FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures').forum(signedIn: false);
    final appearance = Appearance.unsaved();
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );
    await tester.pumpWidget(MaterialApp(home: AccountPage(site: site, appearance: appearance)));
    // A row that names the choice, which opens the choices in a sheet, as the Discourse app's.
    expect(find.text('System preference'), findsOneWidget);
    await tester.tap(find.text('Color Scheme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark Mode'));
    await tester.pump();
    expect(appearance.value, ThemeMode.dark);
  });

  testWidgets('another forum gets a fresh app, not the last forum\'s screens', (tester) async {
    FlarumForum.resetForTesting();
    FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures').forum(signedIn: false);
    SiteContext site() => SiteContext(
          siteType: FlarumProxyFactory.siteType,
          site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
        );
    await tester.pumpWidget(FlarumApp(site: site()));
    await tester.pump();
    final first = tester.state(find.byType(AppShell));
    await tester.pumpWidget(FlarumApp(site: site()));
    await tester.pump();
    expect(tester.state(find.byType(AppShell)), isNot(same(first)));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: the profile tab shows who is signed in', (tester) async {
      FlarumForum.resetForTesting();
      FlarumTokenStore.instance = FlarumTokenStore.memory();
      final forum = FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.runAsync(forum.refresh);
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      expect(find.text('Logged in as @alice'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'View Profile'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Edit Profile'), findsOneWidget);
      expect(find.text('Your Stuff'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Log Out'), 200);
      expect(find.text('Settings'), findsOneWidget, reason: 'the settings heading');
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Account and Privacy'), findsOneWidget);

      await tester.ensureVisible(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Are you sure you want to log out of'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Logged in as @alice'), findsOneWidget, reason: 'still logged in');
    });

    testWidgets(
        "Flarum ${version.name}: Account and Privacy opens the forum's settings page in the app, logged in as the reader",
        (tester) async {
      FlarumForum.resetForTesting();
      FlarumTokenStore.instance = FlarumTokenStore.memory();
      final forum = FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.runAsync(forum.refresh);
      final opened = <String>[];
      ForumWebPage.webViewForTesting = (url, cookie) {
        opened.add('$url ${cookie?.name}=${cookie?.value}');
        return const Text('the forum\'s page');
      };
      addTearDown(() => ForumWebPage.webViewForTesting = null);
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      await tester.scrollUntilVisible(find.text('Account and Privacy'), 200);
      await tester.tap(find.text('Account and Privacy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Email, Password and More'));
      await tester.pumpAndSettle();
      expect(find.text("the forum's page"), findsOneWidget);
      expect(opened.single, '${FixtureForum.baseUrl}/settings ${forum.api.client.cookiePrefix}_remember=${forum.api.client.token}',
          reason: "the reader's token as the forum's remember cookie: logged in, unlike in Chrome");
      expect(find.byTooltip('View on Web'), findsOneWidget);
    });

    testWidgets('Flarum ${version.name}: logged in but offline, the tab says so and offers Retry, not Log In',
        (tester) async {
      FlarumForum.resetForTesting();
      FlarumTokenStore.instance = FlarumTokenStore.memory();
      final fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures');
      fixtures.forum();
      fixtures.offline = true;
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Log In'), findsNothing);
      expect(find.text('Log Out'), findsOneWidget);
      fixtures.offline = false;
      await tester.tap(find.text('Retry'));
      for (var i = 0; i < 10 && find.text('Logged in as @alice').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Logged in as @alice'), findsOneWidget);
    });

    testWidgets('Flarum ${version.name}: a guest is offered sign-in', (tester) async {
      FlarumForum.resetForTesting();
      final forum = FixtureForum(version, root: '../flarum_core/test/fixtures').forum(signedIn: false);
      await tester.runAsync(forum.refresh);
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing, reason: 'the test forums take no sign-ups');
    });
  }

  testWidgets('a debug build can switch forums from the account tab', (tester) async {
    FlarumForum.resetForTesting();
    FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures').forum(signedIn: false);
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );
    AppForumConfig? chosen;
    await tester.pumpWidget(MaterialApp(
      home: AccountPage(site: site, onSwitchForum: (forum) async => chosen = forum),
    ));
    await tester.scrollUntilVisible(find.text('Forum (debug)'), 200);
    await tester.tap(find.text('Forum (debug)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flarum Community'));
    await tester.pumpAndSettle();
    expect(chosen?.baseUrl, 'https://discuss.flarum.org');
  });
}
