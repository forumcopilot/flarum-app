import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import 'site.dart';

void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumPostProxy proxy;

      setUp(() {
        FlarumForum.resetForTesting();
        fixtures = FixtureForum(version);
        fixtures.forum();
        proxy = FlarumPostProxy(testSite());
      });

      String welcomePost(int index) => ((fixtures.seed['posts'] as Map)['welcome'] as List)[index] as String;

      test('a page of a thread, with its discussion as the header', () async {
        final thread = await proxy.getThreadAsync(fixtures.discussionId('welcome'), 0, 19, true);
        expect(thread.result, isTrue);
        expect(thread.title, 'Welcome to the test forum');
        expect(thread.forumName, 'General');
        expect(thread.totalPostNum, 4);
        expect(thread.posts.map((p) => p.postNumber), [1, 2, 3, 4]);
        expect(thread.posts.map((p) => p.authorName), ['admin', 'alice', 'bob', 'carol']);

        final reply = thread.posts[1];
        expect(reply.topicId, thread.id);
        expect(reply.content, contains('UserMention'));
        expect(reply.likeCount, 2);
        expect(reply.replyCount, 3, reason: 'bob\'s reply and two formatting samples mention it');
        expect(reply.actionCode, isNull);
      });

      test('opening at the first unread post', () async {
        final thread = await proxy.getThreadByUnreadAsync(fixtures.discussionId('long'), 20, true);
        expect(thread.result, isTrue);
        // alice has read to post 20.
        expect(thread.position, 21);
        expect(thread.posts.map((p) => p.postNumber), contains(21));
        expect(thread.totalPostNum, 60);
      });

      test('opening at a linked post', () async {
        final thread = await proxy.getThreadByPostAsync(welcomePost(1), 20, true);
        expect(thread.result, isTrue);
        expect(thread.position, 2);
        expect(thread.id, fixtures.discussionId('welcome'));
        expect(thread.posts.map((p) => p.postNumber), contains(2));
      });

      test('a post the reader may not edit has no source to give', () async {
        final raw = await proxy.getRawPostAsync(welcomePost(1));
        expect(raw.result, isFalse);
      });

      test('a quote mentions the post and quotes its text', () async {
        final quote = await proxy.getQuotePostAsync(welcomePost(1));
        expect(quote.result, isTrue);
        expect(quote.quoteContent, startsWith('> @"alice"#p${welcomePost(1)} Hi all!'));
        expect(quote.quoteContent, isNot(contains('<')));
      });

      test('writes say they aren\'t available yet, and Flarum has no post votes', () async {
        expect((await proxy.replyPostAsync('', '1', '', 'Hi', null, null, true)).result, isFalse);
        expect((await proxy.castPostVoteAsync('1', 'up')).resultText, 'Flarum has no post votes');
        expect(await proxy.votePollAsync('1', ['1']), isNull);
      });
    });
  }

  group('plainText', () {
    test('drops tags and scripts, keeps paragraph breaks, decodes entities', () {
      expect(
        plainText('<p>One &amp; two</p><p>Three<br>four</p><pre><code>x</code><script>alert(1)</script></pre>'),
        'One & two\nThree\nfour\nx',
      );
    });
  });
}
