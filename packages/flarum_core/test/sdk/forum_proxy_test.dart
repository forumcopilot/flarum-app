import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import 'site.dart';

void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumForumProxy proxy;

      setUp(() {
        FlarumForum.resetForTesting();
        fixtures = FixtureForum(version);
        fixtures.forum();
        proxy = FlarumForumProxy(testSite());
      });

      String tagId(String slug) => (fixtures.seed['tags'] as Map)[slug] as String;
      String welcomePost(int index) => ((fixtures.seed['posts'] as Map)['welcome'] as List)[index] as String;

      test('the forum tree is the primary tags in order, with child tags under their parent', () async {
        final result = await proxy.getForumAsync(true, '', false);
        expect(result.result, isTrue);
        expect(result.forums.map((f) => f.slug), ['general', 'support', 'feedback', 'announcements']);

        final support = result.forums[1];
        expect(support.childForums.map((f) => f.slug), ['ios']);
        expect(support.isSubForumContainer, isTrue);
        expect(support.description, 'Support discussions');
        expect(support.color, '#e67e22');
        expect(support.topicCount, 1);
        expect(support.canPost, isTrue);
        expect(support.canSubscribe, isTrue, reason: 'fof/follow-tags is on');
        expect(support.childForums.single.parentId, support.id);
      });

      test('a forum id lists that tag\'s children only', () async {
        final result = await proxy.getForumAsync(false, tagId('support'), false);
        expect(result.forums.map((f) => f.slug), ['ios']);
        expect(result.forums.single.description, isNull);
      });

      test('reads discussion and tag links', () async {
        final discussion = fixtures.discussionId('welcome');
        final post = await proxy.getIdByUrl('https://forum.test/d/$discussion-welcome-to-the-test-forum/2');
        expect(post.result, isTrue);
        expect(post.topicId, discussion);
        expect(post.postId, welcomePost(1));

        final bare = await proxy.getIdByUrl('https://forum.test/d/$discussion');
        expect(bare.topicId, discussion);
        expect(bare.postId, isNull);

        expect((await proxy.getIdByUrl('https://forum.test/t/support')).forumId, tagId('support'));
        expect((await proxy.getIdByUrl('https://elsewhere.test/d/1')).result, isFalse);
        expect((await proxy.getIdByUrl('https://forum.test/u/alice')).result, isFalse);
      });

      test('builds links to discussions, posts and tags', () async {
        final discussion = fixtures.discussionId('welcome');
        expect((await proxy.getUrlById('topic', discussion)).url, 'https://forum.test/d/$discussion');
        expect((await proxy.getUrlById('post', welcomePost(1))).url, 'https://forum.test/d/$discussion/2');
        expect((await proxy.getUrlById('forum', tagId('support'))).url, 'https://forum.test/t/support');
        expect((await proxy.getUrlById('user', '1')).result, isFalse);
      });

      test('marks everything read through the reader\'s markedAllAsReadAt', () async {
        await proxy.markAllAsRead('ignored');
        final patch = fixtures.requests.last;
        expect(patch.method, 'PATCH');
        expect(patch.path, '/users/${fixtures.userId('alice')}');
        expect(((patch.data as Map)['data'] as Map)['attributes'], {'markedAllAsReadAt': true});
      });

      test('reports what Flarum doesn\'t have instead of inventing it', () async {
        expect((await proxy.getBoardStatAsync()).result, isFalse);
        expect((await proxy.loginForum(tagId('support'), 'secret')).result, isFalse);
        final followed = await proxy.getParticipatedForumAsync();
        expect(followed.result, isTrue);
        expect(followed.forums, isEmpty, reason: 'alice follows no tag');
      });

      test('a failure is a failed result, not an exception', () async {
        final result = await proxy.getUrlById('post', '999999');
        expect(result.result, isFalse);
        expect(result.resultText, isNotEmpty);
      });
    });
  }
}
