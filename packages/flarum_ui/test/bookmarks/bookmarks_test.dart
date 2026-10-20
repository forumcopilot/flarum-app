import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/bookmarks/bookmarks_page.dart';
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

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [FlarumLocalizations.delegate, KitLocalizations.delegate, ...FlarumLocalizations.localizationsDelegates],
      home: home,
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      testWidgets('the Bookmarks page lists the bookmarked discussions and posts', (tester) async {
        final fixtures = FixtureForum(version, root: _fixtures);
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(BookmarksPage(site: _site())));
        await _settle(tester);
        expect(find.text(WriteSamples.questionTitle), findsOneWidget, reason: 'the bookmarked discussion');

        await tester.tap(find.text('Posts'));
        await _settle(tester);
        expect(find.text(WriteSamples.answer), findsOneWidget, reason: 'the bookmarked post');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('back from a bookmarked discussion, the page reads both lists again', (tester) async {
        final fixtures = FixtureForum(version, root: _fixtures);
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(BookmarksPage(site: _site())));
        await _settle(tester);
        await tester.tap(find.text(WriteSamples.questionTitle));
        await _settle(tester);
        expect(find.byType(ThreadPage), findsOneWidget);

        // Meanwhile the reader took both bookmarks off.
        fixtures.replies['GET /discussions'] = {'data': <Object>[]};
        fixtures.replies['GET /posts'] = {'data': <Object>[]};
        Navigator.of(tester.element(find.byType(ThreadPage))).pop();
        await _settle(tester);
        expect(find.text(WriteSamples.questionTitle), findsNothing);
        expect(find.text("You haven't bookmarked any posts yet."), findsOneWidget);
        await tester.tap(find.text('Posts'));
        await _settle(tester);
        expect(find.text(WriteSamples.answer), findsNothing);
        expect(find.text("You haven't bookmarked any posts yet."), findsOneWidget, reason: 'the same words on both tabs');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a tag the reader lurks in shows the menu\'s eye on the bar', (tester) async {
        final forum = FixtureForum(version, root: _fixtures).forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(TagPage(
          site: _site(),
          tag: const FlarumTag(id: '43', name: 'Cycling', slug: 'cycling', isPrimary: true, subscription: 'lurk'),
        )));
        await _settle(tester);
        expect(find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.forum)), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a tag\'s page sets how the reader follows it', (tester) async {
        final fixtures = FixtureForum(version, root: _fixtures);
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        final recorded = jsonDecode(File('$_fixtures/${version.name}/write_tag_follow.json').readAsStringSync());
        final cyclingId = (recorded['request']['path'] as String).split('/')[2];
        final tags = (await tester.runAsync(forum.tags))!;
        await tester.pumpWidget(_app(TagPage(site: _site(), tag: tags.firstWhere((t) => t.id == cyclingId))));
        await _settle(tester);

        await tester.tap(find.byTooltip('Follow'));
        await _settle(tester);
        expect(find.text('Lurking'), findsOneWidget);
        await tester.tap(find.text('Following'));
        await _settle(tester);
        expect(find.byIcon(Icons.star), findsOneWidget);
        final sent = fixtures.requests.lastWhere((r) => r.method != 'GET');
        expect(sent.path, contains('/tags/$cyclingId'));
        expect(find.byType(SnackBar), findsNothing, reason: 'the forum took it');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  }
}
