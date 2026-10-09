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
        expect(lines, contains('bob replied to the private discussion Private: test plan'));
        model.dispose();
      });

      testWidgets('a tap opens the post it\'s about', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        await _pumpUntil(tester, find.byType(NotificationTile));
        await tester.tap(find.text('carol liked your post in Welcome to the test forum'));
        await _pumpUntil(tester, find.byType(ThreadPage));
        expect(fixtures.requests.any((r) => r.method == 'PATCH' && r.path.startsWith('/notifications/')), isTrue,
            reason: 'marked read');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a guest is asked to sign in', (tester) async {
        fixtures.forum(signedIn: false);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: NotificationsPage(site: _site())));
        expect(find.text('Sign in to see your notifications.'), findsOneWidget);
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
    await model.markRead(model.items.first);
    expect(model.items.first.isRead, isTrue);
    expect(await model.markAllRead(), isTrue);
    expect(model.items.every((n) => n.isRead), isTrue);
    expect(adapter.requests.map((r) => '${r.method} ${r.path}'), ['PATCH /notifications/1', 'POST /notifications/read']);
    model.dispose();
  });
}
