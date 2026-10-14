import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_draft_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';
import 'package:forumcopilot_sdk/models/results/fc_draft_result.dart';

import '../models/draft.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;

/// [IFCDraftProxy] on fof/drafts. Flarum keeps any number of drafts, each for a reply, a new
/// discussion or a private one; the SDK's keys name one of each kind, as Discourse's do:
/// `topic_<discussion id>`, `new_topic`, `new_private_message`. A key stands for the latest draft
/// of its kind. A draft's [FCDraft.data] is `{reply, title?, tags?, recipients?}`, the last two ids.
/// fof/drafts has no sequence numbers: the SDK's are always 0.
class FlarumDraftProxy implements IFCDraftProxy {
  FlarumDraftProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  static const _newDiscussion = 'new_topic';
  static const _newPrivateDiscussion = 'new_private_message';
  static const _replyPrefix = 'topic_';

  /// [draft]'s key: what it's for.
  static String keyOf(FlarumDraft draft) => draft.isReply
      ? '$_replyPrefix${draft.discussionId}'
      : draft.isPrivateDiscussion
          ? _newPrivateDiscussion
          : _newDiscussion;

  static FCDraft toDraft(FlarumDraft draft) => FCDraft(
        draftKey: keyOf(draft),
        sequence: 0,
        data: {
          'reply': draft.content,
          if (draft.title != null) 'title': draft.title,
          if (draft.tagIds.isNotEmpty) 'tags': draft.tagIds,
          if (draft.recipientIds.isNotEmpty) 'recipients': draft.recipientIds,
        },
        topicId: int.tryParse(draft.discussionId ?? ''),
        title: draft.title,
        updatedAt: draft.updatedAt,
      );

  /// The latest of the reader's drafts with [key], looking through their first [pages] pages.
  Future<FlarumDraft?> _find(String key, {int pages = 5}) async {
    var offset = 0;
    for (var i = 0; i < pages; i++) {
      final page = await _forum.api.drafts(offset: offset);
      for (final draft in page.items) {
        if (keyOf(draft) == key) return draft;
      }
      if (!page.hasMore) break;
      offset += page.items.length;
    }
    return null;
  }

  static List<String> _ids(Object? value) => [if (value is List) for (final id in value) '$id'];

  @override
  Future<FCSaveDraftResult> saveDraftAsync({
    required String draftKey,
    required Map<String, dynamic> data,
    int sequence = 0,
  }) async {
    try {
      final existing = await _find(draftKey);
      final reply = draftKey.startsWith(_replyPrefix);
      await _forum.api.saveDraft(
        id: existing?.id,
        title: reply ? null : data['title']?.toString(),
        content: (data['reply'] ?? '').toString(),
        discussionId: reply ? draftKey.substring(_replyPrefix.length) : null,
        tagIds: draftKey == _newDiscussion ? _ids(data['tags']) : const [],
        recipientIds: draftKey == _newPrivateDiscussion ? _ids(data['recipients']) : const [],
      );
      return FCSaveDraftResult(result: true, resultText: '', sequence: 0);
    } catch (e) {
      return FCSaveDraftResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCLoadDraftResult> loadDraftAsync(String draftKey) async {
    try {
      final draft = await _find(draftKey);
      return FCLoadDraftResult(result: true, resultText: '', draft: draft == null ? null : toDraft(draft));
    } catch (e) {
      return FCLoadDraftResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String draftKey, {int sequence = 0}) async {
    try {
      final draft = await _find(draftKey);
      if (draft != null) await _forum.api.deleteDraft(draft.id);
      return FCDeleteDraftResult(result: true, resultText: '');
    } catch (e) {
      return FCDeleteDraftResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async {
    if (!_forum.isSignedIn) return FCDraftListResult(result: false, resultText: 'Not signed in', total: 0, items: const []);
    try {
      const size = 20;
      final drafts = await _forum.api.drafts(offset: page * size, limit: size);
      return FCDraftListResult(
        result: true,
        resultText: '',
        total: drafts.total ?? drafts.items.length,
        items: [for (final draft in drafts.items) toDraft(draft)],
      );
    } catch (e) {
      return FCDraftListResult(result: false, resultText: describeFlarumError(e), total: 0, items: const []);
    }
  }
}
