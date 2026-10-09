import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/models/results/fc_social_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import 'package:flarum_core/testing.dart';
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

      test('alerts say who did what where, and open at the post it is about', () async {
        fixtures.forum();
        final result = await FlarumSocialProxy(testSite()).getAlertAsync(1, 20, false);

        expect(result.result, isTrue);
        expect(result.items, hasLength(4));
        expect(result.total, 4, reason: 'no further page');
        expect(fixtures.requests.single.queryParameters['include'], contains('subject.discussion'));

        final welcome = fixtures.discussionId('welcome');
        final liked = result.items.singleWhere((a) => a.username == 'carol' && a.action == 'reaction');
        expect(liked.message, endsWith('liked your post in Welcome to the test forum'));
        expect(liked.contentType, 'topic');
        expect(liked.contentId, welcome);
        expect(liked.topicId, welcome);
        expect(liked.position, 2);
        expect(liked.postId, isNotNull);
        expect(liked.actionUrl, '${FixtureForum.baseUrl}/d/$welcome-welcome-to-the-test-forum/2');
        expect(liked.isRead, isFalse);
        expect(liked.alertId, isNotNull);
        expect(liked.iconUrl, isA<String>());
        expect(int.parse(liked.timestamp), greaterThan(0), reason: 'milliseconds since the epoch');

        final mention = result.items.singleWhere((a) => a.username == 'bob' && a.action == 'mention');
        expect(mention.message, endsWith('replied to your post in Welcome to the test forum'));
        expect(mention.position, 3, reason: 'a mention opens at the reply, not the mentioned post');
        expect(mention.postId, isNull);

        final private = fixtures.discussionId('private');
        final reply = result.items.singleWhere((a) => a.action == 'insert');
        expect(reply.message, endsWith('replied to the private discussion Private: test plan'));
        expect(reply.contentId, private);
        expect(reply.position, 3);
        expect(reply.actionUrl, '${FixtureForum.baseUrl}/d/$private-private-test-plan/3');
      });

      test('a guest has no alerts, and nothing is asked', () async {
        fixtures.forum(signedIn: false);
        final result = await FlarumSocialProxy(testSite()).getAlertAsync(1, 20, false);
        expect(result.result, isFalse);
        expect(result.resultText, contains('Sign in'));
        expect(fixtures.requests, isEmpty);
      });

      test('activity is the reader\'s own posts, newest first', () async {
        final bob = await fixtures.api().user(fixtures.userId('bob'));
        fixtures.forum();
        final site = testSite()..setLoginData(FCLoginResult(result: true, resultText: '', user: FlarumUserProxy.toUser(bob)));

        final result = await FlarumSocialProxy(site).getActivityAsync(1, 20);

        expect(result.result, isTrue);
        expect(result.items, hasLength(20));
        expect(result.total, 21, reason: 'another page exists');
        final first = result.items.first;
        expect(first.username, 'bob');
        expect(first.message, matches(RegExp(r'^You (replied to|started) .+')));
        expect(first.contentType, 'topic');
        expect(first.contentId, isNotEmpty);
        expect(first.topicId, first.contentId);
      });
    });
  }

  test('marking all alerts read is one call', () async {
    final adapter = ScriptedAdapter([(204, null)]);
    FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio()).api.client.token = 'fixture-token';
    final result = await FlarumSocialProxy(testSite()).markAllAlertsReadAsync();
    expect(result.result, isTrue);
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, endsWith('/notifications/read'));
  });

  test('a failure is a failed result, not an exception', () async {
    final adapter = ScriptedAdapter([(500, errors('500', 'internal_server_error'))]);
    FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio()).api.client.token = 'fixture-token';
    final result = await FlarumSocialProxy(testSite()).getAlertAsync(1, 20, false);
    expect(result.result, isFalse);
    expect(result.resultText, isNotEmpty);
  });

  group('alert types the test forums don\'t send', () {
    FCAlert alert(String type, {Object? content, String? discussionId, ResourceId? subject, FlarumUser? from}) =>
        FlarumSocialProxy.toAlert(
          FlarumNotification(
            id: '1',
            contentType: type,
            content: content,
            subject: subject,
            discussionId: discussionId,
            discussionTitle: discussionId == null ? null : 'Release notes',
            postNumber: content is Map ? content['postNumber'] as int? : null,
            fromUser: from,
          ),
          baseUrl: FixtureForum.baseUrl,
        );

    test('a rename opens at its event post', () {
      final renamed = alert('discussionRenamed',
          content: {'postNumber': 7},
          discussionId: '12',
          from: const FlarumUser(id: '3', username: 'bob', displayName: 'Bob'));
      expect(renamed.message, 'Bob renamed a discussion to Release notes');
      expect(renamed.position, 7);
      expect(renamed.actionUrl, '${FixtureForum.baseUrl}/d/12/7', reason: 'no slug: the id alone is a valid link');
    });

    test('a suspension opens the reader\'s profile', () {
      final suspended = alert('userSuspended', subject: (type: 'users', id: '2'));
      expect(suspended.contentType, 'user');
      expect(suspended.contentId, '2');
      expect(suspended.topicId, isNull);
      expect(suspended.actionUrl, isNull);
    });

    test('a 2.0 message is a conversation', () {
      expect(alert('messageReceived', subject: (type: 'dialog-messages', id: '4')).contentType, 'conversation_message');
    });

    test('an unknown type with no discussion is a plain notice from someone', () {
      final unknown = alert('someExtensionThing');
      expect(unknown.contentType, 'notice');
      expect(unknown.message, 'New notification');
      expect(unknown.username, '');
      expect(alert('postLiked', discussionId: '12').message, 'Someone liked your post in Release notes');
    });
  });

  test('what Flarum doesn\'t have, or the app doesn\'t do yet, is a failed result', () async {
    final proxy = FlarumSocialProxy(testSite());
    expect((await proxy.likePostAsync('1')).result, isFalse);
    expect((await proxy.unlikePostAsync('1')).result, isFalse);
    expect((await proxy.thankPostAsync('1')).resultText, contains('no thanks'));
    expect((await proxy.followAsync('1')).result, isFalse);
    expect((await proxy.unfollowAsync('1')).result, isFalse);
  });
}
