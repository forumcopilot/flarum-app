import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/messages/dialog_page.dart';
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

  testWidgets('a notification from the forum itself shows its kind, not a "?" avatar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: FlarumLocalizations.localizationsDelegates,
      home: const Material(
        child: Column(children: [
          NotificationTile(notification: FlarumNotification(id: '1', contentType: 'userSuspended')),
          NotificationTile(notification: FlarumNotification(id: '2', contentType: 'userUnsuspended')),
        ]),
      ),
    ));
    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.text('?'), findsNothing);
  });

  testWidgets('Flarum v2: a message notification opens its conversation, with the message under it', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _root);
    Map<String, dynamic> recorded(String name) =>
        (jsonDecode(File('$_root/v2/$name.json').readAsStringSync()) as Map<String, dynamic>)['body'] as Map<String, dynamic>;
    // A message as flarum/messages sends it (carrying its dialog as linkage only), and the
    // notification of it, which the test forums' members don't get: by default it's emailed.
    final message = (recorded('write_dialog_messages')['data'] as List).first as Map<String, dynamic>;
    final dialog = (message['relationships'] as Map)['dialog']['data']['id'];
    final list = recorded('notifications');
    fixtures.replies['GET /notifications'] = {
      ...list,
      'data': [
        {
          'type': 'notifications',
          'id': '900',
          'attributes': {'contentType': 'messageReceived', 'createdAt': '2026-10-20T10:00:00+00:00', 'isRead': false},
          'relationships': {
            'subject': {
              'data': {'type': 'dialog-messages', 'id': message['id']},
            },
            'fromUser': {
              'data': {'type': 'users', 'id': '3'},
            },
          },
        },
        ...list['data'] as List,
      ],
      'included': [...list['included'] as List, message],
    };
    fixtures.forum();
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
    await _pumpUntil(tester, find.textContaining('sent you a message'));
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.textContaining('Got it, thanks.'), findsOneWidget, reason: 'the message, as a post shows under its line');
    await tester.tap(find.textContaining('sent you a message'));
    await _pumpUntil(tester, find.byType(DialogPage));
    expect(tester.widget<DialogPage>(find.byType(DialogPage)).dialogId, dialog);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: _root));

      test('the reader\'s notifications, each worded with who and where', () async {
        final model = NotificationsModel(fixtures.forum());
        await model.refresh();
        expect(model.items, hasLength(4));
        late FlarumLocalizations l10n;
        l10n = lookupFlarumLocalizations(const Locale('en'));
        final lines = model.items.map((n) => NotificationTile.message(n, l10n)).toList();
        expect(lines, contains('carol liked your post in Welcome to the test forum'));
        expect(lines, contains('bob replied to your post in Welcome to the test forum'));
        expect(lines, contains("bob posted in a private discussion you're a part of: Private: test plan"));
        model.dispose();
      });

      testWidgets('a tap opens the post it\'s about', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        await _pumpUntil(tester, find.byType(NotificationTile));
        await tester.tap(find.text('carol liked your post'));
        await _pumpUntil(tester, find.byType(ThreadPage));
        expect(fixtures.requests.any((r) => r.method == 'PATCH' && r.path.startsWith('/notifications/')), isTrue,
            reason: 'marked read');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('notifications sit under their discussion, with the kind, the line and the post', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        await _pumpUntil(tester, find.byType(NotificationTile));
        expect(find.text('Welcome to the test forum'), findsOneWidget, reason: "the discussion's title heads its group");
        expect(find.text('carol liked your post'), findsOneWidget, reason: "the web's own line, without the title");
        expect(find.byIcon(Icons.thumb_up), findsOneWidget, reason: 'a like, marked as the web marks it');
        expect(find.textContaining('Looking forward to testing'), findsWidgets, reason: 'a line of the post it is about');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets("the settings say which notifications come, as the forum's settings page; a change is saved",
          (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        final reader = forum.info!.actor!.id;
        final emailed = forum.info!.preferences['notify_newPost_email'] == true;
        fixtures.replies['PATCH /users/$reader'] = {
          'data': {'type': 'users', 'id': reader, 'attributes': <String, Object>{}},
        };
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        await _pumpUntil(tester, find.byType(NotificationTile));
        await tester.tap(find.byTooltip('Settings'));
        await _pumpUntil(tester, find.text('Someone likes one of my posts'));
        // The page has finished sliding in.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.text('Someone posts in a discussion I\'m following'), findsOneWidget);
        expect(find.text('Someone sends me a message'), version == FlarumVersion.v2 ? findsOneWidget : findsNothing,
            reason: 'flarum/messages is 2.0 only');
        expect(find.text('Automatically follow discussions that I reply to'), findsOneWidget);

        // The email box on the following row (likes come on the web only: flarum/likes sends no email).
        final row = find.ancestor(of: find.text('Someone posts in a discussion I\'m following'), matching: find.byType(Row)).first;
        final boxes = find.descendant(of: row, matching: find.byType(Checkbox));
        expect(boxes, findsNWidgets(2));
        expect(find.descendant(
          of: find.ancestor(of: find.text('Someone likes one of my posts'), matching: find.byType(Row)).first,
          matching: find.byType(Checkbox),
        ), findsOneWidget);
        await tester.tap(boxes.last);
        await tester.pump(const Duration(milliseconds: 300));
        final sent = fixtures.requests.singleWhere((r) => r.method == 'PATCH' && r.path == '/users/$reader');
        expect((sent.data as Map)['data']['attributes'], {
          'preferences': {'notify_newPost_email': !emailed},
        });
        expect(tester.widget<Checkbox>(boxes.last).value, !emailed);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a guest is asked to sign in', (tester) async {
        fixtures.forum(signedIn: false);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        expect(find.text('Log in to see your notifications.'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);
        expect(fixtures.requests, isEmpty);
      });

      testWidgets('the app doesn\'t list notifications until the tab is opened', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(FlarumApp(site: _site()));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        expect(fixtures.requests.where((r) => r.path == '/notifications'), isEmpty);
        await tester.tap(find.text('Notifications'));
        await _pumpUntil(tester, find.byType(NotificationTile));
        expect(fixtures.requests.where((r) => r.path == '/notifications'), hasLength(1));
      });

      testWidgets('coming back to Notifications loads the list again', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(FlarumApp(site: _site()));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.tap(find.text('Notifications'));
        await _pumpUntil(tester, find.byType(NotificationTile));
        await tester.tap(find.text('Home'));
        await tester.pump();
        await tester.tap(find.text('Notifications'));
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(fixtures.requests.where((r) => r.path == '/notifications'), hasLength(2),
            reason: 'what came in meanwhile is listed, as the web lists it each time it opens');
      });

      testWidgets('a next page that fails offers Retry, not a spinner that never stops', (tester) async {
        // The first page says there is more.
        final page = jsonDecode(File('$_root/${version.name}/notifications.json').readAsStringSync())['body'] as Map<String, dynamic>;
        fixtures.replies['GET /notifications'] = {...page, 'links': {'next': 'https://forum.test/api/notifications?page[offset]=20'}};
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        await _pumpUntil(tester, find.byType(NotificationTile));
        fixtures.offline = true;
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await _pumpUntil(tester, find.text('Retry'));
        fixtures.offline = false;
        await tester.tap(find.text('Retry'));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Retry'), findsNothing);
        expect(fixtures.requests.where((r) => r.path == '/notifications'), hasLength(3));
      });

      testWidgets('the badge counts the rows the list shows, not each notification it groups', (tester) async {
        // Read before the app starts, as it is when the app starts signed in.
        await tester.runAsync(fixtures.forum().refresh);
        await tester.pumpWidget(FlarumApp(site: _site()));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        Finder badge(String count) => find.descendant(of: find.byType(NavigationBar), matching: find.text(count));
        // The forum counts 5 unread: two of them about the same thing, which it lists as one.
        expect(badge('5'), findsOneWidget);
        await tester.tap(find.text('Notifications'));
        await _pumpUntil(tester, find.byType(NotificationTile));
        await _pumpUntil(tester, badge('4'));
        expect(find.byType(NotificationTile), findsNWidgets(4));
      });
    });
  }

  test('marking one read, and all, tell the forum', () async {
    final adapter = ScriptedAdapter([
      (200, {'data': {'type': 'notifications', 'id': '1', 'attributes': {'isRead': true}}}),
      (204, null),
    ]);
    final forum = FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio())..api.client.token = 't';
    final model = NotificationsModel(forum)
      ..items.addAll(const [
        FlarumNotification(id: '1', contentType: 'postLiked'),
        FlarumNotification(id: '2', contentType: 'newPost'),
      ]);
    expect(await model.markRead(model.items.first), isTrue, reason: 'the forum marked it, so the badge reloads');
    expect(model.items.first.isRead, isTrue);
    expect(await model.markRead(model.items.first), isFalse, reason: 'already read: nothing sent');
    expect(await model.markAllRead(), isTrue);
    expect(model.items.every((n) => n.isRead), isTrue);
    expect(adapter.requests.map((r) => '${r.method} ${r.path}'), ['PATCH /notifications/1', 'POST /notifications/read']);
    model.dispose();
  });
}
