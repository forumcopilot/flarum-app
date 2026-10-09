import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_subscription_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_notification_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_subscription_result.dart';

import '../models/tag.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_topic_proxy.dart';

/// What the reader follows: discussions (flarum/subscriptions) and tags
/// (fof/follow-tags), and how closely.
///
/// Flarum's levels map onto the SDK's: a followed discussion is watching and
/// an ignored one muted; a tag the reader lurks in is watching (every reply),
/// a followed tag watching-first-post (new discussions), and an ignored or
/// hidden tag muted. Changing them arrives with the write path in Phase 3.
class FlarumSubscriptionProxy implements IFCSubscriptionProxy {
  FlarumSubscriptionProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// The tags the reader follows or lurks in.
  @override
  Future<FCSubscribedForumResult> getSubscribedForumAsync() async {
    if (!_forum.isSignedIn) return FCSubscribedForumResult(result: false, resultText: _signIn);
    try {
      final followed = [
        for (final tag in await _forum.tags())
          if (tag.subscription == 'follow' || tag.subscription == 'lurk') tag,
      ];
      return FCSubscribedForumResult(
        result: true,
        resultText: '',
        totalForumsNum: followed.length,
        forums: [
          for (final tag in followed)
            FCSubscribedForum(
              forumId: tag.id,
              forumName: tag.name,
              canPost: tag.canStartDiscussion,
              // Both notify; Flarum has no email-only or digest modes.
              subscribeMode: 1,
            ),
        ],
      );
    } catch (e) {
      return FCSubscribedForumResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// The discussions the reader follows, latest activity first.
  @override
  Future<FCSubscribedTopicResult> getSubscribedTopicAsync(int startNum, int lastNum) async {
    if (!_forum.isSignedIn) return FCSubscribedTopicResult(result: false, resultText: _signIn);
    try {
      final offset = startNum < 0 ? 0 : startNum;
      final limit = lastNum >= offset ? lastNum - offset + 1 : 20;
      final page = await _forum.api.discussions(following: true, offset: offset, limit: limit);
      final topics = await FlarumTopicProxy(siteContext).topics(page.items);
      return FCSubscribedTopicResult(
        result: true,
        resultText: '',
        totalTopicNum: page.total ?? offset + topics.length + (page.hasMore ? 1 : 0),
        topics: [for (final topic in topics) _subscribed(topic)],
      );
    } catch (e) {
      return FCSubscribedTopicResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCNotificationLevelResult> getTopicNotificationLevelAsync(String topicId) async {
    if (!_forum.isSignedIn) return FCNotificationLevelResult(result: false, resultText: _signIn);
    try {
      final discussion = await _forum.api.discussion(topicId);
      return FCNotificationLevelResult(result: true, resultText: '', level: discussionLevel(discussion.subscription));
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// [categoryId] is a tag id.
  @override
  Future<FCNotificationLevelResult> getCategoryNotificationLevelAsync(String categoryId) async {
    if (!_forum.isSignedIn) return FCNotificationLevelResult(result: false, resultText: _signIn);
    try {
      final tag = (await _forum.tags()).where((t) => t.id == categoryId).firstOrNull;
      if (tag == null) return FCNotificationLevelResult(result: false, resultText: 'This forum has no tag $categoryId');
      return FCNotificationLevelResult(result: true, resultText: '', level: tagLevel(tag));
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// A discussion's `subscription` as the SDK's level.
  static FCNotificationLevel discussionLevel(String? subscription) => switch (subscription) {
        'follow' => FCNotificationLevel.watching,
        'ignore' => FCNotificationLevel.muted,
        _ => FCNotificationLevel.normal,
      };

  /// A tag's fof/follow-tags `subscription` as the SDK's level. The SDK has
  /// no "hide from the discussion list"; hidden reads as muted.
  static FCNotificationLevel tagLevel(FlarumTag tag) => switch (tag.subscription) {
        'lurk' => FCNotificationLevel.watching,
        'follow' => FCNotificationLevel.watchingFirstPost,
        'ignore' || 'hide' => FCNotificationLevel.muted,
        _ => FCNotificationLevel.normal,
      };

  static FCSubscribedTopic _subscribed(FCTopic t) => FCSubscribedTopic(
        forumId: t.forumId,
        forumName: t.forumName,
        topicId: t.id,
        topicTitle: t.title,
        postAuthorName: t.authorName,
        postAuthorId: t.authorId,
        iconUrl: t.authorIconUrl,
        postTime: t.lastPostedAt ?? t.timestamp,
        replyNumber: t.replyCount,
        newPost: t.hasNewPosts,
        subscribeMode: 1,
        isClosed: t.isClosed,
        isLocked: t.isClosed,
        isSticky: t.isPinned,
        isPinned: t.isPinned,
        isPoll: t.hasPoll,
        isSolved: t.isSolved,
        isApproved: t.isApproved,
        isDeleted: t.isDeleted,
        isHidden: t.isDeleted,
        isSubscribed: true,
      );

  // ---- Following and unfollowing arrive with the write path in Phase 3. ----

  static const _later = 'Not available yet';
  static const _signIn = 'Sign in to see what you follow';

  @override
  Future<FCSubscribeForumResult> subscribeForumAsync(String forumId, int subscribeMode) async =>
      FCSubscribeForumResult(result: false, resultText: _later);

  @override
  Future<FCUnsubscribeForumResult> unsubscribeForumAsync(String forumId) async =>
      FCUnsubscribeForumResult(result: false, resultText: _later);

  @override
  Future<FCSubscribeTopicResult> subscribeTopicAsync(String topicId, int subscribeMode) async =>
      FCSubscribeTopicResult(result: false, resultText: _later);

  @override
  Future<FCUnsubscribeTopicResult> unsubscribeTopicAsync(String topicId) async =>
      FCUnsubscribeTopicResult(result: false, resultText: _later);

  @override
  Future<FCNotificationLevelResult> setTopicNotificationLevelAsync(String topicId, FCNotificationLevel level) async =>
      FCNotificationLevelResult(result: false, resultText: _later);

  @override
  Future<FCNotificationLevelResult> setCategoryNotificationLevelAsync(String categoryId, FCNotificationLevel level) async =>
      FCNotificationLevelResult(result: false, resultText: _later);
}
