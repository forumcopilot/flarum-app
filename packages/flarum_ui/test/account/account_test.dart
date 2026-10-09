import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
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

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: the account tab shows who is signed in', (tester) async {
      FlarumForum.resetForTesting();
      FlarumTokenStore.instance = FlarumTokenStore.memory();
      final forum = FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.runAsync(forum.refresh);
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      expect(find.text('Signed in as @alice'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
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
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });
  }
}
