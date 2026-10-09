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
    testWidgets('Flarum ${version.name}: search finds discussions with their best post, and posts', (tester) async {
      FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: SearchPage(site: _site())));
      await tester.enterText(find.byType(TextField), 'thread');
      await _pumpUntil(tester, find.byType(DiscussionTile));
      expect(find.text('App crashes when opening a long thread'), findsOneWidget);
      expect(find.text('Long thread for paging tests'), findsOneWidget);
      expect(find.text('Steps: open any thread with 50+ replies.'), findsOneWidget, reason: 'the best post');

      await tester.tap(find.text('Posts'));
      await _pumpUntil(tester, find.textContaining('alice: Steps: open any thread'));
    });
  }
}
