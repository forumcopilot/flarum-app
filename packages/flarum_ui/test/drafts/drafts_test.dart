import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/compose/compose_page.dart';
import 'package:flarum_ui/src/compose/composers.dart';
import 'package:flarum_ui/src/drafts/drafts_page.dart';
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

/// fof/drafts, replayed from the write fixtures: carol's three drafts (the `drafts` state is her
/// forum, where members may save them).
void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('$_fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;

      Future<FixtureForum> signIn(WidgetTester tester) async {
        final fixtures = FixtureForum(version, root: _fixtures, states: {'drafts'});
        await tester.runAsync(fixtures.forum().refresh);
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        return fixtures;
      }

      testWidgets('Drafts lists them; a reply resumes in its composer, and Save draft keeps the change', (tester) async {
        final fixtures = await signIn(tester);
        await tester.pumpWidget(_app(DraftsPage(site: _site())));
        await _pumpUntil(tester, find.text(WriteSamples.draftPrivateTitle));
        expect(find.text(WriteSamples.draftTitle), findsOneWidget);
        final question = (recorded('write_question')['body']['data'] as Map)['attributes']['title'] as String;
        await _pumpUntil(tester, find.text('Reply to $question'));

        await tester.tap(find.text('Reply to $question'));
        await _pumpUntil(tester, find.byType(ComposePage));
        await _settle(tester);
        expect(find.text(WriteSamples.draftReply), findsOneWidget);
        await tester.enterText(find.byType(TextField).last, WriteSamples.draftReplyEdited);
        // The close prompt reads the change on the next frame.
        await tester.pump();
        await tester.tap(find.byTooltip('Close'));
        await _settle(tester);
        await tester.tap(find.text('Save draft'));
        await _settle(tester);
        expect(find.byType(ComposePage), findsNothing);
        expect(find.text('Draft saved.'), findsOneWidget);
        final saved = fixtures.requests.lastWhere((r) => r.path.startsWith('/drafts/'));
        expect(saved.method, 'PATCH');
        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('a draft deleted from the list leaves it', (tester) async {
        final fixtures = await signIn(tester);
        await tester.pumpWidget(_app(DraftsPage(site: _site())));
        await _pumpUntil(tester, find.text(WriteSamples.draftTitle));
        final tile = find.ancestor(of: find.text(WriteSamples.draftTitle), matching: find.byType(ListTile));
        await tester.tap(find.descendant(of: tile, matching: find.byTooltip('Delete draft')));
        await _settle(tester);
        expect(find.text('Delete this draft?'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await _settle(tester);
        expect(find.text(WriteSamples.draftTitle), findsNothing);
        expect(fixtures.requests.where((r) => r.method == 'DELETE'), hasLength(1));
      });

      testWidgets('a new discussion with a poll saves as a draft without the poll', (tester) async {
        final fixtures = await signIn(tester);
        // A page with a Scaffold, for the snackbar once the composer closes.
        await tester.pumpWidget(_app(Scaffold(
          body: Builder(
            builder: (context) => TextButton(onPressed: () => composeDiscussion(context, _site()), child: const Text('open')),
          ),
        )));
        await tester.tap(find.text('open'));
        await _settle(tester);
        await tester.enterText(find.widgetWithText(TextField, 'Title'), WriteSamples.draftTitle);
        await tester.enterText(find.byType(TextField).last, WriteSamples.draftContent);
        await tester.tap(find.text('Choose tags'));
        await _settle(tester);
        await tester.tap(find.text('General'));
        await tester.pump();
        await tester.tap(find.text('Done'));
        await _settle(tester);
        await tester.tap(find.text('Add a poll'));
        await _settle(tester);
        await tester.enterText(find.widgetWithText(TextField, 'Question'), WriteSamples.pollQuestion);
        await tester.enterText(find.widgetWithText(TextField, 'Answer 1'), WriteSamples.pollOptions[0]);
        await tester.enterText(find.widgetWithText(TextField, 'Answer 2'), WriteSamples.pollOptions[1]);
        await tester.tap(find.text('Done'));
        await _settle(tester);

        await tester.tap(find.byTooltip('Close'));
        await _settle(tester);
        await tester.tap(find.text('Save draft'));
        await _settle(tester);
        expect(find.byType(ComposePage), findsNothing);
        expect(find.text("Draft saved, without the poll: drafts don't keep polls."), findsOneWidget);
        expect(fixtures.requests.where((r) => r.method == 'POST' && r.path == '/drafts'), hasLength(1));
        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('without the permission, closing offers no Save draft', (tester) async {
        // alice's forum, recorded before members could save drafts.
        final fixtures = FixtureForum(version, root: _fixtures);
        await tester.runAsync(fixtures.forum().refresh);
        await tester.pumpWidget(_app(Builder(
          builder: (context) => TextButton(onPressed: () => composeDiscussion(context, _site()), child: const Text('open')),
        )));
        await tester.tap(find.text('open'));
        await _settle(tester);
        await tester.enterText(find.byType(TextField).last, WriteSamples.draftContent);
        await tester.pump();
        await tester.tap(find.byTooltip('Close'));
        await _settle(tester);
        expect(find.text('Discard'), findsOneWidget);
        expect(find.text('Save draft'), findsNothing);
      });
    });
  }
}
