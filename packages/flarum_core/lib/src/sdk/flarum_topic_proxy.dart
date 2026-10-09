import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_topic_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';

import '../flarum_api.dart';
import '../models/discussion.dart';
import '../models/tag.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_post_proxy.dart' show plainText;

/// Discussion lists and read state.
///
/// A list's range (startNum…lastNum, inclusive) becomes Flarum's offset and
/// limit, capped at 50. Totals are "at least": what's loaded plus one when
/// another page exists, as discourse_core reports them; 1.x gives no totals.
class FlarumTopicProxy implements IFCTopicProxy {
  FlarumTopicProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// A tag's latest discussions, stickies included.
  @override
  Future<FCTopicDataResult> getTopicAsync(String forumId, int startNum, int lastNum) =>
      _tagList(forumId, startNum, lastNum, DiscussionSort.latest);

  /// A tag's most-replied discussions: "top" as discourse_core and the web use it.
  @override
  Future<FCTopicDataResult> getTopTopicAsync(String forumId, int startNum, int lastNum) =>
      _tagList(forumId, startNum, lastNum, DiscussionSort.top);

  /// Forum-wide stickies, the nearest Flarum has to announcements.
  @override
  Future<FCTopicDataResult> getAnnTopicAsync(String forumId, int startNum, int lastNum) async {
    try {
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(sticky: true, offset: offset, limit: limit);
      return FCTopicDataResult(
        result: true,
        resultText: '',
        totalTopicNum: _total(page),
        topics: await topics(page.items),
      );
    } catch (e) {
      return FCTopicDataResult(result: false, resultText: describeFlarumError(e), totalTopicNum: 0);
    }
  }

  @override
  Future<FCLatestTopicResult> getLatestTopicAsync(int startNum, int lastNum, {String? searchId, List<String>? filters}) =>
      _latest(DiscussionSort.latest, startNum, lastNum);

  /// Newest discussions by creation, the web's "Newest".
  @override
  Future<FCLatestTopicResult> getNewTopicAsync(int startNum, int lastNum, {String? searchId, List<String>? filters}) =>
      _latest(DiscussionSort.newest, startNum, lastNum);

  @override
  Future<FCUnreadTopicResult> getUnreadTopicAsync(int startNum, int lastNum, {String? searchId, List<String>? filters}) async {
    try {
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(unread: true, offset: offset, limit: limit);
      return FCUnreadTopicResult(result: true, resultText: '', totalUnreadNum: _total(page), topics: await topics(page.items));
    } catch (e) {
      return FCUnreadTopicResult(result: false, resultText: describeFlarumError(e), totalUnreadNum: 0);
    }
  }

  /// Discussions [username] started. Flarum has no "participated" list; the
  /// ones they only replied to would need assembling from their posts.
  @override
  Future<FCParticipatedTopicResult> getParticipatedTopicAsync(String username, int startNum, int lastNum,
      {String? searchId, String? userId}) async {
    try {
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(author: username, offset: offset, limit: limit);
      return FCParticipatedTopicResult(
        result: true,
        resultText: '',
        totalParticipatedNum: _total(page),
        topics: await topics(page.items),
      );
    } catch (e) {
      return FCParticipatedTopicResult(result: false, resultText: describeFlarumError(e), totalParticipatedNum: 0);
    }
  }

