import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/search/highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('a long result is cut around the first word searched for, as the web cuts it', () {
    final text = '${'Lorem ipsum dolor sit amet. ' * 10}The router drops Wi-Fi every evening.${' Consectetur adipiscing.' * 10}';
    final excerpt = excerptAround(text, 'router', length: 80);
    expect(excerpt, startsWith('…'));
    expect(excerpt, endsWith('…'));
    expect(excerpt, contains('The router drops Wi-Fi'));
    expect(excerptAround('Short and sweet.', 'router'), 'Short and sweet.');
    expect([for (final span in highlighted('Router, router!', 'router')) span.text], ['Router', ', ', 'router', '!']);
  });

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: search finds discussions with their best post, and posts', (tester) async {
      FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: SearchPage(site: _site())));
      await tester.enterText(find.byType(TextField), 'thread');
      await _pumpUntil(tester, find.byType(DiscussionTile));
      expect(find.text('App crashes when opening a long thread'), findsOneWidget);
      expect(find.text('Long thread for paging tests'), findsOneWidget);
      expect(find.text('Steps: open any thread with 50+ replies.'), findsOneWidget, reason: 'the best post');

      expect(find.text('Users'), findsOneWidget);
      if (version == FlarumVersion.v1) {
        expect(find.text('Posts'), findsNothing, reason: '1.x searches no posts: the tab would repeat the discussions');
      } else {
        await tester.tap(find.text('Posts'));
        await _pumpUntil(tester, find.textContaining('alice: Steps: open any thread'));
      }
    });

    testWidgets('Flarum ${version.name}: the words searched for are bold, and the search is remembered', (tester) async {
      SharedPreferences.setMockInitialValues({});
      FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: SearchPage(site: _site())));
      await tester.enterText(find.byType(TextField), 'thread');
      await _pumpUntil(tester, find.byType(DiscussionTile));
      final excerpt = tester.widget<Text>(find.textContaining('Steps: open any thread'));
      final bold = [
        for (final span in (excerpt.textSpan! as TextSpan).children!.cast<TextSpan>())
          if (span.style?.fontWeight == FontWeight.w700) span.text,
      ];
      expect(bold, contains('thread'));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: SearchPage(site: _site())));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'thread'), findsOneWidget);
    });
  }
}
