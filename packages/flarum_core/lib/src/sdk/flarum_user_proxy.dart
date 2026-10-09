import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_user_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/results/fc_directory_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_passkey_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../flarum_exception.dart';
import '../models/forum_info.dart';
import '../models/user.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_topic_proxy.dart';

/// Signing in and out, and users.
///
/// The app signs in through the forum's own page in a web view and hands the
/// captured token to [completeSignIn]; [loginAsync] is the native password
/// form, which a CAPTCHA on the token route can refuse.
class FlarumUserProxy implements IFCUserProxy {
  FlarumUserProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// Finishes a web-view sign-in: checks [token] with the forum, keeps it, and
  /// marks [site] signed in. Throws if the forum doesn't accept the token.
  static Future<FCLoginResult> completeSignIn(SiteContext site, String token, {String cookiePrefix = 'flarum'}) async {
    final forum = FlarumForum.of(site);
    final info = await forum.signIn(token, cookiePrefix: cookiePrefix);
    final result = loginResult(info);
    site.setLoginData(result);
    return result;
  }

  /// [info]'s reader as the SDK's sign-in result.
  static FCLoginResult loginResult(FlarumForumInfo info) {
    final reader = info.actor!;
    return FCLoginResult(
      result: true,
      resultText: '',
      user: toUser(reader),
      canProfile: true,
      canUploadAvatar: true,
      canUploadAttachment: info.can('fof-upload.canUpload'),
      canWhosonline: false,
    );
  }

