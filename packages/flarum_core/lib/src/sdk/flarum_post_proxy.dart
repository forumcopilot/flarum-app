import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_vote.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_reaction_result.dart';

import '../flarum_api.dart';
import '../models/discussion.dart';
import '../models/post.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_topic_proxy.dart';

/// A discussion's posts: pages by offset, or around a post (the reader's
/// first unread, or a linked one). Writing, reporting, likes, reactions and
/// polls arrive with the write path (Phase 3).
class FlarumPostProxy implements IFCPostProxy {
  FlarumPostProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  @override
  Future<FCThreadResult> getThreadAsync(String topicId, int startNum, int lastNum, bool returnHtml) async {
    try {
      final offset = startNum < 0 ? 0 : startNum;
      final limit = (lastNum >= offset ? lastNum - offset + 1 : 20).clamp(1, FlarumApi.maxPageSize);
      final (discussion, page) = await (_forum.api.discussion(topicId), _forum.api.posts(topicId, offset: offset, limit: limit)).wait;
      final topic = await _topic(discussion);
      return _thread(topic, discussion, _posts(page.items, topic));
    } catch (e) {
      return FCThreadResult(result: false, resultText: describeFlarumError(e), totalPostNum: 0, id: topicId, title: '',
          forumId: '', forumName: '', authorId: '', authorName: '', authorUserType: 'normal', timestamp: _epoch);
    }
  }

  /// The page around the reader's first unread post (the first post for guests).
  @override
  Future<FCThreadByUnreadResult> getThreadByUnreadAsync(String topicId, int postsPerRequest, bool returnHtml) async {
    try {
      final discussion = await _forum.api.discussion(topicId);
      final last = discussion.lastPostNumber ?? 1;
      final anchor = ((discussion.lastReadPostNumber ?? 0) + 1).clamp(1, last);
      final page = await _forum.api.postsNear(topicId, anchor, limit: postsPerRequest);
      final topic = await _topic(discussion);
      final posts = _posts(page.items, topic);
      return FCThreadByUnreadResult(
        result: true,
        resultText: '',
        totalPostNum: _total(discussion),
        position: anchor,
        posts: posts,
        canReply: topic.canReply,
        canReport: topic.canReport,
        canUpload: _forum.extensions.upload,
        id: topic.id,
        title: topic.title,
        forumId: topic.forumId,
        forumName: topic.forumName,
        authorId: topic.authorId,
        authorName: topic.authorName,
        authorUserType: 'normal',
        authorIconUrl: topic.authorIconUrl,
        timestamp: topic.timestamp,
        replyCount: topic.replyCount,
        isClosed: topic.isClosed,
        isSubscribed: topic.isSubscribed,
        canSubscribe: topic.canSubscribe,
        url: topic.url,
        isPinned: topic.isPinned,
        tags: topic.tags,
        isSolved: topic.isSolved,
      );
    } catch (e) {
      return FCThreadByUnreadResult(result: false, resultText: describeFlarumError(e), totalPostNum: 0, position: 1,
          id: topicId, title: '', forumId: '', forumName: '', authorId: '', authorName: '', authorUserType: 'normal',
          timestamp: _epoch);
    }
  }

