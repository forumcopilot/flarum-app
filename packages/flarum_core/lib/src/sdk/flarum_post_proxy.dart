import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_vote.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_reaction_result.dart';

import '../flarum_api.dart';
import '../models/discussion.dart';
import '../models/poll.dart';
import '../models/post.dart';
import 'flarum_attachment_proxy.dart';
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
      return _thread(topic, discussion, _posts(page.items, topic, discussion));
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
      final posts = _posts(page.items, topic, discussion);
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
        posts: _posts(page.items, topic, discussion),
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

  // ---- The write path (Phase 3). ----

  /// flarum/flags: [reason] is one of the forum's (`off_topic`, `inappropriate`, `spam`), or the
  /// reporter's own words, sent as "Other".
  @override
  Future<FCReportPostResult> reportPostAsync(String postId, String reason) async {
    try {
      final known = const {'off_topic', 'inappropriate', 'spam'}.contains(reason);
      await _forum.api.flagPost(postId, reason: known ? reason : null, detail: known ? '' : reason);
      return FCReportPostResult(result: true, resultText: '');
    } catch (e) {
      return FCReportPostResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCReplyPostResult> replyPostAsync(String forumId, String topicId, String subject, String textBody,
      List<String>? attachmentIds, String? groupId, bool returnHtml) async {
    try {
      final post = await _forum.api.reply(topicId, FlarumAttachmentProxy.withAttachments(textBody, attachmentIds));
      return FCReplyPostResult(
        result: true,
        resultText: '',
        postId: post.id,
        // 1: posted, but held for a moderator's approval.
        state: post.isApproved ? 0 : 1,
        postContent: post.contentHtml ?? '',
        canEdit: post.canEdit,
        canDelete: post.canDelete || post.canHide,
        canReport: post.canFlag,
      );
    } catch (e) {
      return FCReplyPostResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Saves an edit. [postTitle] is ignored: on Flarum the title is the discussion's, renamed on
  /// its own (`renameTopicAsync`).
  @override
  Future<FCSaveRawPostResult> saveRawPostAsync(String postId, String postTitle, String postContent, bool returnHtml,
      String? reason, List<String>? attachmentIds, String? groupId, String? prefix) async {
    try {
      final post = await _forum.api.editPost(postId, postContent);
      return FCSaveRawPostResult(result: true, resultText: '', postContent: post.contentHtml ?? '');
    } catch (e) {
      return FCSaveRawPostResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Votes in the poll of discussion [topicId] that has the options [responseIds] (its first
  /// post's, which a new discussion's poll is on): [responseIds] is the reader's whole choice, and
  /// none takes their vote back. Null when it fails.
  @override
  Future<FCPoll?> votePollAsync(String topicId, List<String> responseIds) async {
    try {
      final first = (await _forum.api.posts(topicId)).items.firstOrNull;
      final polls = first?.polls ?? const <FlarumPoll>[];
      final poll = polls
              .where((poll) => responseIds.every((id) => poll.options.any((option) => option.id == id)))
              .firstOrNull ??
          polls.firstOrNull;
      if (first == null || poll == null) return null;
      return toPoll(await _forum.api.votePoll(poll.id, responseIds), topicId: topicId, postId: first.id);
    } catch (_) {
      return null;
    }
  }

  /// Chooses [postId] as its discussion's best answer (fof/best-answer).
  @override
  Future<FCAcceptAnswerResult> acceptAnswerAsync(String postId) => _bestAnswer(postId, choose: true);

  @override
  Future<FCAcceptAnswerResult> unacceptAnswerAsync(String postId) => _bestAnswer(postId, choose: false);

  Future<FCAcceptAnswerResult> _bestAnswer(String postId, {required bool choose}) async {
    try {
      final discussionId = (await _forum.api.post(postId)).discussionId;
      if (discussionId == null) throw StateError('Post $postId has no discussion');
      await _forum.api.setBestAnswer(discussionId, choose ? postId : null);
      return FCAcceptAnswerResult(result: true, resultText: '');
    } catch (e) {
      return FCAcceptAnswerResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Reacts to [postId] with the reaction named [reactionId] (its shortcode, as the SDK names
  /// reactions), or takes it back when it's already the reader's (fof/reactions).
  @override
  Future<FCToggleReactionResult> toggleReactionAsync(String postId, String reactionId) async {
    try {
      final reactions = (await _forum.current()).reactions;
      final reaction = reactions.where((r) => r.identifier == reactionId || r.id == reactionId).firstOrNull;
      if (reaction == null) return FCToggleReactionResult(result: false, resultText: 'No reaction $reactionId');
      final post = await _forum.api.post(postId);
      final updated = post.userReactionId == reaction.id
          ? await _forum.api.unreactToPost(postId, reaction.id)
          : await _forum.api.reactToPost(postId, reaction.id);
      return FCToggleReactionResult(result: true, resultText: '', reactions: [
        for (final r in reactions)
          if ((updated.reactionCounts[r.id] ?? 0) > 0)
            FCPostReaction(
              id: r.identifier,
              type: r.type,
              count: updated.reactionCounts[r.id]!,
              viewerReacted: updated.userReactionId == r.id,
              canUndo: true,
            ),
      ]);
    } catch (e) {
      return FCToggleReactionResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// The forum's reactions by shortcode (fof/reactions).
  @override
  Future<FCAvailableReactionsResult> getAvailableReactionsAsync() async {
    try {
      final reactions = (await _forum.current()).reactions;
      return FCAvailableReactionsResult(result: true, resultText: '', reactions: [for (final r in reactions) r.identifier]);
    } catch (e) {
      return FCAvailableReactionsResult(result: false, resultText: describeFlarumError(e));
    }
  }

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

  List<FCPost> _posts(List<FlarumPost> posts, FCTopic topic, FlarumDiscussion discussion) => [
        for (final post in posts)
          toPost(post, topicId: topic.id, topicTitle: topic.title, isSolution: post.id == discussion.bestAnswerPostId),
      ];

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
        poll: posts.where((post) => post.postNumber == 1).firstOrNull?.polls.firstOrNull,
        unreadCount: topic.unreadCount,
        tags: topic.tags,
        isSolved: topic.isSolved,
      );

  /// [post] as the SDK's post. Event posts (a rename, lock, sticky, retag…)
  /// carry their type as [FCPost.actionCode] and no text. [isSolution]: fof/best-answer chose it.
  static FCPost toPost(FlarumPost post, {required String topicId, String? topicTitle, bool isSolution = false}) =>
      FCPost(
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
        isSolution: isSolution,
        canAcceptAnswer: post.canSelectAsBestAnswer,
        actionCode: post.isComment ? null : post.contentType,
        isModeratorAction: !post.isComment,
        polls: [for (final poll in post.polls) toPoll(poll, topicId: topicId, postId: post.id)],
      );

  /// [poll] as the SDK's: its vote count stands for the voters' (the same in a single-choice
  /// poll), and its options' counts are null while the reader may not see them.
  static FCPoll toPoll(FlarumPoll poll, {required String topicId, String? postId}) => FCPoll(
        pollId: poll.id,
        topicId: topicId,
        question: poll.question,
        responses: [
          for (final option in poll.options)
            FCPollResponse(
              id: option.id,
              text: option.answer,
              voteCount: option.voteCount,
              viewerVotedFor: poll.myVotes.contains(option.id),
            ),
        ],
        voterCount: poll.voteCount,
        maxVotes: poll.allowMultipleVotes ? poll.maxVotes : 1,
        changeVote: poll.canChangeVote,
        publicVotes: poll.publicPoll,
        viewResultsUnvoted: poll.showsResults && !poll.hasVoted,
        closeDate: poll.endDate?.millisecondsSinceEpoch ?? 0,
        isClosed: poll.hasEnded,
        canVote: poll.canVote,
        hasVoted: poll.hasVoted,
        canViewResults: poll.showsResults,
        postId: postId,
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
