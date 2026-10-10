import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import 'package:flarum_core/testing.dart';
import 'site.dart';

void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumTopicProxy proxy;

      setUp(() {
        FlarumForum.resetForTesting();
        fixtures = FixtureForum(version);
        fixtures.forum();
        proxy = FlarumTopicProxy(testSite());
      });

      String tagId(String slug) => (fixtures.seed['tags'] as Map)[slug] as String;
      FCTopic titled(List<FCTopic> topics, String title) => topics.singleWhere((t) => t.title == title);

      test('latest discussions, with authors, read state and links', () async {
        final result = await proxy.getLatestTopicAsync(0, 19);
        expect(result.result, isTrue);
        expect(result.topics, hasLength(20));
        expect(result.totalLatestNum, greaterThan(result.topics.length), reason: 'the community content fills a second page');

        final welcome = titled(result.topics, 'Welcome to the test forum');
        expect(welcome.authorName, 'admin');
        expect(welcome.lastPosterName, 'carol');
        expect(welcome.replyCount, 3);
        // alice has read to post 2 of 4.
        expect(welcome.unreadCount, 2);
        expect(welcome.hasNewPosts, isTrue);
        expect(welcome.url, 'https://forum.test/d/${fixtures.discussionId('welcome')}-welcome-to-the-test-forum');
        expect(welcome.forumName, 'General');

        final long = titled(result.topics, 'Long thread for paging tests');
        expect(long.unreadCount, 40);

        final rules = titled(result.topics, 'Forum rules');
        expect(rules.isPinned, isTrue);
        expect(rules.isClosed, isTrue);
      });

      test('a tag\'s discussions, filed under the child tag, with secondary tags as tags', () async {
        final result = await proxy.getTopicAsync(tagId('support'), 0, 19);
        expect(result.result, isTrue);
        expect(result.forumName, 'Support');
        expect(result.canPost, isTrue);
        expect(result.canSubscribe, isTrue);

        final crash = result.topics.single;
        expect(crash.title, 'App crashes when opening a long thread');
        expect(crash.forumId, tagId('ios'));
        expect(crash.forumName, 'iOS');
        expect(crash.tags, ['bug']);
      });

      test('top, stickies, newest, unread and started-by lists', () async {
        expect((await proxy.getTopTopicAsync(tagId('support'), 0, 19)).topics.single.title,
            'App crashes when opening a long thread');
        expect((await proxy.getAnnTopicAsync('', 0, 19)).topics.map((t) => t.title),
            unorderedEquals(['Forum rules', 'Welcome! Start here']));
        final newest = await proxy.getNewTopicAsync(0, 19);
        expect(newest.topics.first.createdAtOrder(newest.topics[1]), isTrue);
        expect((await proxy.getUnreadTopicAsync(0, 19)).topics, isNotEmpty);
        final bob = await proxy.getParticipatedTopicAsync('bob', 0, 19);
        expect(bob.topics.map((t) => t.authorName).toSet(), {'bob'});
      });

      test('a list of ids, and their status', () async {
        final id = fixtures.discussionId('welcome');
        expect((await proxy.getTopicByIds([id])).topics.single.id, id);

        final status = (await proxy.getTopicStatusAsync([id])).topics.single;
        expect(status.newPost, isTrue);
        expect(status.replyNumber, 3);
        expect(status.isClosed, isFalse);
      });

      test('marking posts read sends the highest number', () async {
        final id = fixtures.discussionId('long');
        await proxy.markPostsReadAsync(topicId: id, postNumbers: [21, 25, 23]);
        final patch = fixtures.requests.last;
        expect(patch.method, 'PATCH');
        expect(patch.path, '/discussions/$id');
        expect(((patch.data as Map)['data'] as Map)['attributes'], {'lastReadPostNumber': 25});
      });

      test('a range wider than 50 is asked for as 50', () async {
        await proxy.getLatestTopicAsync(0, 199);
        expect(fixtures.requests.last.queryParameters['page[limit]'], '50');
      });
    });
  }

  test('a guest marks nothing read and sends nothing', () async {
    FlarumForum.resetForTesting();
    final fixtures = FixtureForum(FlarumVersion.v2);
    fixtures.forum(signedIn: false);
    final result = await FlarumTopicProxy(testSite()).markPostsReadAsync(topicId: '1', postNumbers: [3]);
    expect(result.result, isTrue);
    expect(fixtures.requests, isEmpty);
  });

  group('unreadCount, as Flarum\'s web counts', () {
    FlarumDiscussion discussion({int last = 10, int? read = 4, int comments = 10, DateTime? lastPosted}) => FlarumDiscussion(
          id: '1',
          title: 't',
          lastPostNumber: last,
          lastReadPostNumber: read,
          commentCount: comments,
          lastPostedAt: lastPosted ?? DateTime.utc(2026, 10, 9),
        );

    test('counts the posts after the reader\'s mark', () {
      expect(unreadCount(discussion(), null, signedIn: true), 6);
      expect(unreadCount(discussion(read: null), null, signedIn: true), 10);
    });

    test('is zero for guests and for discussions older than "mark all read"', () {
      expect(unreadCount(discussion(), null, signedIn: false), 0);
      expect(unreadCount(discussion(), DateTime.utc(2026, 10, 10), signedIn: true), 0);
      expect(unreadCount(discussion(), DateTime.utc(2026, 10, 8), signedIn: true), 6);
    });

    test('never exceeds the comments, when deleted posts leave gaps', () {
      expect(unreadCount(discussion(last: 30, read: 0, comments: 12), null, signedIn: true), 12);
    });
  });
}

extension on FCTopic {
  bool createdAtOrder(FCTopic other) => !timestamp.isBefore(other.timestamp);
}
