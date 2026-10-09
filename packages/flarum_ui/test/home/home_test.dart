import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: Site(
        id: null,
        name: 'Test forum',
        url: FixtureForum.baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: FixtureForum.baseUrl,
        siteType: FlarumProxyFactory.siteType,
        language: null,
      ),
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

      setUp(() => fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures'));

      test('the latest discussions, with what the reader has left unread', () async {
        final list = DiscussionListModel(fixtures.forum());
        await list.refresh();
        expect(list.error, isNull);
        expect(list.items, isNotEmpty);
        final long = list.items.singleWhere((d) => d.id == fixtures.discussionId('long'));
        expect(list.unreadIn(long), 40, reason: 'alice has read 20 of 60');
        expect(list.openAt(long), 21, reason: 'the first post she hasn\'t read');
        list.dispose();
      });

      test('a guest has nothing unread and opens discussions at their start', () async {
        final list = DiscussionListModel(fixtures.forum(signedIn: false));
        // No guest fixture for the list itself; the rules apply to any discussion.
        const d = FlarumDiscussion(id: '1', title: 't', lastPostNumber: 9, lastReadPostNumber: 2, commentCount: 9);
        expect(list.unreadIn(d), 0);
        expect(list.openAt(d), isNull);
        list.dispose();
      });

      test('the other views ask for their own order', () async {
        final newest = DiscussionListModel(fixtures.forum(), view: DiscussionView.newest);
        await newest.refresh();
        expect(fixtures.requests.last.queryParameters['sort'], '-createdAt');

        final following = DiscussionListModel(fixtures.forum(), view: DiscussionView.following);
        await following.refresh();
        expect(following.items.map((d) => d.title), ['Feature request: dark mode']);
        newest.dispose();
        following.dispose();
      });

      testWidgets('the home page lists discussions and opens one where the reader left off', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        expect(find.text('Following'), findsOneWidget, reason: 'signed in');

        await tester.tap(find.text('Long thread for paging tests'));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));

        Navigator.of(tester.element(find.byType(ThreadPage))).pop();
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  }
}