  /// The page around [postId], for opening a link to a post.
  @override
  Future<FCThreadByPostResult> getThreadByPostAsync(String postId, int postsPerRequest, bool returnHtml) async {
    try {
      final target = await _forum.api.post(postId);
      final topicId = target.discussionId;
      if (topicId == null) throw StateError('Post $postId has no discussion');
      final (discussion, page) =
          await (_forum.api.discussion(topicId), _forum.api.postsNear(topicId, target.number, limit: postsPerRequest)).wait;
      final topic = await _topic(discussion);
      return FCThreadByPostResult(
        result: true,
        resultText: '',
        totalPostNum: _total(discussion),
        position: target.number,
        posts: _posts(page.items, topic),
        canReply: topic.canReply,
        canReport: topic.canReport,
        canUpload: _forum.extensions.upload,
        id: topic.id,
        title: topic.title,
        forumId: topic.forumId,
        forumName: topic.forumName,
        authorId: topic.authorId,
        authorName: topic.authorName,
        authorUserType: 'normal',
        authorIconUrl: topic.authorIconUrl,
        timestamp: topic.timestamp,
        replyCount: topic.replyCount,
        isClosed: topic.isClosed,
        isSubscribed: topic.isSubscribed,
        canSubscribe: topic.canSubscribe,
        url: topic.url,
        isPinned: topic.isPinned,
        tags: topic.tags,
        isSolved: topic.isSolved,
      );
    } catch (e) {
      return FCThreadByPostResult(result: false, resultText: describeFlarumError(e), totalPostNum: 0, position: 1,
          id: '', title: '', forumId: '', forumName: '', authorId: '', authorName: '', authorUserType: 'normal',
          timestamp: _epoch);
    }
  }

