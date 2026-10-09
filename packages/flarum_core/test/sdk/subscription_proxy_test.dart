import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';

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

      test('followed discussions, as subscribed topics', () async {
        fixtures.forum();
        final result = await FlarumSubscriptionProxy(testSite()).getSubscribedTopicAsync(0, 19);

        expect(result.result, isTrue, reason: result.resultText);
        final topic = result.topics.single;
        expect(topic.topicId, fixtures.discussionId('feedback'));
        expect(topic.topicTitle, 'Feature request: dark mode');
        expect(topic.postAuthorName, 'bob');
        expect(topic.forumId, fixtures.tagId('feedback'));
        expect(topic.replyNumber, 1);
        expect(topic.isSubscribed, isTrue);
        expect(result.totalTopicNum, 1);
      });

      test('followed tags, as subscribed forums', () async {
        fixtures.forum();
        final result = await FlarumSubscriptionProxy(testSite()).getSubscribedForumAsync();
        expect(result.result, isTrue, reason: result.resultText);
        expect(result.forums.map((f) => f.forumName), unorderedEquals(['Support', 'Feedback']));
        expect(result.totalForumsNum, 2);
      });

      test('a discussion\'s level: followed is watching, others normal', () async {
        fixtures.forum();
        final proxy = FlarumSubscriptionProxy(testSite());
        expect((await proxy.getTopicNotificationLevelAsync(fixtures.discussionId('feedback'))).level, FCNotificationLevel.watching);
        expect((await proxy.getTopicNotificationLevelAsync(fixtures.discussionId('welcome'))).level, FCNotificationLevel.normal);
      });

      test('a tag\'s level: lurking is watching, following is first posts only', () async {
        fixtures.forum();
        final proxy = FlarumSubscriptionProxy(testSite());
        expect((await proxy.getCategoryNotificationLevelAsync(fixtures.tagId('support'))).level, FCNotificationLevel.watching);
        expect((await proxy.getCategoryNotificationLevelAsync(fixtures.tagId('feedback'))).level, FCNotificationLevel.watchingFirstPost);
        expect((await proxy.getCategoryNotificationLevelAsync(fixtures.tagId('general'))).level, FCNotificationLevel.normal);
        expect((await proxy.getCategoryNotificationLevelAsync('999')).result, isFalse);
      });

      test('a guest follows nothing, and nothing is asked', () async {
        fixtures.forum(signedIn: false);
        final proxy = FlarumSubscriptionProxy(testSite());
        expect((await proxy.getSubscribedTopicAsync(0, 19)).result, isFalse);
        expect((await proxy.getSubscribedForumAsync()).resultText, contains('Sign in'));
        expect((await proxy.getTopicNotificationLevelAsync(fixtures.discussionId('feedback'))).result, isFalse);
        expect(fixtures.requests, isEmpty);
      });
    });
  }

  test('an ignored discussion is muted', () async {
    final adapter = ScriptedAdapter([
      (200, {'data': {'type': 'discussions', 'id': '3', 'attributes': {'title': 'x', 'subscription': 'ignore'}}}),
    ]);
    FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio()).api.client.token = 'fixture-token';
    final result = await FlarumSubscriptionProxy(testSite()).getTopicNotificationLevelAsync('3');
    expect(result.level, FCNotificationLevel.muted);
  });

  test('ignored and hidden tags are muted', () {
    FlarumTag tag(String? subscription) => FlarumTag(id: '1', name: 'x', slug: 'x', isPrimary: true, subscription: subscription);
    expect(FlarumSubscriptionProxy.tagLevel(tag('ignore')), FCNotificationLevel.muted);
    expect(FlarumSubscriptionProxy.tagLevel(tag('hide')), FCNotificationLevel.muted);
  });

  test('changing what the reader follows waits for the write path', () async {
    final proxy = FlarumSubscriptionProxy(testSite());
    expect((await proxy.subscribeTopicAsync('1', 1)).result, isFalse);
    expect((await proxy.unsubscribeTopicAsync('1')).result, isFalse);
    expect((await proxy.subscribeForumAsync('1', 1)).result, isFalse);
    expect((await proxy.unsubscribeForumAsync('1')).result, isFalse);
    expect((await proxy.setTopicNotificationLevelAsync('1', FCNotificationLevel.watching)).result, isFalse);
    expect((await proxy.setCategoryNotificationLevelAsync('1', FCNotificationLevel.watching)).result, isFalse);
  });
}
