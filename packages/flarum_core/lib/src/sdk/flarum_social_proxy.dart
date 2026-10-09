import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_social_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_social_result.dart';

import '../models/notification.dart';
import '../models/post.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;

/// Notifications (the SDK's alerts) and the reader's own activity.
///
/// Likes arrive with the write path in Phase 3. Flarum has no thanks; following
/// people needs an extension (ianm/follow-users) the app doesn't support yet.
class FlarumSocialProxy implements IFCSocialProxy {
  FlarumSocialProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// A page of the reader's notifications, newest first; [page] counts from 1.
  ///
  /// Listing resets the "new" badge the website shows the reader, as opening
  /// the website's notification menu does. [forceRefresh] has no effect: there
  /// is no cache.
  @override
  Future<FCAlertResult> getAlertAsync(int page, int perpage, bool forceRefresh) async {
    if (!_forum.isSignedIn) return FCAlertResult(result: false, resultText: _signIn, total: 0, items: const []);
    try {
      final offset = (page < 1 ? 0 : page - 1) * perpage;
      final notifications = await _forum.api.notifications(offset: offset, limit: perpage);
      return FCAlertResult(
        result: true,
        resultText: '',
        total: offset + notifications.items.length + (notifications.hasMore ? 1 : 0),
        items: [for (final n in notifications.items) toAlert(n, baseUrl: _forum.baseUrl)],
      );
    } catch (e) {
      return FCAlertResult(result: false, resultText: describeFlarumError(e), total: 0, items: const []);
    }
  }

  @override
  Future<FCMarkAlertsReadResult> markAllAlertsReadAsync() async {
    if (!_forum.isSignedIn) return FCMarkAlertsReadResult(result: false, resultText: _signIn);
    try {
      await _forum.api.markAllNotificationsRead();
      return FCMarkAlertsReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkAlertsReadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// The reader's own posts, newest first; [page] counts from 1. Flarum keeps
  /// no other activity feed.
  @override
  Future<FCActivityResult> getActivityAsync(int page, int perpage) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCActivityResult(result: false, resultText: _signIn, total: 0, items: const []);
    }
    try {
      final offset = (page < 1 ? 0 : page - 1) * perpage;
      final posts = await _forum.api.userPosts(username, offset: offset, limit: perpage);
      return FCActivityResult(
        result: true,
        resultText: '',
        total: offset + posts.items.length + (posts.hasMore ? 1 : 0),
        items: [for (final post in posts.items) toActivity(post)],
      );
    } catch (e) {
      return FCActivityResult(result: false, resultText: describeFlarumError(e), total: 0, items: const []);
    }
  }

  // ---- Likes arrive with the write path in Phase 3; follows with extension support. ----

  static const _later = 'Not available yet';
  static const _signIn = 'Sign in to see your notifications';

  @override
  Future<FCLikePostResult> likePostAsync(String postId, {int reactionId = 1}) async =>
      FCLikePostResult(result: false, resultText: _later);

  @override
  Future<FCUnlikePostResult> unlikePostAsync(String postId) async => FCUnlikePostResult(result: false, resultText: _later);

  @override
  Future<FCLikePostResult> likeConversationMessageAsync(String messageId, {int reactionId = 1}) async =>
      FCLikePostResult(result: false, resultText: _later);

  @override
  Future<FCUnlikePostResult> unlikeConversationMessageAsync(String messageId) async =>
      FCUnlikePostResult(result: false, resultText: _later);

  @override
  Future<FCThankPostResult> thankPostAsync(String postId) async =>
      FCThankPostResult(result: false, resultText: 'Flarum has no thanks; like the post instead');

  @override
  Future<FCFollowResult> followAsync(String userId) async =>
      FCFollowResult(result: false, resultText: _later);

  @override
  Future<FCUnfollowResult> unfollowAsync(String userId) async =>
      FCUnfollowResult(result: false, resultText: _later);

  // ---- Mapping ----

