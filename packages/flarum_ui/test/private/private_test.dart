import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/compose/compose_page.dart';
import 'package:flarum_ui/src/compose/composers.dart';
import 'package:flarum_ui/src/compose/mention_picker_page.dart';
import 'package:flarum_ui/src/private/private_discussions_page.dart';
import 'package:flarum_ui/src/safety/ignored_users.dart';
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

/// Private discussions (fof/byobu), replayed from the write fixtures: carol's with bob.
void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    IgnoredUsers.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Future<FixtureForum> signIn(WidgetTester tester) async {
        final fixtures = FixtureForum(version, root: _fixtures);
        await tester.runAsync(fixtures.forum().refresh);
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        return fixtures;
      }

      testWidgets('Private discussions lists them; one opens with who it\'s with', (tester) async {
        await signIn(tester);
        await tester.pumpWidget(_app(PrivateDiscussionsPage(site: _site())));
        // The title follows the private discussion's glyph.
        final tile = find.textContaining(WriteSamples.privateTitle, findRichText: true);
        await _pumpUntil(tester, tile);
        expect(find.text('Discuss Privately'), findsOneWidget);

        await tester.tap(tile);
        await _pumpUntil(tester, find.byType(PostTile));
        await _pumpUntil(tester, find.text('With bob, carol'));
        expect(find.text(WriteSamples.privateReply), findsOneWidget);
        // carol may rename hers, but she's no moderator.
        expect(find.byTooltip('Moderate'), findsNothing);
        await _settle(tester);
        await tester.tap(find.descendant(of: find.byType(AppBar), matching: find.byTooltip('Show menu')));
        await _settle(tester);
        expect(find.text('Rename'), findsOneWidget);
        await tester.tapAt(const Offset(10, 700));
        await _settle(tester);
        await _close(tester);
      });

      testWidgets('the composer starts one with the person chosen, and only one', (tester) async {
        final fixtures = await signIn(tester);
        FlarumDiscussion? started;
        await tester.pumpWidget(_app(Builder(
          builder: (context) => TextButton(
            onPressed: () async => started = await composePrivateDiscussion(context, _site()),
            child: const Text('open'),
          ),
        )));
        await tester.tap(find.text('open'));
        await _settle(tester);

        await tester.enterText(find.widgetWithText(TextField, 'Title'), WriteSamples.privateTitle);
        await tester.tap(find.widgetWithText(FilledButton, 'Send'));
        await _settle(tester);
        // Under the field, until there's something in it.
        expect(find.text('Please enter some content'), findsOneWidget);
        await tester.enterText(find.byType(TextField).last, WriteSamples.privateContent);
        await tester.pump();
        expect(find.text('Please enter some content'), findsNothing);
        await tester.tap(find.widgetWithText(FilledButton, 'Send'));
        await _settle(tester);
        expect(find.text('This discussion will only be visible to the users you choose here. At least 1 recipient (other than yourself) is required.'), findsOneWidget);

        await tester.tap(find.text('Recipients'));
        await _settle(tester);
        await tester.enterText(find.descendant(of: find.byType(MentionPickerPage), matching: find.byType(TextField)), 'bo');
        await tester.pump(const Duration(milliseconds: 400));
        await _pumpUntil(tester, find.widgetWithText(ListTile, 'bob'));
        await tester.tap(find.widgetWithText(ListTile, 'bob'));
        await _settle(tester);
        expect(find.widgetWithText(InputChip, 'bob'), findsOneWidget);

        await tester.tap(find.text('Recipients'));
        await _settle(tester);
        expect(find.text('This forum lets you write privately to one person at a time.'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Send'));
        await _settle(tester);
        expect(find.byType(ComposePage), findsNothing);
        expect((started?.title, started?.isPrivate), (WriteSamples.privateTitle, true));
        final sent = fixtures.requests.lastWhere((r) => r.method == 'POST').data as Map;
        expect(sent['data']['relationships']['recipientUsers']['data'], [
          {'type': 'users', 'id': (jsonDecode(File('$_fixtures/${version.name}/write_ignore_user.json').readAsStringSync())['request']['path'] as String).split('/').last},
        ]);
      });
    });
  }
}
