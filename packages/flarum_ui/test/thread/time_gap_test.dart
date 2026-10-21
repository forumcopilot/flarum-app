import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _root = '../flarum_core/test/fixtures';

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

  test('posts more than 4 days apart are marked as the website marks them', () {
    final en = lookupFlarumLocalizations(const Locale('en'));
    final start = DateTime.utc(2026, 1, 1);
    String? after(Duration gap) => timeLapsed(start, start.add(gap), en);
    expect(after(const Duration(days: 4)), isNull);
    expect(after(const Duration(days: 5)), '5 days later');
    expect(after(const Duration(days: 30)), 'a month later');
    expect(after(const Duration(days: 92)), '3 months later');
    expect(after(const Duration(days: 400)), 'a year later');
    expect(after(const Duration(days: 800)), '2 years later');
    expect(timeLapsed(null, start, en), isNull);
    expect(timeLapsed(start, start.add(const Duration(days: 5)), lookupFlarumLocalizations(const Locale('de'))),
        '5 Tage später');
    expect(timeLapsed(start, start.add(const Duration(days: 60)), lookupFlarumLocalizations(const Locale('ru'))),
        '2 месяца спустя');
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: _root));

      testWidgets('a long silence between two posts is marked between them', (tester) async {
        // The welcome thread as recorded, with its third post written 12 days after the second.
        final recorded = jsonDecode(File('$_root/${version.name}/posts_welcome.json').readAsStringSync()) as Map;
        final body = Map<String, dynamic>.from(recorded['body'] as Map);
        final posts = [for (final p in body['data'] as List) Map<String, dynamic>.from(p as Map)];
        posts.sort((a, b) => (a['attributes']['number'] as int).compareTo(b['attributes']['number'] as int));
        final second = DateTime.parse(posts[1]['attributes']['createdAt'] as String);
        posts[2] = {
          ...posts[2],
          'attributes': {...posts[2]['attributes'] as Map, 'createdAt': second.add(const Duration(days: 12)).toIso8601String()},
        };
        for (final p in posts.skip(3)) {
          p['attributes'] = {...p['attributes'] as Map, 'createdAt': second.add(const Duration(days: 13)).toIso8601String()};
        }
        fixtures.replies['GET /posts'] = {...body, 'data': posts};
        fixtures.forum();
        // Tall enough for the whole thread to be drawn.
        tester.view.physicalSize = const Size(800, 3000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('12 DAYS LATER'), findsOneWidget, reason: 'once, above the third post; a day apart is no gap');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('pulled down at the top, the discussion is read again', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        await tester.pump(const Duration(milliseconds: 300));
        final before = fixtures.requests.where((r) => r.path == '/posts').length;
        await tester.fling(find.byType(PostTile).first, const Offset(0, 400), 1000);
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(fixtures.requests.where((r) => r.path == '/posts').length, greaterThan(before));
        expect(find.byType(PostTile), findsWidgets, reason: 'the posts are back');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  }
}
