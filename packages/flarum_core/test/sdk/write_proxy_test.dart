import 'dart:convert';
import 'dart:io';

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

      String answerId() =>
          ((jsonDecode(File('test/fixtures/${version.name}/write_like.json').readAsStringSync()) as Map)['request']['path'] as String)
              .split('/')
              .last;
      String pathId(String fixture, int index) =>
          ((jsonDecode(File('test/fixtures/${version.name}/$fixture.json').readAsStringSync()) as Map)['request']['path'] as String)
              .split('/')[index];

      test('likePostAsync and unlikePostAsync', () async {
        final social = FlarumSocialProxy(testSite());
        final liked = await social.likePostAsync(answerId());
        expect((liked.result, liked.isLiked, liked.likeCount), (true, true, 1));
        final unliked = await social.unlikePostAsync(answerId());
        expect((unliked.result, unliked.isLiked, unliked.likeCount), (true, false, 0));
      });

      test('toggleReactionAsync reacts by shortcode, and takes it back the second time', () async {
        final proxy = FlarumPostProxy(testSite());
        expect((await proxy.getAvailableReactionsAsync()).reactions, contains('heart'));
        final on = await proxy.toggleReactionAsync(answerId(), 'heart');
        expect(on.result, isTrue, reason: on.resultText);
        expect(on.reactions.map((r) => (r.id, r.count, r.viewerReacted)), [('heart', 1, true)]);
        final off = await proxy.toggleReactionAsync(answerId(), 'heart');
        expect(off.result, isTrue, reason: off.resultText);
        expect(off.reactions, isEmpty);
      });

      test('acceptAnswerAsync and unacceptAnswerAsync find the post\'s discussion', () async {
        final proxy = FlarumPostProxy(testSite());
        final accepted = await proxy.acceptAnswerAsync(answerId());
        expect(accepted.result, isTrue, reason: accepted.resultText);
        final cleared = await proxy.unacceptAnswerAsync(answerId());
        expect(cleared.result, isTrue, reason: cleared.resultText);
      });

      test('subscribing to a discussion follows it; to a forum, follows its tag', () async {
        final proxy = FlarumSubscriptionProxy(testSite());
        final question = pathId('write_follow', 2);
        expect((await proxy.subscribeTopicAsync(question, 0)).result, isTrue);
        expect((await proxy.unsubscribeTopicAsync(question)).result, isTrue);
        final cycling = pathId('write_tag_follow', 2);
        expect((await proxy.subscribeForumAsync(cycling, 0)).result, isTrue);
        expect((await proxy.unsubscribeForumAsync(cycling)).result, isTrue);
      });

      test('bookmarks a post, lists it, and takes it off', () async {
        final proxy = FlarumBookmarkProxy(testSite());
        final added = await proxy.addPostBookmarkAsync(answerId());
        expect((added.result, added.isBookmarked), (true, true));
        final list = await proxy.getBookmarksAsync();
        expect(list.items.map((b) => '${b.bookmarkableId}'), [answerId()]);
        expect(list.items.single.title, WriteSamples.questionTitle);
        final removed = await proxy.removePostBookmarkAsync(answerId());
        expect((removed.result, removed.isBookmarked), (true, false));
      });

      test('uploadAttachmentAsync uploads, and a reply given its id carries its BBCode', () async {
        final proxy = FlarumAttachmentProxy(testSite());
        final image = await proxy.uploadAttachmentAsync(
            'image', '', '', WriteSamples.uploadImageName, base64Decode(WriteSamples.uploadImageBase64));
        expect(image.result, isTrue, reason: image.resultText);
        expect((image.fileName, image.fileSize), (WriteSamples.uploadImageName, 69));
        expect(image.url, endsWith(WriteSamples.uploadImageName));

        final text = FlarumAttachmentProxy.withAttachments(WriteSamples.reply, [image.attachmentId!]);
        expect(text, startsWith('${WriteSamples.reply}\n\n[upl-image-preview uuid=${image.attachmentId} '));
        expect(FlarumAttachmentProxy.withAttachments(text, [image.attachmentId!]), text, reason: 'already in the text');
      });

      test('removeAttachmentAsync passes the forum\'s refusal on', () async {
        final proxy = FlarumAttachmentProxy(testSite());
        await proxy.uploadAttachmentAsync('image', '', '', WriteSamples.uploadImageName, base64Decode(WriteSamples.uploadImageBase64));
        final file =
            await proxy.uploadAttachmentAsync('file', '', '', WriteSamples.uploadFileName, utf8.encode(WriteSamples.uploadFileText));
        final removed = await proxy.removeAttachmentAsync(file.attachmentId!, '', '', '');
        expect(removed.result, isFalse);
        expect(removed.resultText, isNotEmpty);
      });

      test('replyPostAsync passes the throttle\'s refusal on', () async {
        final reply = await FlarumPostProxy(testSite()).replyPostAsync('', '1', '', WriteSamples.throttledReply, null, null, true);
        expect(reply.result, isFalse);
        expect(reply.resultText, 'too_many_requests');
      });
    });
  }
}
