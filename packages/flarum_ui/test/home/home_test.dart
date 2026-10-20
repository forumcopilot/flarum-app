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

      testWidgets('a question with a best answer is marked answered', (tester) async {
        final api = fixtures.api();
        final (answered, plain) = (await tester.runAsync(() => (
              api.discussion(fixtures.discussionId('answered')),
              api.discussion(fixtures.discussionId('welcome')),
            ).wait))!;
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: Column(children: [DiscussionTile(discussion: answered), DiscussionTile(discussion: plain)])),
        ));
        expect(find.byIcon(Icons.check_circle), findsOneWidget, reason: 'only the answered one');
        expect(tester.widget<Icon>(find.byIcon(Icons.check_circle)).semanticLabel, 'Answered');
      });

      testWidgets('the home page lists discussions and opens one where the reader left off', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        expect(find.text('Following'), findsOneWidget, reason: 'signed in');
        expect(find.byIcon(Icons.mail_outline), findsOneWidget, reason: 'the byobu discussion is marked private');

        await tester.tap(find.text('Long thread for paging tests'));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));

        Navigator.of(tester.element(find.byType(ThreadPage))).pop();
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a refresh that fails keeps the list and says why', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: Scaffold(body: HomePage(site: _site()))));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        final shown = find.byType(DiscussionTile).evaluate().length;

        fixtures.offline = true;
        await tester.fling(find.byType(DiscussionTile).first, const Offset(0, 400), 1000);
        await _pumpUntil(tester, find.text('Something seems to be wrong with your connection. Please check your network and try again.'));
        expect(find.byType(DiscussionTile), findsNWidgets(shown), reason: 'the list stays');
        expect(find.textContaining('DioException'), findsNothing);
        await tester.pump(const Duration(seconds: 10));
      });
    });
  }
}
