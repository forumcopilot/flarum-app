import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_private_conversation_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

import '../flarum_api.dart';
import '../models/discussion.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'flarum_attachment_proxy.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_post_proxy.dart' show plainText;

/// [IFCPrivateConversationProxy] on fof/byobu's private discussions: a conversation is a private
/// discussion, its messages are the posts. Byobu has no closing, leaving or archiving, and a
/// member may not change who's in one, so those answer `result: false`.
class FlarumPrivateConversationProxy implements IFCPrivateConversationProxy {
  FlarumPrivateConversationProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  static const _none = "Flarum's private discussions have no such thing";

  /// Starts a private discussion with [userName]s (usernames, or slugs on forums that use ids).
  @override
  Future<FCNewConversationResult> newConversationAsync(List<String> userName, String subject, String textBody,
      {List<String>? attachmentIds, String? groupId, bool? openInvite, bool? conversationLocked}) async {
    try {
      final ids = [for (final name in userName) (await _forum.api.userBySlug(name)).id];
      final discussion = await _forum.api
          .startPrivateDiscussion(subject, FlarumAttachmentProxy.withAttachments(textBody, attachmentIds), ids);
      return FCNewConversationResult(result: true, resultText: '', convId: discussion.id);
    } catch (e) {
      return FCNewConversationResult(result: false, resultText: describeFlarumError(e), convId: '');
    }
  }