  /// A post's source, which Flarum sends only to readers who may edit it.
  @override
  Future<FCRawPostResult> getRawPostAsync(String postId) async {
    try {
      final post = await _forum.api.post(postId);
      final source = post.content;
      if (!post.canEdit || source is! String) {
        return FCRawPostResult(result: false, resultText: 'You can\'t edit this post');
      }
      return FCRawPostResult(result: true, resultText: '', postContent: source, canEditTitle: false);
    } catch (e) {
      return FCRawPostResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// A quote as Flarum's web writes it: `> @"Name"#p123 text`, which
  /// flarum/mentions turns into a link to the post. The text is the source
  /// when the reader may see it, else the rendered post as plain text.
  @override
  Future<FCQuotePostResult> getQuotePostAsync(String postId) async {
    try {
      final post = await _forum.api.post(postId);
      final source = post.content;
      final text = source is String ? source : plainText(post.contentHtml ?? '');
      final name = post.author?.displayName ?? '';
      final quoted = text.trim().split('\n').join('\n> ');
      return FCQuotePostResult(result: true, resultText: '', quoteContent: '> @"$name"#p${post.id} $quoted\n\n');
    } catch (e) {
      return FCQuotePostResult(result: false, resultText: describeFlarumError(e));
    }
  }

  // ---- The write path arrives in Phase 3. ----

  static const _later = 'Not available yet';

  @override
  Future<FCReportPostResult> reportPostAsync(String postId, String reason) async =>
      FCReportPostResult(result: false, resultText: _later);

  @override
  Future<FCReplyPostResult> replyPostAsync(String forumId, String topicId, String subject, String textBody,
          List<String>? attachmentIds, String? groupId, bool returnHtml) async =>
      FCReplyPostResult(result: false, resultText: _later);

  @override
  Future<FCSaveRawPostResult> saveRawPostAsync(String postId, String postTitle, String postContent, bool returnHtml,
          String? reason, List<String>? attachmentIds, String? groupId, String? prefix) async =>
      FCSaveRawPostResult(result: false, resultText: _later);

  @override
  Future<FCPoll?> votePollAsync(String topicId, List<String> responseIds) async => null;

  @override
  Future<FCAcceptAnswerResult> acceptAnswerAsync(String postId) async =>
      FCAcceptAnswerResult(result: false, resultText: _later);

  @override
  Future<FCAcceptAnswerResult> unacceptAnswerAsync(String postId) async =>
      FCAcceptAnswerResult(result: false, resultText: _later);

  @override
  Future<FCToggleReactionResult> toggleReactionAsync(String postId, String reactionId) async =>
      FCToggleReactionResult(result: false, resultText: _later);

  @override
  Future<FCAvailableReactionsResult> getAvailableReactionsAsync() async =>
      FCAvailableReactionsResult(result: false, resultText: _later);

  /// Flarum has no post votes (that would be fof/gamification).
  @override
  Future<FCPostVoteResult> castPostVoteAsync(String postId, String direction, {FCPostVote? previous}) async =>
      FCPostVoteResult(result: false, resultText: 'Flarum has no post votes');

  @override
  Future<FCPostVoteResult> removePostVoteAsync(String postId, {FCPostVote? previous}) async =>
      FCPostVoteResult(result: false, resultText: 'Flarum has no post votes');

  // ---- Mapping ----

  Future<FCTopic> _topic(FlarumDiscussion discussion) async {
    final info = await _forum.current();
    final reader = info.actor;
    return FlarumTopicProxy.toTopic(
      discussion,
      baseUrl: _forum.baseUrl,
      markedAllAsReadAt: reader?.markedAllAsReadAt,
      signedIn: reader != null,
      canReport: _forum.extensions.flags && reader != null,
    );
  }

  static int _total(FlarumDiscussion d) => d.lastPostNumber ?? d.commentCount;

  List<FCPost> _posts(List<FlarumPost> posts, FCTopic topic) =>
      [for (final post in posts) toPost(post, topicId: topic.id, topicTitle: topic.title)];

  FCThreadResult _thread(FCTopic topic, FlarumDiscussion discussion, List<FCPost> posts) => FCThreadResult(
        result: true,
        resultText: '',
        totalPostNum: _total(discussion),
        posts: posts,
        id: topic.id,
        title: topic.title,
        forumId: topic.forumId,
        forumName: topic.forumName,
        authorId: topic.authorId,
        authorName: topic.authorName,
        authorUserType: 'normal',
        authorIconUrl: topic.authorIconUrl,
        timestamp: topic.timestamp,
        replyCount: topic.replyCount,
        hasNewPosts: topic.hasNewPosts,
        isClosed: topic.isClosed,
        isSubscribed: topic.isSubscribed,
        canSubscribe: topic.canSubscribe,
        url: topic.url,
        isPinned: topic.isPinned,
        canRename: topic.canRename,
        canDelete: topic.canDelete,
        canClose: topic.canClose,
        canStick: topic.canStick,
        canMove: topic.canMove,
        canReply: topic.canReply,
        canReport: topic.canReport,
        canUpload: _forum.extensions.upload,
        isApproved: topic.isApproved,
        isDeleted: topic.isDeleted,
        hasPoll: topic.hasPoll,
        unreadCount: topic.unreadCount,
        tags: topic.tags,
        isSolved: topic.isSolved,
      );

  /// [post] as the SDK's post. Event posts (a rename, lock, sticky, retag…)
  /// carry their type as [FCPost.actionCode] and no text.
  static FCPost toPost(FlarumPost post, {required String topicId, String? topicTitle}) => FCPost(
        id: post.id,
        title: '',
        content: post.isComment ? post.contentHtml ?? '' : '',
        topicId: topicId,
        topicTitle: topicTitle,
        authorId: post.author?.id ?? '',
        authorName: post.author?.username ?? '',
        authorDisplayName: post.author?.displayName,
        authorIconUrl: post.author?.avatarUrl,
        timestamp: post.createdAt,
        postNumber: post.number,
        canEdit: post.canEdit,
        canDelete: post.canDelete || post.canHide,
        canApprove: post.canApprove,
        canReport: post.canFlag,
        canLike: post.canLike,
        likeCount: post.likesCount,
        replyCount: post.mentionedByCount,
        isApproved: post.isApproved,
        isDeleted: post.isHidden,
        isHidden: post.isHidden,
        bookmarked: post.bookmarked,
        canAcceptAnswer: post.canSelectAsBestAnswer,
        actionCode: post.isComment ? null : post.contentType,
        isModeratorAction: !post.isComment,
      );

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);
}

/// Rendered post HTML as plain text: tags dropped, block ends as line
/// breaks, the common entities decoded. Good enough to quote from.
String plainText(String html) {
  var text = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|li|h\d|blockquote|pre)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  const entities = {'&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&#39;': "'", '&nbsp;': ' '};
  entities.forEach((entity, char) => text = text.replaceAll(entity, char));
  return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
