import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _root = '../flarum_core/test/fixtures';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

/// The Messages tab's badge: bob's unread conversations (flarum/messages, 2.0).
Finder _messagesBadge(String count) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.descendant(of: find.byType(Badge), matching: find.text(count)),
    );

void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
  });

  /// The 2.0 forum's info as recorded, with the reader's unread conversations at [messages].
  Map<String, dynamic> forumWith(int messages) {
    final body = Map<String, dynamic>.from(
        (jsonDecode(File('$_root/v2/forum.json').readAsStringSync()) as Map)['body'] as Map);
    body['included'] = [
      for (final resource in body['included'] as List)
        if ((resource as Map)['type'] == 'users' && (resource['attributes'] as Map).containsKey('messageCount'))
          {
            ...resource,
            'attributes': {...resource['attributes'] as Map, 'messageCount': messages},
          }
        else
          resource,
    ];
    return body;
  }

  testWidgets("the badges follow the forum's info wherever it's read again, and when the app comes back",
      (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _root);
    final forum = fixtures.forum();
    await tester.runAsync(forum.refresh);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AppShell(site: _site())));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_messagesBadge('1'), findsOneWidget);

    // A conversation read (its page reads the forum's info again): the tab follows at once.
    fixtures.replies['GET '] = forumWith(0);
    await tester.runAsync(forum.refresh);
    await tester.pump();
    expect(_messagesBadge('1'), findsNothing);

    // A message comes while the app is away; back in front, the count is read again.
    fixtures.replies['GET '] = forumWith(2);
    final before = fixtures.requests.where((r) => r.path.isEmpty).length;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(fixtures.requests.where((r) => r.path.isEmpty).length, greaterThan(before));
    expect(_messagesBadge('2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: the tabs are the Discourse app\'s, and the drawer is the forum\'s map',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fixtures = FixtureForum(version, root: _root);
      await tester.runAsync(fixtures.forum().refresh);
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AppShell(site: _site())));
      await tester.pump(const Duration(milliseconds: 300));
      final bar = find.byType(NavigationBar);
      for (final tab in ['Home', 'Messages', 'Notifications', 'Profile']) {
        expect(find.descendant(of: bar, matching: find.text(tab)), findsOneWidget, reason: tab);
      }
      expect(find.descendant(of: bar, matching: find.text('Tags')), findsNothing, reason: "the tags are Home's and the drawer's");

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      final drawer = find.byType(ForumDrawer);
      for (final item in ['Community', 'All Discussions', 'Following', 'Bookmarks', 'My Posts', 'Tags', 'Support', 'All Tags']) {
        expect(find.descendant(of: drawer, matching: find.text(item)), findsOneWidget, reason: item);
      }
      expect(find.descendant(of: drawer, matching: find.text('iOS')), findsNothing, reason: 'folded under Support');
      await tester.tap(find.byTooltip('Show tags in Support'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: drawer, matching: find.text('iOS')), findsOneWidget);

      // Back closes the drawer first (on the app's first route, Android left the app instead).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ForumDrawer), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: drawer, matching: find.text('Following')));
      for (var i = 0; i < 40 && find.byType(FollowingPage).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final followed = find.descendant(of: find.byType(FollowingPage), matching: find.byType(DiscussionTile));
      for (var i = 0; i < 40 && followed.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(followed, findsOneWidget, reason: 'the one alice follows');
      expect(find.descendant(of: followed, matching: find.text('Feature request: dark mode')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
