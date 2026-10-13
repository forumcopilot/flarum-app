import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/safety/flag_post_page.dart';
import 'package:flarum_ui/src/safety/ignored_users.dart';
import 'package:flarum_ui/src/safety/ignored_users_page.dart';
import 'package:flarum_ui/src/safety/terms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Closes the page, letting it send what it sends as it goes (the thread's read position).
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Milestone 4's reporting and ignoring, replayed from the write fixtures: carol's question and
/// bob's answer; carol reports it, and ignores bob.
void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    IgnoredUsers.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      String questionId() =>
          (jsonDecode(File('$_fixtures/${version.name}/write_question_with_post_ids.json').readAsStringSync())['request']
                  ['path'] as String)
              .split('/')
              .last;

      /// The question's thread, with the forum [states] (FixtureForum.states).
      Future<FixtureForum> openQuestion(WidgetTester tester, {Set<String> states = const {}}) async {
        final fixtures = FixtureForum(version, root: _fixtures, states: states);
        await tester.runAsync(fixtures.forum().refresh);
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(ThreadPage(site: _site(), discussionId: questionId())));
        await _pumpUntil(tester, find.byType(PostTile));
        await _settle(tester);
        return fixtures;
      }

      Future<void> openAnswerMenu(WidgetTester tester) async {
        await tester.tap(find.descendant(of: find.byType(PostTile).last, matching: find.byIcon(Icons.more_vert)));
        await _settle(tester);
      }

      testWidgets('Flag reports a post: a reason, and words for "Other"', (tester) async {
        final fixtures = await openQuestion(tester);
        await openAnswerMenu(tester);
        await tester.tap(find.text('Flag'));
        await _settle(tester);
        expect(find.byType(FlagPostPage), findsOneWidget);
        expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Flag')).onPressed, isNull,
            reason: 'no reason chosen yet');

        await tester.tap(find.text('Other (please specify)'));
        await _settle(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Flag'));
        await _settle(tester);
        expect(find.text('Please provide some details for our moderators.'), findsOneWidget);

        await tester.tap(find.text('Off-topic'));
        await _settle(tester);
        await tester.enterText(find.byType(TextField), WriteSamples.flagDetail);
        await tester.tap(find.widgetWithText(FilledButton, 'Flag'));
        await _settle(tester);
        expect(find.byType(FlagPostPage), findsNothing);
        expect(find.text('Thank you for flagging this post. Our moderators will look into it.'), findsOneWidget);
        expect(fixtures.requests.where((r) => r.method == 'POST' && r.path.endsWith('/flags')), hasLength(1));
        await _close(tester);
      });

      testWidgets('Ignore folds bob\'s posts away, Show unfolds one, and Stop ignoring brings them back',
          (tester) async {
        await openQuestion(tester);
        await openAnswerMenu(tester);
        await tester.tap(find.text('Ignore bob'));
        await _settle(tester);
        expect(find.textContaining('Their posts will be folded away'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Ignore bob'));
        await _settle(tester);
        expect(find.text('A post by bob, whom you ignore.'), findsOneWidget);
        expect(find.text(WriteSamples.answer), findsNothing);

        await tester.tap(find.text('Show post'));
        await _settle(tester);
        expect(find.text(WriteSamples.answer), findsOneWidget);

        await openAnswerMenu(tester);
        await tester.tap(find.text('Stop ignoring bob'));
        await _settle(tester);
        expect(find.text('A post by bob, whom you ignore.'), findsNothing);
        expect(find.text(WriteSamples.answer), findsOneWidget);
        await _close(tester);
      });

      testWidgets('a policy to accept shows above the tabs until the reader accepts it', (tester) async {
        final fixtures = FixtureForum(version, root: _fixtures, states: {'terms'});
        await tester.runAsync(fixtures.forum().refresh);
        await tester.pumpWidget(_app(AppShell(site: _site(), appearance: Appearance.unsaved())));
        await _settle(tester);
        expect(find.text("Accept this forum's updated terms to post again."), findsOneWidget);

        await tester.tap(find.text('Review'));
        await _settle(tester);
        expect(find.byType(TermsPage), findsOneWidget);
        expect(find.text(WriteSamples.policyName), findsOneWidget);
        expect(find.text(WriteSamples.policyUpdate), findsOneWidget);
        await tester.tap(find.text('Accept'));
        await _settle(tester);
        expect(find.byType(TermsPage), findsNothing);
        expect(find.text('Thank you. You can post again.'), findsOneWidget);
        expect(find.byType(TermsStrip), findsNothing);
        expect(fixtures.requests.where((r) => r.method == 'POST' && r.path.endsWith('/accept')), hasLength(1));
        await _close(tester);
      });

      testWidgets('read while ignoring bob, his answer opens folded; Ignored users lists him', (tester) async {
        await openQuestion(tester, states: {'ignoring'});
        expect(find.text('A post by bob, whom you ignore.'), findsOneWidget);

        await tester.pumpWidget(_app(IgnoredUsersPage(site: _site())));
        await _pumpUntil(tester, find.text('bob'));
        expect(find.text('Stop ignoring'), findsOneWidget);
        await _close(tester);
      });
    });
  }

  testWidgets('where the forum keeps no list (a guest here), the app keeps it on the phone', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures);
    await tester.runAsync(fixtures.forum(signedIn: false).refresh);
    final ignored = IgnoredUsers.of(_site());
    expect(ignored.forumKeepsList, isFalse);
    const bob = FlarumUser(id: '3', username: 'bob', displayName: 'bob', ignored: false, canBeIgnored: true);
    expect(ignored.canIgnore(bob), isTrue);
    await tester.runAsync(() => ignored.setIgnored(bob, true));
    expect(ignored.isIgnored(bob), isTrue, reason: 'the forum\'s "not ignored" is for its own list');

    // Kept: read again by the next run of the app.
    IgnoredUsers.resetForTesting();
    final again = IgnoredUsers.of(_site());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(again.isIgnored(bob), isTrue);
    expect((await tester.runAsync(again.list))!.map((u) => u.username), ['bob']);
  });
}