  /// [n] as the SDK's alert. Those about a discussion open it at the post
  /// they're about; a suspension opens the reader's profile.
  static FCAlert toAlert(FlarumNotification n, {required String baseUrl}) {
    final who = n.fromUser?.displayName ?? 'Someone';
    final title = n.discussionTitle ?? 'a discussion';
    final number = n.openAt;
    final discussionId = n.discussionId;
    final (contentType, contentId) = switch (n.contentType) {
      'messageReceived' => ('conversation_message', ''),
      'userSuspended' || 'userUnsuspended' => ('user', n.subject?.id ?? ''),
      _ when discussionId != null => ('topic', discussionId),
      _ => ('notice', ''),
    };
    return FCAlert(
      alertId: int.tryParse(n.id),
      userId: n.fromUser?.id ?? '',
      username: n.fromUser?.username ?? '',
      fromUsername: n.fromUser?.username,
      iconUrl: n.fromUser?.avatarUrl ?? '',
      message: _message(n.contentType, who: who, title: title),
      timestamp: '${(n.createdAt ?? DateTime.now()).millisecondsSinceEpoch}',
      contentType: contentType,
      contentId: contentId,
      topicId: contentType == 'topic' ? discussionId : null,
      position: contentType == 'topic' ? number : null,
      // The post itself only when the alert opens at it; a mention's subject
      // is the reader's post, but it opens at the reply.
      postId: n.contentType == 'postMentioned' ? null : n.postId,
      actionUrl: contentType == 'topic'
          ? '$baseUrl/d/${n.discussionSlug ?? discussionId}${number == null ? '' : '/$number'}'
          : null,
      action: _action(n.contentType),
      isRead: n.isRead,
    );
  }

  /// The website's wording for each type, in English. Types from extensions
  /// the app doesn't know fall back to a neutral line.
  static String _message(String type, {required String who, required String title}) => switch (type) {
        'newPost' || 'newPostInTag' => '$who replied to $title',
        'postLiked' => '$who liked your post in $title',
        'postReacted' => '$who reacted to your post in $title',
        'postMentioned' => '$who replied to your post in $title',
        'userMentioned' => '$who mentioned you in $title',
        'groupMentioned' => '$who mentioned a group you\'re in, in $title',
        'discussionRenamed' => '$who renamed a discussion to $title',
        'discussionLocked' => '$who locked $title',
        'newDiscussionInTag' => '$who started $title',
        'newDiscussionTag' => '$who moved $title to a tag you follow',
        'byobuPrivateDiscussionCreated' => '$who started a private discussion with you: $title',
        'byobuPrivateDiscussionReplied' => '$who replied to the private discussion $title',
        'byobuPrivateDiscussionAdded' => '$who added you to the private discussion $title',
        'byobuRecipientRemoved' => '$who removed you from the private discussion $title',
        'byobuMadePublic' => '$who made $title public',
        'awardedBestAnswer' => '$who chose your post as the best answer in $title',
        'bestAnswerInDiscussion' => '$who chose a best answer in $title',
        'selectBestAnswer' => 'Choose a best answer in $title',
        'messageReceived' => '$who sent you a message',
        'userSuspended' => 'You have been suspended',
        'userUnsuspended' => 'Your suspension has been lifted',
        'gdprExportAvailable' => 'Your data export is ready',
        _ => 'New notification',
      };

  /// The SDK's action verb, for the types it has one for.
  static String? _action(String type) => switch (type) {
        'newPost' || 'newPostInTag' || 'byobuPrivateDiscussionReplied' => 'insert',
        'postMentioned' || 'userMentioned' || 'groupMentioned' => 'mention',
        'postLiked' || 'postReacted' => 'reaction',
        _ => null,
      };

  /// One of the reader's posts as the SDK's activity.
  static FCActivity toActivity(FlarumPost post) {
    final title = post.discussionTitle ?? 'a discussion';
    return FCActivity(
      userId: post.author?.id ?? '',
      username: post.author?.username ?? '',
      iconUrl: post.author?.avatarUrl ?? '',
      message: post.number == 1 ? 'You started $title' : 'You replied to $title',
      timestamp: '${(post.createdAt ?? DateTime.now()).millisecondsSinceEpoch}',
      contentType: 'topic',
      contentId: post.discussionId ?? '',
      topicId: post.discussionId,
    );
  }
}
