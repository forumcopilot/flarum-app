import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Milestone 2's actions on posts and discussions, replayed from the write fixtures
/// (tool/record_write_fixtures.dart): carol asked in the Q&A tag and bob answered.
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumApi api;
      Map<String, dynamic> fixture(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      // The answer and the question as recorded: their ids are in the requests' paths.
      String answerId() => (fixture('write_like')['request']['path'] as String).split('/').last;
      String questionId() => (fixture('write_follow')['request']['path'] as String).split('/').last;

      setUp(() {
        fixtures = FixtureForum(version);
        api = fixtures.api();
      });

      test('likes a post and takes the like back', () async {
        final liked = await api.likePost(answerId(), liked: true);
        expect(liked.likesCount, 1);
        expect(liked.isLikedBy(fixtures.userId('carol')), isTrue);
        final unliked = await api.likePost(answerId(), liked: false);
        expect(unliked.likesCount, 0);
        expect(unliked.isLikedBy(fixtures.userId('carol')), isFalse);
      });

      test('reacts, and the same reaction again takes it back', () async {
        final reacted = await api.reactToPost(answerId(), '5');
        expect(reacted.reactionCounts, {'5': 1});
        expect(reacted.userReactionId, '5');
        final taken = await api.unreactToPost(answerId(), '5');
        expect(taken.reactionCounts, isEmpty);
        expect(taken.userReactionId, isNull);
      });

      test('chooses a best answer and clears it, as each version takes it', () async {
        final chosen = await api.setBestAnswer(questionId(), answerId());
        expect(chosen.bestAnswerPostId, answerId());
        final cleared = await api.setBestAnswer(questionId(), null);
        expect(cleared.bestAnswerPostId, isNull);
        final sent = fixtures.requests.firstWhere((r) => r.method == 'PATCH').data as Map;
        if (version == FlarumVersion.v1) {
          expect(sent['data']['attributes'], {'bestAnswerPostId': int.parse(answerId())});
        } else {
          expect(sent['data']['relationships']['bestAnswerPost']['data'], {'type': 'posts', 'id': answerId()});
          expect(sent['data']['attributes'], isEmpty, reason: 'rc.8 fails with 500 without them');
        }
      });

      test('follows, ignores and stops following a discussion', () async {
        expect((await api.setSubscription(questionId(), 'follow')).subscription, 'follow');
        expect((await api.setSubscription(questionId(), 'ignore')).subscription, 'ignore');
        expect((await api.setSubscription(questionId(), null)).subscription, isNull);
      });

      test('bookmarks a post and a discussion, and lists them', () async {
        expect((await api.bookmarkPost(answerId(), bookmarked: true)).bookmarked, isTrue);
        expect((await api.bookmarkDiscussion(questionId(), bookmarked: true)).bookmarked, isTrue);
        final discussions = await api.discussions(bookmarked: true);
        expect(discussions.items.map((d) => d.id), [questionId()], reason: '1.x lists them only by gambit');
        final posts = await api.bookmarkedPosts();
        expect(posts.items.map((p) => p.id), [answerId()]);
        expect((await api.bookmarkPost(answerId(), bookmarked: false)).bookmarked, isFalse);
        expect((await api.bookmarkDiscussion(questionId(), bookmarked: false)).bookmarked, isFalse);
      });

      test('sets a tag\'s level and clears it, through each version\'s own route', () async {
        final cycling = (fixture('write_tag_follow')['request']['path'] as String).split('/')[2];
        await api.setTagSubscription(cycling, 'follow');
        await api.setTagSubscription(cycling, null);
        final sent = fixtures.requests.firstWhere((r) => r.method != 'GET');
        expect('${sent.method} ${sent.path}', version == FlarumVersion.v1 ? 'POST /tags/$cycling/subscription' : 'PATCH /tags/$cycling');
      });
    });
  }

  test('the forum\'s reactions come with its info', () async {
    final info = await FixtureForum(FlarumVersion.v2).api().forumInfo();
    expect(info.reactions.map((r) => r.identifier), ['thumbsup', 'thumbsdown', 'laughing', 'confused', 'heart', 'tada']);
  });
}
