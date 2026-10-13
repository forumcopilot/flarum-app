import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_moderation_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_moderation_result.dart';

import '../models/user.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;

/// [IFCModerationProxy] on Flarum's own moderation: flarum/lock and flarum/sticky, hiding (Flarum's
/// Delete) and deleting for good, renaming, flarum/approval and flarum/suspend. Each refuses with
/// the forum's 403 for a reader without the permission. Flarum has no separate moderator sign-in,
/// and moving posts or merging discussions needs extensions the app doesn't speak to yet.
class FlarumModerationProxy implements IFCModerationProxy {
  FlarumModerationProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  static const _later = 'Not available yet';

  /// Where an [IFCModerationProxy] call needs no more than [change], or says why not.
  Future<(bool, String)> _do(Future<void> Function() change) async {
    try {
      await change();
      return (true, '');
    } catch (e) {
      return (false, describeFlarumError(e));
    }
  }

  /// A moderator is a member with the permissions: there's nothing more to sign in to.
  @override
  Future<FCLoginModResult> doLoginModAsync(String username, String password) async =>
      FCLoginModResult(result: true, resultText: '');

  @override
  Future<FCStickTopicResult> stickTopicAsync(String topicId) async {
    final (ok, text) = await _do(() => _forum.api.setSticky(topicId, true));
    return FCStickTopicResult(result: ok, resultText: text);
  }

  @override
  Future<FCStickTopicResult> unstickTopicAsync(String topicId) async {
    final (ok, text) = await _do(() => _forum.api.setSticky(topicId, false));
    return FCStickTopicResult(result: ok, resultText: text);
  }

  /// Closing a topic is locking the discussion (flarum/lock).
  @override
  Future<FCCloseTopicResult> closeTopicAsync(String topicId) async {
    final (ok, text) = await _do(() => _forum.api.setLocked(topicId, true));
    return FCCloseTopicResult(result: ok, resultText: text);
  }

  @override
  Future<FCCloseTopicResult> uncloseTopicAsync(String topicId) async {
    final (ok, text) = await _do(() => _forum.api.setLocked(topicId, false));
    return FCCloseTopicResult(result: ok, resultText: text);
  }

  /// [mode] 1 hides the discussion (Flarum's Delete, which a moderator can undo), 2 deletes it for
  /// good.
  @override
  Future<FCDeleteTopicResult> deleteTopicAsync(String topicId, int mode, String reason) async {
    final (ok, text) = await _do(
        () => mode == 2 ? _forum.api.deleteDiscussion(topicId) : _forum.api.setDiscussionHidden(topicId, true));
    return FCDeleteTopicResult(result: ok, resultText: text);
  }

  /// [mode] 1 hides the post (Flarum's Delete), 2 deletes it for good.
  @override
  Future<FCDeletePostResult> deletePostAsync(String postId, int mode, String reason) async {
    final (ok, text) =
        await _do(() => mode == 2 ? _forum.api.deletePost(postId) : _forum.api.setPostHidden(postId, true));
    return FCDeletePostResult(result: ok, resultText: text);
  }

  @override
  Future<FCUndeleteTopicResult> undeleteTopicAsync(String topicId, String reason) async {
    final (ok, text) = await _do(() => _forum.api.setDiscussionHidden(topicId, false));
    return FCUndeleteTopicResult(result: ok, resultText: text);
  }

  @override
  Future<FCUndeletePostResult> undeletePostAsync(String postId, String reason) async {
    final (ok, text) = await _do(() => _forum.api.setPostHidden(postId, false));
    return FCUndeletePostResult(result: ok, resultText: text);
  }

  /// A discussion is "moved" by its tags, which comes with tag editing.
  @override
  Future<FCMoveTopicResult> moveTopicAsync(String topicId, String forumId, bool redirect) async =>
      FCMoveTopicResult(result: false, resultText: _later);

  @override
  Future<FCRenameTopicResult> renameTopicAsync(String topicId, String title) async {
    final (ok, text) = await _do(() => _forum.api.renameDiscussion(topicId, title));
    return FCRenameTopicResult(result: ok, resultText: text);
  }

  /// Moving posts needs fof/split.
  @override
  Future<FCMovePostResult> movePostAsync(String postId, String? topicId, String? topicTitle, String? forumId) async =>
      FCMovePostResult(result: false, resultText: _later);

