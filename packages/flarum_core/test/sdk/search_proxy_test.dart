import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/scripted.dart';
import 'site.dart';

void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version));

      test('a search finds discussions most relevant first, each with its best post as the excerpt', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite()).searchTopicAsync('thread', 0, 19, null);

        expect(result.result, isTrue);
        expect(result.topics.map((t) => t.id), [fixtures.discussionId('support'), fixtures.discussionId('long')]);
        expect(result.topics.first.shortContent, startsWith('Steps: open any thread with 50+ replies.'));
        expect(result.topics.last.shortContent, 'Post 1 of 60.');
        expect(result.totalTopicNum, 2);
        expect(result.hasMore, isFalse);
        final search = fixtures.requests.firstWhere((r) => r.path == '/discussions');
        expect(search.queryParameters.containsKey('sort'), isFalse, reason: 'no sort: relevance');
      });

      test('an empty search asks nothing', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite()).searchTopicAsync('  ', 0, 19, null);
        expect(result.result, isTrue);
        expect(result.topics, isEmpty);
        expect(fixtures.requests, isEmpty);
      });

      test('an advanced search by a user\'s id, leaving a tag out', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite()).advanceSearchTopicAsync(
            'thread', 1, 20, null, false, fixtures.userId('bob'), null, null, null, null, [fixtures.tagId('support')], false, null);

        expect(result.result, isTrue, reason: result.resultText);
        expect(result.topics.map((t) => t.title), ['Long thread for paging tests']);
        final search = fixtures.requests.lastWhere((r) => r.path == '/discussions').queryParameters;
        if (version == FlarumVersion.v1) {
          expect(search['filter[q]'], 'thread -tag:support author:bob', reason: '1.x conditions are gambits');
        } else {
          expect(search, containsPair('filter[author]', 'bob'));
          expect(search, containsPair('filter[-tag]', 'support'));
        }
      });

      test('a tag id the forum doesn\'t have fails the search instead of widening it', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite())
            .advanceSearchTopicAsync('thread', 1, 20, null, false, null, null, '999', null, null, null, false, null);
        expect(result.result, isFalse);
        expect(result.resultText, contains('no tag 999'));
      });

      test('a post search returns posts with their discussions', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite()).searchPostAsync('thread', 0, 19, null);

        expect(result.result, isTrue, reason: result.resultText);
        final first = result.posts.first;
        expect(first.topicId, fixtures.discussionId('support'));
        expect(first.topicTitle, 'App crashes when opening a long thread');
        expect(first.authorName, 'alice');
        expect(first.content, contains('open any thread'));
        // 2.0 searches posts; 1.x has the best post of each matching discussion.
        expect(result.posts, hasLength(version == FlarumVersion.v1 ? 2 : 1));
      });

      test('a post search by author', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite())
            .advanceSearchPostAsync('thread', 1, 20, null, false, null, 'alice', null, null, null, null, false);
        expect(result.result, isTrue, reason: result.resultText);
        expect(result.posts.map((p) => p.authorName), ['alice']);
      });

      test('with no keywords, an author\'s posts newest first', () async {
        fixtures.forum();
        final result = await FlarumSearchProxy(testSite())
            .advanceSearchPostAsync('', 1, 20, null, false, null, 'bob', null, null, null, null, false);
        expect(result.posts, hasLength(20));
        expect(result.posts.every((p) => p.authorName == 'bob'), isTrue);
        expect(result.hasMore, isTrue);
      });

      if (version == FlarumVersion.v1) {
        test('1.x can\'t search within a discussion, and says so', () async {
          fixtures.forum();
          final result = await FlarumSearchProxy(testSite()).advanceSearchPostAsync(
              'thread', 1, 20, null, false, null, null, null, fixtures.discussionId('long'), null, null, false);
          expect(result.result, isFalse);
          expect(result.resultText, contains('can\'t search within a discussion'));
        });
      }
    });
  }

  test('titles only keeps the discussions whose title has every word', () async {
    Map<String, Object> discussion(String id, String title) => {
          'type': 'discussions',
          'id': id,
          'attributes': {'title': title, 'slug': '$id-x', 'commentCount': 1},
        };
    final adapter = ScriptedAdapter([
      (200, {'data': [discussion('1', 'Long thread for paging'), discussion('2', 'A thread, not long in the title')], 'links': {}}),
      (200, {'data': {'type': 'forums', 'id': '1', 'attributes': {'title': 'x'}}}),
    ]);
    FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio());
    final result = await FlarumSearchProxy(testSite())
        .advanceSearchTopicAsync('Long  paging', 1, 20, null, true, null, null, null, null, null, null, false, null);
    expect(result.result, isTrue, reason: result.resultText);
    expect(result.topics.map((t) => t.id), ['1']);
  });
}
