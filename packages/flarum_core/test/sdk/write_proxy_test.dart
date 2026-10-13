import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site.dart';

/// The SDK's write methods, replayed from the write fixtures (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() {
        FlarumForum.resetForTesting();
        fixtures = FixtureForum(version);
        fixtures.forum();
      });

      test('newTopic starts a discussion in a primary tag', () async {
        final result = await FlarumTopicProxy(testSite()).newTopic(fixtures.tagId('general'), WriteSamples.title, WriteSamples.content);
        expect(result.result, isTrue, reason: result.resultText);
        expect(result.topicId, isNotEmpty);
        expect(result.state, 0, reason: 'not held for approval');
      });

      test('newTopic without a tag says why the forum refused', () async {
        final result = await FlarumTopicProxy(testSite()).newTopic('', WriteSamples.title, WriteSamples.noTagsContent);
        expect(result.result, isFalse);
        expect(result.resultText, contains('tags'));
      });

      test('replyPostAsync posts, and saveRawPostAsync edits it', () async {
        final proxy = FlarumPostProxy(testSite());
        final reply = await proxy.replyPostAsync('', '1', '', WriteSamples.reply, null, null, true);
        expect(reply.result, isTrue, reason: reply.resultText);
        expect(reply.postContent, '<p>${WriteSamples.reply}</p>');
        expect(reply.canEdit, isTrue);

        final saved = await proxy.saveRawPostAsync(reply.postId!, '', WriteSamples.edit, true, null, null, null, null);
        expect(saved.result, isTrue, reason: saved.resultText);
        expect(saved.postContent, '<p>${WriteSamples.edit}</p>');
      });

      test('replyPostAsync passes the throttle\'s refusal on', () async {
        final reply = await FlarumPostProxy(testSite()).replyPostAsync('', '1', '', WriteSamples.throttledReply, null, null, true);
        expect(reply.result, isFalse);
        expect(reply.resultText, 'too_many_requests');
      });
    });
  }
}