  @override
  Future<FCLoginResult> loginAsync(String loginname, String password, bool anonymous, String? trustCode,
      {bool remember = true,
      String? tfaCode,
      String? tfaProvider,
      String? webauthnChallenge,
      Map<String, String>? webauthnPayload,
      bool trustDevice = false}) async {
    try {
      final session = await _forum.api.logIn(loginname, password, remember: remember);
      final info = await _forum.signIn(session.token, cookiePrefix: _forum.api.client.cookiePrefix);
      final result = loginResult(info);
      siteContext.setLoginData(result);
      return result;
    } on FlarumApiException catch (e) {
      return FCLoginResult(result: false, resultText: _signInError(e));
    } catch (e) {
      return FCLoginResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// A CAPTCHA on the token route (2.0's Turnstile fork) answers 422 on its
  /// own field: the app should offer the web sign-in instead.
  static String _signInError(FlarumApiException e) {
    final captcha = e.errors.any((error) => RegExp('turnstile|captcha', caseSensitive: false).hasMatch(error.pointer ?? ''));
    if (captcha) return 'This forum asks for a CAPTCHA: sign in on its page instead';
    if (e.isUnauthorized) return 'Wrong username, email or password';
    return e.message;
  }

  /// Revokes the token on the forum, forgets it, and marks the site signed out.
  @override
  Future<void> logoutUserAsync() async {
    await _forum.signOut();
    siteContext.clearLoginData();
  }

  @override
  Future<String> getAvatarAsync(String userId, String username) async {
    try {
      return (await _user(userId: userId, username: username)).avatarUrl ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<FCUserInfoResult> getUserInfoAsync(String? username, String? userId) async {
    try {
      final user = await _user(userId: userId, username: username);
      return FCUserInfoResult(
        result: true,
        resultText: '',
        id: user.id,
        username: user.username,
        displayText: user.displayName,
        iconUrl: user.avatarUrl,
        postCount: user.commentCount ?? 0,
        registrationTime: user.joinTime,
        lastSeenAt: user.lastSeenAt,
        lastActivityTime: user.lastSeenAt,
      );
    } catch (e) {
      return FCUserInfoResult(result: false, resultText: describeFlarumError(e), id: userId ?? '', username: username ?? '');
    }
  }

  /// The discussions a user started.
  @override
  Future<FCUserTopicResult> getUserTopicAsync(String? username, String? userId) async {
    try {
      final name = username ?? (await _user(userId: userId)).username;
      final page = await _forum.api.discussions(author: name);
      final topics = [
        for (final d in page.items) FlarumTopicProxy.toTopic(d, baseUrl: _forum.baseUrl),
      ];
      return FCUserTopicResult(result: true, resultText: '', total: topics.length, list: [
        for (final t in topics)
          FCUserTopic(
            topicId: t.id,
            topicTitle: t.title,
            forumId: t.forumId,
            forumName: t.forumName,
            authorId: t.authorId,
            authorName: t.authorName,
            postTime: t.timestamp,
            replyCount: t.replyCount,
            isClosed: t.isClosed,
            isSticky: t.isPinned,
          ),
      ]);
    } catch (e) {
      return FCUserTopicResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// A user's comments, newest first.
  @override
  Future<FCUserReplyResult> getUserReplyPostAsync(int startNum, int lastNum, String? searchId, String? username, String? userId) async {
    try {
      final name = username ?? (await _user(userId: userId)).username;
      final offset = startNum < 0 ? 0 : startNum;
      final limit = lastNum >= offset ? lastNum - offset + 1 : 20;
      final page = await _forum.api.userPosts(name, offset: offset, limit: limit);
      return FCUserReplyResult(
        result: true,
        resultText: '',
        total: offset + page.items.length + (page.hasMore ? 1 : 0),
        list: [
          for (final post in page.items)
            FCUserReply(
              postId: post.id,
              topicId: post.discussionId ?? '',
              topicTitle: post.discussionTitle ?? '',
              forumId: '',
              forumName: '',
              authorId: post.author?.id ?? '',
              authorName: post.author?.username ?? name,
              authorIconUrl: post.author?.avatarUrl ?? '',
              postTime: post.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              replyNumber: post.number,
              postContent: post.contentHtml,
            ),
        ],
      );
    } catch (e) {
      return FCUserReplyResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Needs the forum's "search users" permission; [page] counts from 1.
  @override
  Future<FCSearchUserResult> searchUserAsync(String keywords, int page, int perpage) async {
    try {
      final offset = (page < 1 ? 0 : page - 1) * perpage;
      final users = await _forum.api.searchUsers(keywords, offset: offset, limit: perpage);
      return FCSearchUserResult(
        result: true,
        resultText: '',
        total: offset + users.items.length + (users.hasMore ? 1 : 0),
        hasMore: users.hasMore,
        list: [
          for (final user in users.items)
            FCSearchUser(
              id: user.id,
              username: user.username,
              displayText: user.displayName,
              iconUrl: user.avatarUrl,
              postCount: user.commentCount ?? 0,
            ),
        ],
      );
    } catch (e) {
      return FCSearchUserResult(result: false, resultText: describeFlarumError(e));
    }
  }

  // ---- Not on Flarum, or later phases ----

  @override
  Future<FCPasskeyChallengeResult> getPasskeyChallengeAsync() async =>
      FCPasskeyChallengeResult(result: false, resultText: 'Flarum has no passkey sign-in');

  @override
  Future<FCLoginResult> loginWithPasskeyAsync(
          {required String webauthnChallenge, required Map<String, String> webauthnPayload}) async =>
      FCLoginResult(result: false, resultText: 'Flarum has no passkey sign-in');

  @override
  Future<FCLoginTwoStepResult> loginTwoStepAsync(String codeTwoStep, bool trust) async =>
      FCLoginTwoStepResult(result: false, resultText: 'Two-step sign-in happens on the forum\'s page', id: '', username: '');

  /// Comes with private messages (Phase 3).
  @override
  Future<FCInboxStatResult> getInboxStatAsync(DateTime pmLastCheckedTime, DateTime subscribedTopicLastCheckedTime) async =>
      FCInboxStatResult(result: false, resultText: 'Not available yet', totalConversations: 0, unreadConversations: 0, unreadMessages: 0);

  /// Seeing who's online needs viewLastSeenAt, which members lack by default.
  @override
  Future<FCOnlineUserResult> getOnlineUsersAsync(int page, int perpage, String? id, String? area) async =>
      FCOnlineUserResult(result: false, resultText: 'Flarum shows who\'s online to staff only');

  @override
  Future<FCRecommendedUserResult> getRecommendedUsersAsync(int page, int perpage, int mode) async =>
      FCRecommendedUserResult(result: false, resultText: 'Flarum has no recommended users');

  @override
  Future<FCIgnoreUserResult> ignoreUserAsync(String userId, int mode) async =>
      FCIgnoreUserResult(result: false, resultText: 'Not available yet');

  @override
  Future<FCIgnoredUserResult> getIgnoredUsersAsync(int page, int perpage) async =>
      FCIgnoredUserResult(result: false, resultText: 'Not available yet');

  /// flarum/flags reports posts only.
  @override
  Future<FCReportUserResult> reportUserAsync(String userId, String reason) async =>
      FCReportUserResult(result: false, resultText: 'Flarum reports posts, not users');

  @override
  Future<FCDirectoryItemResult> getDirectoryItemsAsync(String period, String order, int page) async =>
      FCDirectoryItemResult(result: false, resultText: 'Not available yet', total: 0, items: const []);

  @override
  Future<FCBadgeResult> getAllBadgesAsync() async => FCBadgeResult(result: false, resultText: 'Flarum has no badges in core');

  @override
  Future<FCBadgeResult> getUserBadgesAsync(String username) async =>
      FCBadgeResult(result: false, resultText: 'Flarum has no badges in core');

  Future<FlarumUser> _user({String? userId, String? username}) {
    if (userId != null && userId.isNotEmpty) return _forum.api.user(userId);
    if (username != null && username.isNotEmpty) return _forum.api.userByUsername(username);
    throw ArgumentError('A user id or username is needed');
  }

  /// [user] as the SDK's user.
  static FCUser toUser(FlarumUser user) => FCUser(
        id: user.id,
        username: user.username,
        displayText: user.displayName,
        iconUrl: user.avatarUrl,
        postCount: user.commentCount ?? 0,
        registrationTime: user.joinTime,
        lastSeenAt: user.lastSeenAt,
        lastActivityTime: user.lastSeenAt,
        canSearch: true,
      );
}
