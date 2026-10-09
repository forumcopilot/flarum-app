import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures'));

      testWidgets('a profile shows the user, their posts and their discussions', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: UserPage(site: _site(), username: 'bob')));
        await _pumpUntil(tester, find.text('@bob'));
        await _pumpUntil(tester, find.byType(ListTile));
        expect(find.textContaining('Joined'), findsOneWidget);

        await tester.tap(find.text('Discussions'));
        await _pumpUntil(tester, find.text('Feature request: dark mode'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a mention in a thread opens the profile', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.text('@bob'));
        await tester.tap(find.text('@bob').first);
        await _pumpUntil(tester, find.byType(UserPage));
        await _pumpUntil(tester, find.text('@bob'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  }
}