  @override
  Future<FCReplyConversationResult> replyConversationAsync(
      String conversationId, String textBody, List<String>? attachmentIds, String? groupId) async {
    try {
      final post =
          await _forum.api.reply(conversationId, FlarumAttachmentProxy.withAttachments(textBody, attachmentIds));
      return FCReplyConversationResult(result: true, resultText: '', messageId: post.id);
    } catch (e) {
      return FCReplyConversationResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Adds [userName]s to the private discussion; byobu lets only those with the permission.
  @override
  Future<FCInviteParticipantResult> inviteParticipantAsync(
      List<String> userName, String conversationId, String? reason) async {
    try {
      final people = await _forum.api.recipients(conversationId);
      final added = [for (final name in userName) (await _forum.api.userBySlug(name)).id];
      await _forum.api.setRecipients(conversationId, {for (final user in people) user.id, ...added}.toList());
      return FCInviteParticipantResult(result: true, resultText: '');
    } catch (e) {
      return FCInviteParticipantResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// The reader's private discussions and how many have something new: from the first page of
  /// 50, the most the forum gives at once.
  @override
  Future<FCInboxStatResult> getInboxStatAsync() async {
    try {
      final page = await _forum.api.discussions(private: true, limit: FlarumApi.maxPageSize);
      final unread = page.items.where(_hasUnread).toList();
      return FCInboxStatResult(
        result: true,
        resultText: '',
        totalConversations: page.total ?? page.items.length,
        unreadConversations: unread.length,
        unreadMessages: unread.fold(0, (sum, d) => sum + (d.lastPostNumber ?? 0) - (d.lastReadPostNumber ?? 0)),
      );
    } catch (e) {
      return FCInboxStatResult(
          result: false, resultText: describeFlarumError(e), totalConversations: 0, unreadConversations: 0, unreadMessages: 0);
    }
  }

  @override
  Future<FCConversationsResult> getConversationsAsync(int startNum, int lastNum) async {
    try {
      final offset = startNum < 0 ? 0 : startNum;
      final limit = (lastNum >= offset ? lastNum - offset + 1 : 20).clamp(1, FlarumApi.maxPageSize);
      final page = await _forum.api.discussions(private: true, offset: offset, limit: limit);
      return FCConversationsResult(
        result: true,
        resultText: '',
        conversationCount: page.total ?? offset + page.items.length,
        unreadCount: page.items.where(_hasUnread).length,
        canUpload: _forum.info?.can('fof-upload.canUpload') ?? false,
        list: [
          for (final d in page.items)
            FCConversationSummary(
              convId: d.id,
              replyCount: '${d.commentCount > 0 ? d.commentCount - 1 : 0}',
              participantCount: d.recipients.length,
              startUserId: d.author?.id,
              startTime: d.createdAt?.toIso8601String(),
              subject: d.title,
              convSubject: d.title,
              lastUserId: d.lastPostedUser?.id,
              lastReplyTime: d.lastPostedAt?.toIso8601String(),
              newPost: _hasUnread(d),
              participants: [for (final user in d.recipients) _participant(user)],
              canEdit: d.canRename,
              canClose: false,
              isClosed: d.isLocked,
              unreadMessageCount: _hasUnread(d) ? (d.lastPostNumber ?? 0) - (d.lastReadPostNumber ?? 0) : 0,
            ),
        ],
      );
    } catch (e) {
      return FCConversationsResult(
          result: false, resultText: describeFlarumError(e), conversationCount: 0, unreadCount: 0, canUpload: false, list: const []);
    }
  }

  @override
  Future<FCConversationResult> getConversationAsync(
      String conversationId, int startNum, int lastNum, bool returnHtml) async {
    try {
      final offset = startNum < 0 ? 0 : startNum;
      final limit = (lastNum >= offset ? lastNum - offset + 1 : 20).clamp(1, FlarumApi.maxPageSize);
      final (discussion, page, people) = await (
        _forum.api.discussion(conversationId),
        _forum.api.posts(conversationId, offset: offset, limit: limit),
        _forum.api.recipients(conversationId),
      ).wait;
      return _conversation(discussion, page.items, people, returnHtml: returnHtml, position: offset + 1);
    } catch (e) {
      return FCConversationResult(
          result: false, resultText: describeFlarumError(e), convId: conversationId, messages: const [], participants: const []);
    }
  }

  @override
  Future<FCConversationResult> getConversationByMessageAsync(String messageId, {int messagesPerRequest = 20}) async {
    try {
      final target = await _forum.api.post(messageId);
      final id = target.discussionId;
      if (id == null) throw StateError('Post $messageId has no discussion');
      final (discussion, page, people) = await (
        _forum.api.discussion(id),
        _forum.api.postsNear(id, target.number, limit: messagesPerRequest),
        _forum.api.recipients(id),
      ).wait;
      return _conversation(discussion, page.items, people, returnHtml: true, position: target.number);
    } catch (e) {
      return FCConversationResult(
          result: false, resultText: describeFlarumError(e), convId: '', messages: const [], participants: const []);
    }
  }

  /// A quote as Flarum's web writes one, `> @"Name"#p123 text`.
  @override
  Future<FCQuoteConversationResult> getQuoteConversationAsync(String conversationId, String messageId) async {
    try {
      final post = await _forum.api.post(messageId);
      final name = post.author?.displayName ?? '';
      final text = (post.source ?? plainText(post.contentHtml ?? '')).trim().split('\n').join('\n> ');
      return FCQuoteConversationResult(
          result: true, resultText: '', quoteText: '> @"$name"#p${post.id} $text\n\n', authorName: name);
    } catch (e) {
      return FCQuoteConversationResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCMarkConversationReadResult> markConversationReadAsync(String conversationId) async {
    try {
      final discussion = await _forum.api.discussion(conversationId);
      await _forum.api.markDiscussionRead(conversationId, discussion.lastPostNumber ?? 1);
      return FCMarkConversationReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkConversationReadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Flarum never lowers a discussion's read mark.
  @override
  Future<FCMarkConversationUnreadResult> markConversationUnreadAsync(String conversationId) async =>
      FCMarkConversationUnreadResult(result: false, resultText: 'Flarum has no "mark unread"');

  @override
  Future<FCLeaveConversationResult> leaveConversationAsync(String conversationId, int mode) async =>
      FCLeaveConversationResult(result: false, resultText: _none);

  @override
  Future<FCCloseConversationResult> closeConversationAsync(String conversationId) async =>
      FCCloseConversationResult(result: false, resultText: _none);

  @override
  Future<FCCloseConversationResult> uncloseConversationAsync(String conversationId) async =>
      FCCloseConversationResult(result: false, resultText: _none);

  @override
  Future<FCArchiveConversationResult> archiveConversationAsync(String conversationId) async =>
      FCArchiveConversationResult(result: false, resultText: _none);

  @override
  Future<FCArchiveConversationResult> unarchiveConversationAsync(String conversationId) async =>
      FCArchiveConversationResult(result: false, resultText: _none);

  @override
  Future<FCRawConversationResult> getRawConversationAsync(String conversationId) async {
    try {
      final discussion = await _forum.api.discussion(conversationId);
      return FCRawConversationResult(
          result: true, resultText: '', conversationTitle: discussion.title, canEdit: discussion.canRename);
    } catch (e) {
      return FCRawConversationResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Renaming a discussion comes with moderation (Milestone 5).
  @override
  Future<FCSaveRawConversationResult> saveRawConversationAsync(String conversationId,
          {String? conversationTitle, bool? openInvite, bool? conversationOpen}) async =>
      FCSaveRawConversationResult(result: false, resultText: 'Not available yet');

  @override
  Future<FCRawMessageResult> getRawMessageAsync(String messageId) async {
    try {
      final source = (await _forum.api.post(messageId)).source;
      if (source == null) return FCRawMessageResult(result: false, resultText: 'You can\'t edit this message');
      return FCRawMessageResult(result: true, resultText: '', messageContent: source);
    } catch (e) {
      return FCRawMessageResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCSaveRawMessageResult> saveRawMessageAsync(String messageId, String messageContent,
      {List<String>? attachmentIds, String? groupId}) async {
    try {
      final post =
          await _forum.api.editPost(messageId, FlarumAttachmentProxy.withAttachments(messageContent, attachmentIds));
      return FCSaveRawMessageResult(result: true, resultText: '', messageContent: post.contentHtml);
    } catch (e) {
      return FCSaveRawMessageResult(result: false, resultText: describeFlarumError(e));
    }
  }

  FCConversationResult _conversation(FlarumDiscussion discussion, List<FlarumPost> posts, List<FlarumUser> people,
      {required bool returnHtml, required int position}) {
    final readerId = _forum.info?.actor?.id;
    return FCConversationResult(
      result: true,
      resultText: '',
      convId: discussion.id,
      subject: discussion.title,
      convTitle: discussion.title,
      messages: [
        for (final post in posts)
          if (post.isComment)
            FCConversationMessage(
              messageId: post.id,
              userId: post.author?.id ?? '',
              username: post.author?.username ?? '',
              iconUrl: post.author?.avatarUrl,
              textBody: returnHtml ? post.contentHtml ?? '' : post.source ?? plainText(post.contentHtml ?? ''),
              messageTime: post.createdAt?.toIso8601String() ?? '',
              isFromCurrentUser: readerId != null && post.author?.id == readerId,
              canLike: post.canLike,
              isLiked: post.isLikedBy(readerId),
              likeCount: post.likesCount,
              isUnread: post.number > (discussion.lastReadPostNumber ?? 0),
              isFirstMessage: post.number == 1,
              canReport: post.canFlag,
              isIgnored: post.author?.ignored,
              canEdit: post.canEdit,
              messageNumber: post.number,
            ),
      ],
      participants: [for (final user in people) _participant(user)],
      participantCount: people.length,
      canReply: discussion.canReply,
      canInvite: discussion.canEditRecipients,
      canEdit: discussion.canRename,
      canClose: false,
      isClosed: discussion.isLocked,
      totalMessageNum: discussion.commentCount,
      lastRead: discussion.lastReadPostNumber,
      canUpload: _forum.info?.can('fof-upload.canUpload') ?? false,
      position: position,
    );
  }

  static FCParticipant _participant(FlarumUser user) =>
      FCParticipant(userId: user.id, username: user.username, iconUrl: user.avatarUrl);

  static bool _hasUnread(FlarumDiscussion d) => (d.lastPostNumber ?? 0) > (d.lastReadPostNumber ?? 0);
}
