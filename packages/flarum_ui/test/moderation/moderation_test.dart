import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/safety/ignored_users.dart';
import 'package:flarum_ui/src/safety/suspended_strip.dart';
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

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

/// Moderation (Milestone 5), replayed from the write fixtures: the admin on carol's question and
/// bob's answer (the `moderator` state), and bob suspended for a moment.
void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    IgnoredUsers.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      String questionId() =>
          (jsonDecode(File('$_fixtures/${version.name}/write_lock.json').readAsStringSync())['request']['path'] as String)
              .split('/')
              .last;

      Future<FixtureForum> asModerator(WidgetTester tester, {Set<String> states = const {'moderator'}}) async {
        final fixtures = FixtureForum(version, root: _fixtures, states: states);
        await tester.runAsync(fixtures.forum().refresh);
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        return fixtures;
      }

      /// The changes sent to [path], leaving out the thread's read reports.
      List<Object?> patched(FixtureForum fixtures, String path) => [
            for (final r in fixtures.requests)
              if (r.method == 'PATCH' && r.path == path && !'${r.data}'.contains('lastReadPostNumber'))
                (r.data as Map)['data']['attributes'],
          ];

      testWidgets('a moderator locks the discussion, is offered its rename, and deletes and restores a post', (tester) async {
        final fixtures = await asModerator(tester);
        await tester.pumpWidget(_app(ThreadPage(site: _site(), discussionId: questionId())));
        await _pumpUntil(tester, find.byType(PostTile));
        await _settle(tester);

        await tester.tap(find.byTooltip('Moderate'));
        await _settle(tester);
        for (final label in ['Rename', 'Lock', 'Sticky', 'Delete']) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        expect(find.text('Delete forever'), findsNothing, reason: 'only once it\'s deleted');
        await tester.tap(find.text('Lock'));
        await _settle(tester);
        expect(patched(fixtures, '/discussions/${questionId()}'), [
          {'isLocked': true},
        ]);

        await tester.tap(find.byTooltip('Moderate'));
        await _settle(tester);
        await tester.tap(find.text('Rename'));
        await _settle(tester);
        // The moderator read it after its rename: the dialog opens on that title.
        final field = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
        expect(tester.widget<TextField>(field).controller!.text, WriteSamples.renamedTitle);
        await tester.tap(find.text('Cancel'));
        await _settle(tester);
        expect(patched(fixtures, '/discussions/${questionId()}'), hasLength(1), reason: 'nothing sent');

        // bob's answer: Delete hides it, Restore brings it back.
        final answer = find.byType(PostTile).at(1);
        await tester.tap(find.descendant(of: answer, matching: find.byIcon(Icons.more_vert)));
        await _settle(tester);
        await tester.tap(find.text('Delete'));
        await _settle(tester);
        expect(find.descendant(of: find.byType(PostTile).at(1), matching: find.text('This post was deleted.')), findsOneWidget);
        await tester.tap(find.descendant(of: find.byType(PostTile).at(1), matching: find.byIcon(Icons.more_vert)));
        await _settle(tester);
        expect(find.text('Delete forever'), findsOneWidget);
        await tester.tap(find.text('Restore'));
        await _settle(tester);
        expect(find.text('This post was deleted.'), findsNothing);
        await _close(tester);
      });

      testWidgets('a moderator suspends bob indefinitely from his profile, and lets him back', (tester) async {
        final fixtures = await asModerator(tester);
        await tester.pumpWidget(_app(UserPage(site: _site(), slug: 'bob')));
        await _pumpUntil(tester, find.text('@bob'));
        await tester.tap(find.byTooltip('Show menu'));
        await _settle(tester);
        await tester.tap(find.text('Suspend User'));
        await _settle(tester);

        // Forever is the default; the reason is ours.
        await tester.tap(find.text('Custom…'));
        await _settle(tester);
        await tester.enterText(find.byType(TextField).last, WriteSamples.suspendReason);
        await tester.tap(find.widgetWithText(FilledButton, 'Suspend User'));
        await _settle(tester);
        expect(find.text('Suspended indefinitely'), findsOneWidget);
        final sent = fixtures.requests.lastWhere((r) => r.method == 'PATCH').data as Map;
        expect(sent['data']['attributes'], {
          'suspendedUntil': FlarumUser.indefiniteSuspension.toIso8601String(),
          'suspendReason': WriteSamples.suspendReason,
          'suspendMessage': WriteSamples.suspendReason,
        });

        await tester.tap(find.byTooltip('Show menu'));
        await _settle(tester);
        await tester.tap(find.text('Unsuspend'));
        await _settle(tester);
        expect(find.text('Suspended indefinitely'), findsNothing);
        await _close(tester);
      });

      testWidgets('a suspended reader is told above the tabs', (tester) async {
        await asModerator(tester, states: {'suspended'});
        await tester.pumpWidget(_app(AppShell(site: _site(), appearance: Appearance.unsaved())));
        await _settle(tester);
        expect(find.byType(SuspendedStrip), findsOneWidget);
        expect(find.text("You're suspended. ${WriteSamples.suspendReason}"), findsOneWidget);
        await _close(tester);
      });
    });
  }
}