  /// Merging needs fof/merge-discussions.
  @override
  Future<FCMergeTopicResult> mergeTopicAsync(String topicId1, String topicId2, bool redirect) async =>
      FCMergeTopicResult(result: false, resultText: _later);

  @override
  Future<FCModerateTopicResult> getModerateTopicAsync(int startNum, int lastNum) async =>
      FCModerateTopicResult(result: false, resultText: _later, total: 0, list: const []);

  @override
  Future<FCModeratePostResult> getModeratePostAsync(int startNum, int lastNum) async =>
      FCModeratePostResult(result: false, resultText: _later, total: 0, list: const []);

  @override
  Future<FCDeletedTopicResult> getDeletedTopicAsync(int startNum, int lastNum) async =>
      FCDeletedTopicResult(result: false, resultText: _later, total: 0, list: const []);

  @override
  Future<FCDeletedPostResult> getDeletedPostAsync(int startNum, int lastNum) async =>
      FCDeletedPostResult(result: false, resultText: _later, total: 0, list: const []);

  @override
  Future<FCReportedPostResult> getReportedPostAsync(int startNum, int lastNum) async =>
      FCReportedPostResult(result: false, resultText: _later, total: 0, list: const []);

  /// Approves the discussion's first post, which approves the discussion (flarum/approval).
  @override
  Future<FCApproveTopicResult> approveTopicAsync(String topicId) async {
    final (ok, text) = await _do(() async {
      final first = (await _forum.api.posts(topicId, limit: 1)).items.first;
      await _forum.api.approvePost(first.id);
    });
    return FCApproveTopicResult(result: ok, resultText: text);
  }

  @override
  Future<FCApprovePostResult> approvePostAsync(String postId) async {
    final (ok, text) = await _do(() => _forum.api.approvePost(postId));
    return FCApprovePostResult(result: ok, resultText: text);
  }

  /// Suspends [userName] (flarum/suspend) until [banExpires] (Unix seconds), or indefinitely for 0,
  /// as the web does; [reason] is what they're told. Their posts stay.
  @override
  Future<FCBanUserResult> banUserAsync(
      String userName, String reason, int banExpires, int deletePostMode, int deletePostValue) async {
    final (ok, text) = await _do(() async {
      final user = await _forum.api.userBySlug(userName);
      final until = banExpires == 0
          ? FlarumUser.indefiniteSuspension
          : DateTime.fromMillisecondsSinceEpoch(banExpires * 1000, isUtc: true);
      await _forum.api.suspend(user.id, until, reason: reason, message: reason);
    });
    return FCBanUserResult(result: ok, resultText: text);
  }

  @override
  Future<FCUnbanUserResult> unbanUserAsync(String userId) async {
    final (ok, text) = await _do(() => _forum.api.suspend(userId, null));
    return FCUnbanUserResult(result: ok, resultText: text);
  }

  @override
  Future<FCMarkAsSpamResult> markAsSpamAsync(String userId) async =>
      FCMarkAsSpamResult(result: false, resultText: 'Flarum has no spam marking in core');

  @override
  Future<FCSpamCleanUserResult> spamCleanUserAsync({
    String? userId,
    String? username,
    bool actionThreads = false,
    bool deleteMessages = false,
    bool deleteConversations = false,
    bool banUser = false,
  }) async =>
      FCSpamCleanUserResult(result: false, resultText: 'Flarum has no spam cleaning in core');

  @override
  Future<FCDeleteTopicResult> archiveTopicAsync(String topicId, {required bool archived}) async =>
      FCDeleteTopicResult(result: false, resultText: 'Flarum has no archive');

  @override
  Future<FCDeleteTopicResult> setTopicVisibilityAsync(String topicId, {required bool visible}) async {
    final (ok, text) = await _do(() => _forum.api.setDiscussionHidden(topicId, !visible));
    return FCDeleteTopicResult(result: ok, resultText: text);
  }

  @override
  Future<FCDeleteTopicResult> deleteTopicExtendedAsync(String topicId,
      {bool hardDelete = false, String? reason, bool starterAlert = false, String? starterAlertReason}) async {
    final (ok, text) = await _do(
        () => hardDelete ? _forum.api.deleteDiscussion(topicId) : _forum.api.setDiscussionHidden(topicId, true));
    return FCDeleteTopicResult(result: ok, resultText: text);
  }
}