  /// One request per discussion: Flarum lists can't filter by id.
  @override
  Future<FCTopicByIdsResult> getTopicByIds(List<String> topicIds) async {
    try {
      final discussions = await Future.wait(topicIds.map(_forum.api.discussion));
      return FCTopicByIdsResult(result: true, resultText: '', topics: await topics(discussions));
    } catch (e) {
      return FCTopicByIdsResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCTopicStatusResult> getTopicStatusAsync(List<String> topicIds) async {
    try {
      final reader = (await _forum.current()).actor;
      final discussions = await Future.wait(topicIds.map(_forum.api.discussion));
      return FCTopicStatusResult(result: true, resultText: '', topics: [
        for (final d in discussions)
          FCTopicStatus(
            topicId: d.id,
            newPost: unreadCount(d, reader?.markedAllAsReadAt, signedIn: reader != null) > 0,
            replyNumber: _replies(d),
            viewNumber: 0,
            isClosed: d.isLocked,
            isSubscribed: d.subscription == 'follow',
            canSubscribe: reader != null,
            lastReplyTime: d.lastPostedAt,
          ),
      ]);
    } catch (e) {
      return FCTopicStatusResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Marks each discussion read to its last post.
  @override
  Future<FCMarkTopicReadResult> markTopicReadAsync(List<String> topicIds) async {
    try {
      for (final id in topicIds) {
        final discussion = await _forum.api.discussion(id);
        final last = discussion.lastPostNumber;
        if (last != null) await _forum.api.markDiscussionRead(id, last);
      }
      return FCMarkTopicReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Flarum keeps one high-water mark per discussion: the highest number read.
  /// Dwell time isn't recorded. Guests and an empty list succeed without a request.
  @override
  Future<FCMarkTopicReadResult> markPostsReadAsync({
    required String topicId,
    required List<int> postNumbers,
    int msPerPost = 2000,
  }) async {
    try {
      if (postNumbers.isEmpty || _forum.api.client.token == null) {
        return FCMarkTopicReadResult(result: true, resultText: '');
      }
      final highest = postNumbers.reduce((a, b) => a > b ? a : b);
      await _forum.api.markDiscussionRead(topicId, highest);
      return FCMarkTopicReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Starting discussions arrives with the write path (Phase 3).
  @override
  Future<FCNewTopicResult> newTopic(String forumId, String subject, String textBody,
          {String? prefixId, List<String>? attachmentIds, String? groupId, List<String>? tags}) async =>
      FCNewTopicResult(result: false, resultText: 'Starting discussions is not available yet', topicId: '', state: 0);

  Future<FCTopicDataResult> _tagList(String forumId, int startNum, int lastNum, DiscussionSort sort) async {
    try {
      final tag = (await _forum.tags()).where((t) => t.id == forumId).firstOrNull;
      if (tag == null) return FCTopicDataResult(result: false, resultText: 'No tag $forumId', totalTopicNum: 0);
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(tagSlug: tag.slug, sort: sort, offset: offset, limit: limit);
      final extensions = await _forum.currentExtensions();
      return FCTopicDataResult(
        result: true,
        resultText: '',
        totalTopicNum: _total(page),
        forumId: tag.id,
        forumName: tag.name,
        canPost: tag.canStartDiscussion,
        canUpload: extensions.upload,
        canSubscribe: extensions.followTags,
        isSubscribed: tag.subscription == 'follow' || tag.subscription == 'lurk',
        topics: await topics(page.items),
      );
    } catch (e) {
      return FCTopicDataResult(result: false, resultText: describeFlarumError(e), totalTopicNum: 0);
    }
  }

  Future<FCLatestTopicResult> _latest(DiscussionSort sort, int startNum, int lastNum) async {
    try {
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(sort: sort, offset: offset, limit: limit);
      return FCLatestTopicResult(result: true, resultText: '', totalLatestNum: _total(page), topics: await topics(page.items));
    } catch (e) {
      return FCLatestTopicResult(result: false, resultText: describeFlarumError(e), totalLatestNum: 0);
    }
  }

  /// [discussions] as the SDK's topics, with the reader's read state.
  Future<List<FCTopic>> topics(List<FlarumDiscussion> discussions) async {
    final info = await _forum.current();
    final reader = info.actor;
    return [
      for (final d in discussions)
        toTopic(
          d,
          baseUrl: _forum.baseUrl,
          markedAllAsReadAt: reader?.markedAllAsReadAt,
          signedIn: reader != null,
          canReport: _forum.extensions.flags && reader != null,
        ),
    ];
  }

  /// [d] as the SDK's topic. Its forum is its child tag when it has one,
  /// otherwise its primary tag; its secondary tags become [FCTopic.tags].
  static FCTopic toTopic(
    FlarumDiscussion d, {
    required String baseUrl,
    DateTime? markedAllAsReadAt,
    bool signedIn = false,
    bool canReport = false,
  }) {
    final forumTag = _forumTag(d.tags);
    final unread = unreadCount(d, markedAllAsReadAt, signedIn: signedIn);
    return FCTopic(
      id: d.id,
      title: d.title,
      forumId: forumTag?.id ?? '',
      forumName: forumTag?.name ?? '',
      authorId: d.author?.id ?? '',
      authorName: d.author?.displayName ?? '',
      authorIconUrl: d.author?.avatarUrl,
      timestamp: d.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      lastPosterName: d.lastPostedUser?.displayName,
      lastPosterIconUrl: d.lastPostedUser?.avatarUrl,
      lastPostedAt: d.lastPostedAt,
      participantCount: d.participantCount,
      replyCount: _replies(d),
      hasNewPosts: unread > 0,
      unreadCount: unread,
      isClosed: d.isLocked,
      isSubscribed: d.subscription == 'follow',
      canSubscribe: signedIn,
      // Flarum's slug is the whole path segment, id included: `5-welcome-to-the-forum`.
      url: '$baseUrl/d/${d.slug ?? d.id}',
      isPinned: d.isSticky,
      canRename: d.canRename,
      canDelete: d.canDelete || d.canHide,
      canClose: d.canLock,
      canStick: d.canSticky,
      canMove: d.canTag,
      canReply: d.canReply,
      canReport: canReport,
      isApproved: d.isApproved,
      isDeleted: d.isHidden,
      hasPoll: d.hasPoll,
      isSolved: d.hasBestAnswer,
      tags: [for (final tag in d.tags) if (!tag.isPrimary) tag.name],
      // In search results, the best-matching post.
      shortContent: d.mostRelevantPost == null ? null : excerpt(plainText(d.mostRelevantPost!.contentHtml ?? '')),
    );
  }

  /// [text] cut to about [length] characters, at a word where possible.
  static String excerpt(String text, {int length = 200}) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= length) return flat;
    final cut = flat.lastIndexOf(' ', length);
    return '${flat.substring(0, cut > length ~/ 2 ? cut : length)}…';
  }

  /// Replies, not counting the first post.
  static int _replies(FlarumDiscussion d) => d.commentCount > 0 ? d.commentCount - 1 : 0;

  static FlarumTag? _forumTag(List<FlarumTag> tags) =>
      tags.where((t) => t.isChild).firstOrNull ?? tags.where((t) => t.isPrimary).firstOrNull;

  static (int, int) _range(int startNum, int lastNum) {
    final offset = startNum < 0 ? 0 : startNum;
    final limit = lastNum >= offset ? lastNum - offset + 1 : 20;
    return (offset, limit.clamp(1, FlarumApi.maxPageSize));
  }

  static int _total(FlarumPage<Object?> page) => (page.offset ?? 0) + page.items.length + (page.hasMore ? 1 : 0);
}

/// Unread posts in [d] as Flarum's web counts them: only when its last post
/// is newer than the reader's "mark all read" time, and never more than its
/// comments (deleted posts leave gaps in the numbering). Zero for guests.
int unreadCount(FlarumDiscussion d, DateTime? markedAllAsReadAt, {required bool signedIn}) {
  if (!signedIn) return 0;
  final lastPosted = d.lastPostedAt;
  if (lastPosted == null) return 0;
  if (markedAllAsReadAt != null && !markedAllAsReadAt.isBefore(lastPosted)) return 0;
  final unread = (d.lastPostNumber ?? 0) - (d.lastReadPostNumber ?? 0);
  if (unread <= 0) return 0;
  return unread < d.commentCount ? unread : d.commentCount;
}
