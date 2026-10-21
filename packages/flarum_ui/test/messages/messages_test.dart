import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/messages/dialog_page.dart';
import 'package:flarum_ui/src/messages/dialogs_page.dart';
import 'package:flarum_ui/src/widgets/flarum_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// flarum/messages (2.0), replayed from the write fixtures: carol's conversation with bob, read as
/// carol (the `messages` state).
void main() {
  setUp(FlarumForum.resetForTesting);

  final bobId = (jsonDecode(File('$_fixtures/v2/write_ignore_user.json').readAsStringSync())['request']['path'] as String)
      .split('/')
      .last;

  Future<FixtureForum> signIn(WidgetTester tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures, states: {'messages'});
    await tester.runAsync(fixtures.forum().refresh);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return fixtures;
  }

  testWidgets('Messages lists the conversations; one opens, its messages in order, and is marked read', (tester) async {
    final fixtures = await signIn(tester);
    await tester.pumpWidget(_app(DialogsPage(site: _site())));
    await _pumpUntil(tester, find.text('bob'));
    expect(find.text(WriteSamples.messageReply), findsOneWidget, reason: 'the last message');
    expect(find.text('1'), findsOneWidget, reason: 'one unread');
    expect(find.text('Send a Message'), findsOneWidget);

    await tester.tap(find.text('bob'));
    await _pumpUntil(tester, find.byType(DialogPage));
    // The list stays under the conversation, its last message too.
    Finder inDialog(String text) => find.descendant(of: find.byType(DialogPage), matching: find.text(text));
    await _pumpUntil(tester, inDialog(WriteSamples.message));
    expect(inDialog(WriteSamples.messageReply), findsOneWidget);
    expect(
      tester.getTopLeft(inDialog(WriteSamples.message)).dy,
      lessThan(tester.getTopLeft(inDialog(WriteSamples.messageReply)).dy),
      reason: 'the newest at the bottom',
    );
    expect(fixtures.requests.where((r) => r.method == 'PATCH' && r.path.startsWith('/dialogs/')), hasLength(1));
  });

  testWidgets('Mark all as read marks every conversation read, as the messages page does', (tester) async {
    final fixtures = await signIn(tester);
    fixtures.replies['POST /dialogs/read'] = <String, Object>{};
    await tester.pumpWidget(_app(DialogsPage(site: _site())));
    await _pumpUntil(tester, find.text('bob'));
    await tester.tap(find.byTooltip('Mark all as read'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(fixtures.requests.where((r) => r.method == 'POST' && r.path == '/dialogs/read'), hasLength(1));
    expect(fixtures.requests.where((r) => r.method == 'GET' && r.path == '/dialogs').length, greaterThan(1),
        reason: 'listed again');
  });

  testWidgets('a conversation as flarum/messages marks it, grouped as a chat; a long press copies a message',
      (tester) async {
    final fixtures = await signIn(tester);
    // carol's message, then ten days on two of bob's a minute apart.
    final recorded = jsonDecode(File('$_fixtures/v2/write_dialog_messages.json').readAsStringSync())['body'] as Map;
    final [bobs, carols] = [for (final m in recorded['data'] as List) Map<String, dynamic>.from(m as Map)];
    final at = DateTime.parse(bobs['attributes']['createdAt'] as String);
    String time(Duration d) => at.add(d).toIso8601String();
    fixtures.replies['GET /dialog-messages'] = {
      ...recorded,
      'data': [
        {
          ...bobs,
          'id': '900',
          'attributes': {...bobs['attributes'] as Map, 'createdAt': time(const Duration(minutes: 1)), 'contentHtml': '<p>One more thing.</p>'},
        },
        bobs,
        {
          ...carols,
          'attributes': {...carols['attributes'] as Map, 'createdAt': time(const Duration(days: -10))},
        },
      ],
    };
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(_app(DialogPage(site: _site(), dialogId: (bobs['relationships'] as Map)['dialog']['data']['id'] as String)));
    await _pumpUntil(tester, find.text('One more thing.'));
    expect(find.text('START OF THE CONVERSATION'), findsOneWidget);
    expect(find.text('10 DAYS LATER'), findsOneWidget);
    expect(find.descendant(of: find.byType(DialogPage), matching: find.byType(FlarumAvatar)), findsOneWidget,
        reason: "bob's two messages in a run: his avatar once, by the last");

    await tester.longPress(find.text('One more thing.'));
    await tester.pump();
    expect(copied, 'One more thing.');
    expect(find.text('Message copied.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('opened on someone, it shows the conversation the reader already has with them', (tester) async {
    final fixtures = await signIn(tester);
    await tester.pumpWidget(_app(DialogPage(
      site: _site(),
      to: FlarumUser(id: bobId, username: 'bob', displayName: 'bob'),
    )));
    await tester.pump();
    expect(find.text('bob'), findsOneWidget, reason: 'the title');
    await _pumpUntil(tester, find.text(WriteSamples.messageReply));
    expect(find.text(WriteSamples.message), findsOneWidget);
    expect(fixtures.requests.where((r) => r.method == 'POST'), isEmpty);
    expect(fixtures.requests.where((r) => r.method == 'GET' && r.path == '/dialogs'), hasLength(1));
  });

  testWidgets('a first message to someone new starts the conversation', (tester) async {
    final fixtures = await signIn(tester);
    // carol has no conversations yet.
    fixtures.replies['GET /dialogs'] = {'data': <Object>[]};
    await tester.pumpWidget(_app(DialogPage(
      site: _site(),
      to: FlarumUser(id: bobId, username: 'bob', displayName: 'bob'),
    )));
    for (var i = 0; i < 20 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(WriteSamples.message), findsNothing);

    await tester.enterText(find.byType(TextField), WriteSamples.message);
    // A real network: the field is drawn while the message goes.
    fixtures.latency = const Duration(milliseconds: 300);
    await tester.tap(find.byTooltip('Send message'));
    // The forum's answer names the conversation: all of it shows.
    await _pumpUntil(tester, find.text(WriteSamples.messageReply));
    expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue,
        reason: 'the keyboard stays up for the next message');
    final sent = fixtures.requests.firstWhere((r) => r.method == 'POST').data as Map;
    expect(sent['data']['attributes']['users'], [
      {'id': bobId},
    ]);
    // What is still on its way (the read mark) arrives.
    await tester.pump(const Duration(seconds: 1));
  });
}
