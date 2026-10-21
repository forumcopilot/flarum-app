import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        final newest = DiscussionListModel(fixtures.forum(), sort: DiscussionSort.newest);
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
        expect(find.byIcon(Icons.check), findsOneWidget, reason: 'only the answered one, a green check as on the web');
        expect(tester.widget<Icon>(find.byIcon(Icons.check)).semanticLabel, 'Answered');
      });

      testWidgets('the home page lists discussions and opens one where the reader left off', (tester) async {
        fixtures.forum();
        // Who the private discussion is with, read for its row (none was recorded for it).
        fixtures.replies['GET /discussions/${fixtures.discussionId('private')}'] = {
          'data': {
            'type': 'discussions',
            'id': fixtures.discussionId('private'),
            'attributes': {'title': 'Private: test plan'},
            'relationships': {
              'recipientUsers': {
                'data': [
                  {'type': 'users', 'id': '90'},
                ],
              },
            },
          },
          'included': [
            {'type': 'users', 'id': '90', 'attributes': {'username': 'carol', 'displayName': 'carol'}},
          ],
        };
        // Tall enough for the private discussion's row, under the stickies' opening words.
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        expect(find.text('All Discussions'), findsOneWidget, reason: "the view menu's face");
        expect(find.byIcon(Icons.map_outlined), findsOneWidget, reason: 'the byobu discussion is marked private, with byobu\'s map');
        await _pumpUntil(tester, find.text('With carol'));
        expect(find.byIcon(Icons.push_pin), findsWidgets, reason: "the rules are sticky: the web's red pin");

        await tester.tap(find.text('Long thread for paging tests'));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));

        Navigator.of(tester.element(find.byType(ThreadPage))).pop();
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('the view menu switches the list, as the web\'s sidebar; the sort menu orders it', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byTooltip('Toggle navigation dropdown menu'));
        await tester.pumpAndSettle();
        for (final view in ['All Discussions', 'Following', 'Bookmarks', 'Private Discussions', 'Support']) {
          expect(find.text(view), findsWidgets, reason: view);
        }
        expect(find.text('Messages'), version == FlarumVersion.v2 ? findsOneWidget : findsNothing,
            reason: 'flarum/messages is 2.0 only');
        await tester.tap(find.text('Following').last);
        await tester.pumpAndSettle();
        await _pumpUntil(tester, find.textContaining('Feature request: dark mode'));
        expect(find.byType(DiscussionTile), findsOneWidget, reason: 'the one alice follows');
        expect(fixtures.requests.last.queryParameters['filter[subscription]'] ?? fixtures.requests.last.queryParameters['filter[q]'],
            anyOf('following', contains('is:following')));

        await tester.tap(find.byTooltip('Change discussion list sorting'));
        await tester.pumpAndSettle();
        expect(find.text('Oldest'), findsOneWidget);
        expect(find.text('Title (A–Z)'), version == FlarumVersion.v2 ? findsOneWidget : findsNothing,
            reason: '1.x refuses sorting by title');
        await tester.tap(find.text('Oldest'));
        await tester.pumpAndSettle();
        expect(fixtures.requests.last.queryParameters['sort'], 'createdAt');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets("a sticky discussion the reader hasn't opened shows its opening words, as flarum/sticky does", (tester) async {
        // 1.x: the first post, read for the row (2.0 sends the words with the list).
        fixtures.replies['GET /posts'] = {
          'data': [
            {
              'type': 'posts',
              'id': '9',
              'attributes': {'number': 1, 'contentType': 'comment', 'contentHtml': '<p>Be kind. Stay on topic.</p>'},
            },
          ],
        };
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await _pumpUntil(tester, find.textContaining('Be kind. Stay on topic.'));
        expect(
          find.descendant(of: find.widgetWithText(DiscussionTile, 'Formatting samples'), matching: find.textContaining('Be kind')),
          findsNothing,
          reason: 'only under the sticky ones',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('Mark All as Read asks first, then marks every discussion read and reloads', (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        final reader = forum.info!.actor!.id;
        fixtures.replies['PATCH /users/$reader'] = {
          'data': {'type': 'users', 'id': reader, 'attributes': <String, Object>{}},
        };
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        final lists = fixtures.requests.where((r) => r.path == '/discussions').length;

        await tester.tap(find.byTooltip('Mark All as Read'));
        await tester.pumpAndSettle();
        expect(find.text('Are you sure you want to mark all discussions as read?'), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pump(const Duration(seconds: 1));
        final sent = fixtures.requests.singleWhere((r) => r.method == 'PATCH' && r.path == '/users/$reader');
        expect((sent.data as Map)['data']['attributes'], contains('markedAllAsReadAt'));
        expect(fixtures.requests.where((r) => r.path == '/discussions').length, greaterThan(lists), reason: 'reloaded');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a guest is offered Start a Discussion, as on the web', (tester) async {
        fixtures
          ..guestReadsMember = true
          ..forum(signedIn: false);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        expect(find.widgetWithText(FloatingActionButton, 'Start a Discussion'), findsOneWidget);
        expect(find.byTooltip('Mark All as Read'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets("the forum's welcome message heads Latest, and stays hidden once hidden", (tester) async {
        SharedPreferences.setMockInitialValues({});
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        final title = forum.info!.welcomeTitle!;
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pump();
        expect(find.text(title), findsOneWidget);
        await tester.tap(find.byTooltip('Hide welcome message'));
        await tester.pump();
        expect(find.text(title), findsNothing);

        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await tester.pump();
        expect(find.text(title), findsNothing, reason: 'hidden on this phone until the forum changes it');
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
