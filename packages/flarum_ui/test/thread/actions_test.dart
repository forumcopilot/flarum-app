import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/widgets/flarum_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _fixtures = '../flarum_core/test/fixtures';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Milestone 2's actions on a thread, replayed from the write fixtures: carol's question in the
/// Q&A tag and bob's answer.
void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: like, react, choose the best answer, follow and bookmark', (tester) async {
      final fixtures = FixtureForum(version, root: _fixtures);
      final forum = fixtures.forum();
      await tester.runAsync(forum.refresh);
      final recorded = jsonDecode(File('$_fixtures/${version.name}/write_question_with_post_ids.json').readAsStringSync());
      final question = (recorded['request']['path'] as String).split('/').last;
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [FlarumLocalizations.delegate, KitLocalizations.delegate, ...FlarumLocalizations.localizationsDelegates],
        home: ThreadPage(site: _site(), discussionId: question),
      ));
      await _pumpUntil(tester, find.byType(PostTile));
      await _settle(tester);
      final answer = find.byType(PostTile).last;
      List<String> writes() => [
            for (final r in fixtures.requests)
              if (r.method != 'GET' && !'${r.data}'.contains('lastReadPostNumber')) '${r.method} ${r.path}',
          ];

      // Like the answer: at once, as the reader's (the forum's answer was recorded as bob's).
      fixtures.latency = const Duration(milliseconds: 300);
      await tester.tap(find.descendant(of: answer, matching: find.byIcon(Icons.thumb_up_outlined)));
      await tester.pump();
      expect(find.descendant(of: answer, matching: find.byIcon(Icons.thumb_up)), findsOneWidget,
          reason: 'the thumb fills, in the accent');
      expect(find.descendant(of: answer, matching: find.text('1')), findsOneWidget, reason: 'one like, the reader\'s');
      await _settle(tester);
      fixtures.latency = Duration.zero;

      // Who: the count opens the sheet, which lists the liker (the forum's answer names bob).
      await tester.tap(find.descendant(of: answer, matching: find.text('1')));
      await _settle(tester);
      expect(find.text('Likes and Reactions'), findsOneWidget);
      expect(find.descendant(of: find.byType(BottomSheet), matching: find.byType(FlarumAvatar)), findsOneWidget);
      await tester.tapAt(const Offset(400, 20));
      await _settle(tester);

      // React with a heart: a long press on Like offers the forum's reactions.
      // (Saved, the like reads as the recording's, bob's: the thumb may be empty again.)
      await tester.longPress(find.descendant(
          of: answer,
          matching: find.byWidgetPredicate((w) => w is Icon && (w.icon == Icons.thumb_up || w.icon == Icons.thumb_up_outlined))));
      await _settle(tester);
      expect(find.text('React'), findsOneWidget, reason: "the picker's title");
      await tester.tap(find.text('❤️'));
      await _settle(tester);
      expect(find.descendant(of: answer, matching: find.text('❤️')), findsNWidgets(2),
          reason: 'in the count, and as the reader\'s own reaction beside Like');
      expect(find.descendant(of: answer, matching: find.text('2')), findsOneWidget, reason: 'a like and a heart');

      // Choose it as the best answer, from its menu.
      await tester.tap(find.descendant(of: answer, matching: find.byIcon(Icons.more_vert)));
      await _settle(tester);
      await tester.tap(find.text('Select Best Answer'));
      await _settle(tester);
      expect(find.text('Best Answer'), findsNWidgets(2), reason: 'on the answer, and previewed under the question');

      // Follow the discussion, and bookmark it.
      await tester.tap(find.byTooltip('Follow'));
      await _settle(tester);
      await tester.tap(find.text('Following'));
      await _settle(tester);
      expect(find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.star)), findsOneWidget);
      expect(find.byTooltip('Following'), findsWidgets, reason: 'the bar, and the badge in the header');
      await tester.tap(find.byTooltip('Bookmark'));
      await _settle(tester);
      expect(find.byTooltip('Remove from bookmarks'), findsOneWidget);

      expect(writes(), [
        'PATCH /posts/${(jsonDecode(File('$_fixtures/${version.name}/write_like.json').readAsStringSync())['request']['path'] as String).split('/').last}',
        'PATCH /posts/${(jsonDecode(File('$_fixtures/${version.name}/write_react.json').readAsStringSync())['request']['path'] as String).split('/').last}',
        'PATCH /discussions/$question',
        'PATCH /discussions/$question',
        'PATCH /discussions/$question',
      ], reason: 'each action reached the forum once, and none was undone');
      expect(find.byType(SnackBar), findsNothing, reason: 'no refusal');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
