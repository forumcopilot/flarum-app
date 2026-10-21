import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

const _fixtures = '../flarum_core/test/fixtures';

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

/// Pumps until [finder] shows (or, with [gone], stops showing), for pages
/// that load from the fixtures.
Future<void> _pumpUntil(WidgetTester tester, Finder finder, {bool gone = false}) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty != gone; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, gone ? findsNothing : findsWidgets);
}

/// Closes the page and lets what it sends on the way out (the read mark) finish.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: _fixtures));

      test('a thread opens at its start and pages forward', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'));
        await model.open();
        expect(model.total, 60);
        expect(model.posts.map((p) => p.number), List.generate(20, (i) => i + 1));
        expect(model.hasPrevious, isFalse);
        expect(model.hasNext, isTrue);

        await model.loadNext();
        expect(model.posts.map((p) => p.number), List.generate(40, (i) => i + 1));
        model.dispose();
      });

      test('a thread opened at a post pages both ways from there', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'));
        await model.open(near: 21);
        expect(model.indexOfNumber(21), greaterThanOrEqualTo(0));
        expect(model.start, greaterThan(0));
        final start = model.start;

        expect(await model.loadPrevious(), start);
        expect(model.start, 0);
        expect(model.posts.first.number, 1);

        await model.loadNext();
        expect(model.posts.map((p) => p.number), List.generate(model.posts.length, (i) => i + 1),
            reason: 'one run of posts, no gaps or repeats');
        model.dispose();
      });

      test('reading is reported once it pauses, and only forward', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'), readDelay: Duration.zero);
        await model.open();
        model
          ..reportRead(15) // alice has read up to 20 already
          ..reportRead(24)
          ..reportRead(26);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final marks = fixtures.requests.where((r) => r.method == 'PATCH').toList();
        expect(marks, hasLength(1));
        expect(((marks.single.data as Map)['data'] as Map)['attributes'], {'lastReadPostNumber': 26});
        model.dispose();
      });

      test('a guest\'s reading is not reported', () async {
        final model = ThreadModel(fixtures.forum(signedIn: false), fixtures.discussionId('welcome'), readDelay: Duration.zero);
        model.reportRead(3);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(fixtures.requests.where((r) => r.method == 'PATCH'), isEmpty);
        model.dispose();
      });

      testWidgets("a post's link off the forum goes to the host first, which may open it in the app", (tester) async {
        fixtures.forum();
        final offered = <String>[];
        FlarumHost.openOtherForumLink = (context, url) async {
          offered.add(url);
          return true;
        };
        addTearDown(() => FlarumHost.openOtherForumLink = null);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.textContaining('a link'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tapOnText(find.textRange.ofSubstring('a link').first);
        await tester.pump();
        expect(offered, ['https://flarum.org'], reason: 'flarum.org: not this forum');
        await tester.tap(find.text('@bob').first);
        await tester.pump();
        expect(offered, hasLength(1), reason: "this forum's own links stay in it");
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets("a post's menu copies its web address", (tester) async {
        fixtures.forum();
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
          return null;
        });
        addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.descendant(of: find.byType(PostTile).at(1), matching: find.byIcon(Icons.more_vert)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Copy Link'));
        await tester.pump();
        final id = fixtures.discussionId('welcome');
        expect(copied, matches(RegExp('^${RegExp.escape(FixtureForum.baseUrl)}/d/$id(-[a-z0-9-]+)?/2\$')),
            reason: 'the second post, as Flarum links it');
        expect(find.text('Link copied.'), findsOneWidget);
        await _close(tester);
      });

      testWidgets("the discussion opens under its hero, in its tag's colour, and the bar takes the title on scroll",
          (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('long')),
        ));
        await _pumpUntil(tester, find.text('Post 1 of 60.'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.descendant(of: find.byType(AppBar), matching: find.text('Long thread for paging tests')), findsNothing,
            reason: 'the hero has the title');
        expect(find.text('Long thread for paging tests'), findsOneWidget);
        await tester.drag(find.byType(PostTile).first, const Offset(0, -1500));
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.descendant(of: find.byType(AppBar), matching: find.text('Long thread for paging tests')), findsOneWidget);
        await _close(tester);
      });

      testWidgets('a guest is offered Log In to Reply, and Reply under each post', (tester) async {
        fixtures
          ..guestReadsMember = true
          ..forum(signedIn: false);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.descendant(of: find.byKey(const ValueKey('thread-bar')), matching: find.text('Log In to Reply')),
            findsOneWidget);
        expect(find.descendant(of: find.byType(PostTile).first, matching: find.text('Reply')), findsOneWidget,
            reason: 'as the web shows it to guests, opening Log In');
        expect(find.text('Like'), findsNothing, reason: 'the web offers guests no Like');
        await _close(tester);
      });

      testWidgets('the page shows the posts, their authors and bodies', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        expect(find.text('Welcome to the test forum'), findsOneWidget, reason: 'the title');
        expect(find.byType(FlarumContent), findsWidgets);
        expect(find.text('admin'), findsWidgets);
        expect(find.descendant(of: find.byType(TagLabel), matching: find.text('General')), findsOneWidget,
            reason: 'the tags head the thread');
        await _close(tester);
      });

      testWidgets('who replied to a post, and the list of replies', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.text('bob and alice replied to this.'));
        // Clear of the bar at the bottom of the screen.
        await tester.drag(find.byType(PostTile).first, const Offset(0, -150));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('bob and alice replied to this.'));
        await _pumpUntil(tester, find.text('Replies to this post'));
        expect(find.text('Post #3'), findsOneWidget, reason: "bob's reply, in this discussion");
        expect(find.text('Formatting samples'), findsWidgets, reason: "alice's, in another one");
        await tester.tap(find.text('Post #3'));
        await tester.pump(const Duration(seconds: 1));
        await _close(tester);
      });

      testWidgets('a question shows its best answer, and offers the way to it', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('answered')),
        ));
        await _pumpUntil(tester, find.text('View Best Answer'));
        expect(find.text('View Best Answer'), findsOneWidget, reason: 'under the question');
        expect(find.text('Best Answer'), findsOneWidget, reason: 'above the answer, the second post');
        final answer = find.ancestor(of: find.text('Best Answer'), matching: find.byType(PostTile));
        expect(tester.widget<PostTile>(answer).post.number, 2);

        await tester.tap(find.text('View Best Answer'));
        await tester.pump(const Duration(seconds: 1));
        expect(fixtures.requests.where((r) => r.path.startsWith('/posts/')), isEmpty,
            reason: 'the answer is loaded, so it scrolls there without asking the forum');
        await _close(tester);
      });

      testWidgets('a jump to a post outside the window opens there, with the post at the top', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('long')),
        ));
        await _pumpUntil(tester, find.text('Post 1 of 60.'));
        // A real network: frames are drawn while the window loads.
        fixtures.latency = const Duration(milliseconds: 300);
        (tester.state(find.byType(ThreadPage)) as dynamic).goTo(21);
        await _pumpUntil(tester, find.text('Post 21 of 60.'));
        await tester.pump(const Duration(seconds: 2));
        expect(tester.getTopLeft(find.text('Post 21 of 60.')).dy, lessThan(250),
            reason: 'at the top, not half a page below, where the list used to stay');
        expect(find.text('Post 12 of 60.'), findsNothing, reason: "the window's first posts are above the screen");
        await _close(tester);
      });

      testWidgets('the bar says where the reader is, and its scrubber goes to the Original Post', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('long'), near: 21),
        ));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));
        await tester.pump(const Duration(milliseconds: 500));
        final bar = find.byKey(const ValueKey('thread-bar'));
        expect(find.descendant(of: bar, matching: find.textContaining(RegExp(r'^\d+ of \d+ posts$'))), findsOneWidget);
        await tester.tap(find.descendant(of: bar, matching: find.byIcon(Icons.unfold_more)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Original Post'));
        await _pumpUntil(tester, find.text('Post 1 of 60.'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.descendant(of: bar, matching: find.textContaining(RegExp(r'^1 of \d+ posts$'))), findsOneWidget);
        await _close(tester);
      });

      testWidgets('opened part-way down, it offers the posts before', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('long'), near: 21),
        ));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));
        await tester.drag(find.byType(PostTile).first, const Offset(0, 2000));
        await tester.pump();
        await _pumpUntil(tester, find.text('Load More'));
        await tester.tap(find.text('Load More'));
        await _pumpUntil(tester, find.text('Load More'), gone: true);
        expect(find.text('Post 1 of 60.'), findsNothing, reason: 'the reader stays where they were');
        await _close(tester);
      });
    });
  }

  group('forum links', () {
    const base = 'https://forum.test';
    test('a discussion, with or without slug and post number', () {
      expect(ForumLink.parse('$base/d/5-welcome/2', base), const DiscussionLink('5', 2));
      expect(ForumLink.parse('$base/d/5', base), const DiscussionLink('5'));
      expect(ForumLink.parse('$base/d/5-welcome', base), const DiscussionLink('5'));
    });

    test('users and tags', () {
      expect(ForumLink.parse('$base/u/bob', base), const UserLink('bob'));
      expect(ForumLink.parse('$base/t/support', base), const TagLink('support'));
    });

    test('a forum in a folder, and other sites', () {
      expect(ForumLink.parse('https://ex.com/forum/d/7/3', 'https://ex.com/forum'), const DiscussionLink('7', 3));
      expect(ForumLink.parse('https://ex.com/d/7', 'https://ex.com/forum'), isNull);
      expect(ForumLink.parse('https://forum.test.evil.com/d/5', base), isNull);
      expect(ForumLink.parse('$base/settings', base), isNull);
    });
  });

  testWidgets('event posts read as the web words them', (tester) async {
    late FlarumLocalizations l10n;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      l10n = flarumL10n(context);
      return const SizedBox();
    })));
    FlarumPost event(String type, Object? content) => FlarumPost(
          id: '1',
          number: 2,
          contentType: type,
          content: content,
          author: const FlarumUser(id: '2', username: 'alice', displayName: 'Alice'),
        );
    expect(EventPostNotice.describe(event('discussionRenamed', ['Old', 'New']), l10n).$2,
        'Alice changed the title from “Old” to “New”.');
    expect(EventPostNotice.describe(event('discussionLocked', {'locked': true}), l10n).$2, 'Alice locked the discussion.');
    expect(EventPostNotice.describe(event('discussionLocked', {'locked': false}), l10n).$2,
        'Alice unlocked the discussion.');
    expect(EventPostNotice.describe(event('discussionStickied', {'sticky': true}), l10n).$2,
        'Alice stickied the discussion.');
    expect(
        EventPostNotice.describe(
                event('recipientsModified', {
                  'new': {'users': [2, 3], 'groups': []},
                  'old': {'users': [], 'groups': []},
                }),
                l10n)
            .$2,
        'Alice changed who is in this private discussion.');
    expect(EventPostNotice.describe(event('discussionMerged', null), l10n).$2, 'Alice changed the discussion.');
    // fof/merge-discussions and fof/split, as their published source writes them.
    expect(
        EventPostNotice.describe(event('discussionMerged', {'count': 3, 'titles': ['One', 'Two']}), l10n).$2,
        'Alice merged 3 posts from “One”, “Two” into this discussion.');
    expect(
        EventPostNotice.describe(
                event('discussionSplit', {'title': 'Elsewhere', 'count': 1, 'url': 'https://f/d/9', 'toNew': true}), l10n)
            .$2,
        'Alice split 1 post off to “Elsewhere”.');
    expect(
        EventPostNotice.describe(
                event('discussionSplit', {'title': 'Origin', 'count': 2, 'url': 'https://f/d/8', 'toNew': false}), l10n)
            .$2,
        'Alice split 2 posts off from “Origin”.');
    final tags = {
      '1': const FlarumTag(id: '1', name: 'General', slug: 'general', isPrimary: true),
      '3': const FlarumTag(id: '3', name: 'Support', slug: 'support', isPrimary: true),
      '4': const FlarumTag(id: '4', name: 'iOS', slug: 'ios', isPrimary: true),
    };
    expect(EventPostNotice.describe(event('discussionTagged', [[1], [1, 4]]), l10n, tags: tags).$2, 'Alice added iOS.');
    expect(EventPostNotice.describe(event('discussionTagged', [[1, 4], [1]]), l10n, tags: tags).$2, 'Alice removed iOS.');
    expect(EventPostNotice.describe(event('discussionTagged', [[1], [3]]), l10n, tags: tags).$2,
        'Alice added Support and removed General.');
    expect(EventPostNotice.describe(event('discussionTagged', [[1], [3]]), l10n).$2, 'Alice changed the tags.',
        reason: 'without the tag list');
  });

  test('replies are worded as the web words them', () {
    final l10n = lookupFlarumLocalizations(const Locale('en'));
    FlarumPostReply by(String name) =>
        FlarumPostReply(id: name, author: FlarumUser(id: name, username: name, displayName: name));
    FlarumPost post(int count, List<String> names) =>
        FlarumPost(id: '1', number: 1, contentType: 'comment', mentionedByCount: count, mentionedBy: [for (final n in names) by(n)]);
    expect(repliedBy(post(1, ['bob']), l10n), 'bob replied to this.');
    expect(repliedBy(post(3, ['bob', 'alice', 'alice']), l10n), 'bob and alice replied to this.');
    expect(repliedBy(post(4, ['bob', 'alice', 'carol']), l10n), 'bob, alice and 2 others replied to this.');
    expect(repliedBy(post(2, ['bob']), l10n), 'bob and 1 other replied to this.', reason: '2.0 lists only some');
    expect(repliedBy(post(2, []), l10n), '2 replies');
  });
}
