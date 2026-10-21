import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/compose/compose_page.dart';
import 'package:flarum_ui/src/compose/composers.dart';
import 'package:flarum_ui/src/polls/poll_card.dart';
import 'package:flarum_ui/src/polls/poll_editor_page.dart';
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

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

/// fof/polls in the thread and the composer, replayed from the write fixtures: carol's poll, bob
/// voting in it (tool/record_write_fixtures.dart).
void main() {

  testWidgets('the poll editor closes at once untouched, and asks once something is written', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () => PollEditorPage.open(context, maxOptions: 10),
        child: const Text('open'),
      ),
    )));
    Future<void> close() async {
      await tester.tap(find.byIcon(Icons.close));
      await _settle(tester);
    }

    await tester.tap(find.text('open'));
    await _settle(tester);
    await close();
    expect(find.byType(PollEditorPage), findsNothing, reason: 'nothing to lose');

    await tester.tap(find.text('open'));
    await _settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Question'), 'Which day?');
    await tester.pump();
    await close();
    expect(find.text('You have not saved your changes. Do you wish to discard them?'), findsOneWidget);
    expect(find.byType(PollEditorPage), findsOneWidget, reason: 'still open until the reader says');
  });
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('$_fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      final pollDiscussionId = (recorded('write_poll_discussion')['body']['data'] as Map)['id'] as String;

      void tallScreen(WidgetTester tester) {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
      }

      List<Object?> votesSent(FixtureForum fixtures) => [
            for (final r in fixtures.requests)
              if (r.method == 'PATCH' && r.path.endsWith('/votes')) ((r.data as Map)['data'] as Map)['optionIds'],
          ];

      testWidgets('a poll in a thread: a tap votes, another changes it; who voted; the vote taken back', (tester) async {
        final fixtures = FixtureForum(version, root: _fixtures);
        await tester.runAsync(fixtures.forum().refresh);
        tallScreen(tester);
        await tester.pumpWidget(_app(ThreadPage(site: _site(), discussionId: pollDiscussionId)));
        await _pumpUntil(tester, find.text(WriteSamples.pollQuestion));
        expect(find.text('The results show once you vote.'), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(WriteSamples.pollOptions.length));

        final [phone, tablet, _] = WriteSamples.pollOptions;
        await tester.tap(find.text(phone));
        await _pumpUntil(tester, find.text('1 vote was given'));
        expect(find.text('100%'), findsOneWidget);
        expect(find.text('The results show once you vote.'), findsNothing);

        await tester.tap(find.text(tablet));
        await _settle(tester);
        final [first, second] = votesSent(fixtures);
        expect((first as List).single, isNot((second as List).single), reason: 'changed, not added');

        await tester.tap(find.text('View voters'));
        await _pumpUntil(tester, find.descendant(of: find.byType(BottomSheet), matching: find.text('bob')));
        expect(find.descendant(of: find.byType(BottomSheet), matching: find.text(tablet)), findsOneWidget);
        await tester.tapAt(const Offset(10, 10));
        await _settle(tester);

        await tester.tap(find.text('Take back my vote'));
        await _pumpUntil(tester, find.text('The results show once you vote.'));
        expect(votesSent(fixtures).last, isEmpty);
        await _close(tester);
      });

      testWidgets('a multiple-choice poll takes its answers together, with Vote', (tester) async {
        FixtureForum(version, root: _fixtures).forum();
        final poll = (await tester.runAsync(() => FlarumForum.of(_site())
            .api
            .posts((recorded('write_poll_multiple_discussion')['body']['data'] as Map)['id'] as String)))!
            .items
            .first
            .polls
            .single;
        // Collected, then sent at once, where votes can't be changed after.
        final once = FlarumPoll(
          id: poll.id,
          question: poll.question,
          allowMultipleVotes: true,
          maxVotes: 2,
          canVote: true,
          options: poll.options,
        );
        FlarumPoll? voted;
        await tester.pumpWidget(_app(Scaffold(
          body: PollCard(site: _site(), poll: once, onChanged: (poll) => voted = poll),
        )));
        expect(find.text('Poll allows voting for 2 options.'), findsOneWidget);
        final [android, ios, desktop] = WriteSamples.multiplePollOptions;
        await tester.tap(find.text(android));
        await tester.tap(find.text(ios));
        await tester.pump();
        await tester.tap(find.text(desktop));
        await tester.pump();
        expect(find.text('Poll allows voting for 2 options.'), findsWidgets, reason: 'a third is refused');
        expect(voted, isNull, reason: 'nothing sent before Vote');
        await tester.tap(find.text('Vote'));
        for (var i = 0; i < 40 && voted == null; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(voted?.myVotes, hasLength(2));
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('Start a discussion adds a poll, which goes with the discussion', (tester) async {
        // carol's forum, where members may start polls.
        final fixtures = FixtureForum(version, root: _fixtures, states: {'drafts'});
        await tester.runAsync(fixtures.forum().refresh);
        tallScreen(tester);
        await tester.pumpWidget(_app(Builder(
          builder: (context) => TextButton(onPressed: () => composeDiscussion(context, _site()), child: const Text('open')),
        )));
        await tester.tap(find.text('open'));
        await _settle(tester);

        await tester.tap(find.text('Add Poll'));
        await _settle(tester);
        expect(find.byType(PollEditorPage), findsOneWidget);
        await tester.tap(find.text('Submit'));
        await tester.pump();
        expect(find.text('You must include a question'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Question'), WriteSamples.pollQuestion);
        // The message goes, and the fields move up, on the next frame.
        await tester.pump();
        expect(find.text('You must include a question'), findsNothing);
        await tester.enterText(find.widgetWithText(TextField, 'Answer 1'), WriteSamples.pollOptions[0]);
        await tester.tap(find.text('Submit'));
        await tester.pump();
        expect(find.text('You must include a minimum of 2 answers'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Answer 2'), WriteSamples.pollOptions[1]);
        await tester.pump();
        expect(find.text('You must include a minimum of 2 answers'), findsNothing, reason: 'gone once the reader puts it right');
        await tester.tap(find.text('Add Answer'));
        await tester.pump();
        await tester.enterText(find.widgetWithText(TextField, 'Answer 3'), WriteSamples.pollOptions[2]);
        await tester.tap(find.text('Allow people to see who voted'));
        await tester.tap(find.text('Allow users to change their vote'));
        await tester.pump();
        await tester.tap(find.text('Submit'));
        await _settle(tester);
        expect(find.widgetWithText(InputChip, WriteSamples.pollQuestion), findsOneWidget);

        await tester.enterText(find.widgetWithText(TextField, 'Title'), WriteSamples.pollTitle);
        await tester.enterText(find.byType(TextField).last, WriteSamples.pollContent);
        await tester.tap(find.text('Choose Tags'));
        await _settle(tester);
        await tester.tap(find.text('General'));
        await tester.pump();
        await tester.tap(find.text('OK'));
        await _settle(tester);
        await tester.tap(find.text('Post Discussion'));
        await _settle(tester);
        expect(find.byType(ComposePage), findsNothing);
        final sent = fixtures.requests.lastWhere((r) => r.method == 'POST' && r.path == '/discussions').data as Map;
        expect(sent['data']['attributes']['poll'], recorded('write_poll_discussion')['request']['body']['data']['attributes']['poll']);
      });
    });
  }
}
