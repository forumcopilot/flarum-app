import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_forum_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/models/results/fc_forum_result.dart';

import '../flarum_exception.dart';
import '../models/tag.dart';
import 'flarum_forum.dart';

/// The forum tree is Flarum's primary tags: top-level tags in the admin's
/// order, each with its child tags. Secondary tags are labels, not forums;
/// IFCTagProxy serves them.
class FlarumForumProxy implements IFCForumProxy {
  FlarumForumProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  Future<bool> _canFollowTags() async => (await _forum.currentExtensions()).followTags;

  @override
  Future<FCForumDataResult> getForumAsync(bool returnDescription, String forumId, bool forceRefresh) async {
    try {
      final tags = await _forum.tags(refresh: forceRefresh);
      final canFollow = await _canFollowTags();
      final forums = forumId.isEmpty
          ? _tree(tags, canFollow: canFollow, withDescription: returnDescription)
          : [
              for (final child in _childrenOf(forumId, tags))
                _toForum(child, canFollow: canFollow, withDescription: returnDescription),
            ];
      return FCForumDataResult(result: true, resultText: '', forums: forums);
    } catch (e) {
      return FCForumDataResult(result: false, resultText: describeFlarumError(e), forums: const []);
    }
  }

  /// Followed tags (fof/follow-tags), standing in for participation, as
  /// discourse_core does with watched categories.
  @override
  Future<FCParticipatedForumResult> getParticipatedForumAsync() async {
    try {
      final tags = await _forum.tags();
      final followed = tags.where((t) => t.subscription == 'follow' || t.subscription == 'lurk');
      return FCParticipatedForumResult(
        result: true,
        resultText: '',
        forums: [for (final tag in followed) _toForum(tag, canFollow: true)],
      );
    } catch (e) {
      return FCParticipatedForumResult(result: false, resultText: describeFlarumError(e), forums: const []);
    }
  }

  /// Flarum marks the whole forum read; [forumId] is ignored (config's markForum is false).
  @override
  Future<FCMarkAllAsReadResult> markAllAsRead(String forumId) async {
    try {
      final reader = (await _forum.current()).actor;
      if (reader == null) return FCMarkAllAsReadResult(result: false, resultText: 'Sign in to mark discussions read');
      await _forum.api.markAllAsRead(reader.id);
      return FCMarkAllAsReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkAllAsReadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCLoginForumResult> loginForum(String forumId, String password) async =>
      FCLoginForumResult(result: false, resultText: 'Flarum has no password-protected tags');

  /// Reads the forum's own links: `/d/{id}[-{slug}][/{number}]` and `/t/{slug}`.
  @override
  Future<FCIdByUrlResult> getIdByUrl(String url) async {
    try {
      final segments = _pathWithinForum(url);
      if (segments != null && segments.length >= 2 && segments[0] == 'd') {
        final discussionId = RegExp(r'^\d+').stringMatch(segments[1]);
        if (discussionId != null) {
          final number = segments.length >= 3 ? int.tryParse(segments[2]) : null;
          final postId = number == null ? null : await _forum.api.postIdByNumber(discussionId, number);
          return FCIdByUrlResult(result: true, resultText: '', topicId: discussionId, postId: postId);
        }
      }
      if (segments != null && segments.length >= 2 && segments[0] == 't') {
        final slug = Uri.decodeComponent(segments[1]);
        final tag = (await _forum.tags()).where((t) => t.slug == slug).firstOrNull;
        if (tag != null) return FCIdByUrlResult(result: true, resultText: '', forumId: tag.id);
      }
      return FCIdByUrlResult(result: false, resultText: 'Not a link to a discussion or tag on this forum');
    } catch (e) {
      return FCIdByUrlResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCUrlByIdResult> getUrlById(String mode, String id) async {
    final base = _forum.baseUrl;
    try {
      switch (mode) {
        case 'topic':
          return FCUrlByIdResult(result: true, resultText: '', url: '$base/d/$id');
        case 'post':
          final post = await _forum.api.post(id);
          return FCUrlByIdResult(result: true, resultText: '', url: '$base/d/${post.discussionId}/${post.number}');
        case 'forum':
          final tag = (await _forum.tags()).where((t) => t.id == id).firstOrNull;
          if (tag == null) return FCUrlByIdResult(result: false, resultText: 'No tag $id');
          return FCUrlByIdResult(result: true, resultText: '', url: '$base/t/${tag.slug}');
        default:
          return FCUrlByIdResult(result: false, resultText: 'Unsupported mode: $mode');
      }
    } catch (e) {
      return FCUrlByIdResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Flarum's statistics are for admins only (flarum/statistics), and 1.x
  /// lists carry no totals. Reported as unavailable rather than as zeros.
  @override
  Future<FCBoardStatResult> getBoardStatAsync() async =>
      FCBoardStatResult(result: false, resultText: 'Flarum shows forum statistics to admins only');

  @override
  Future<FCForumStatusResult> getForumStatusAsync(List<String> forumIds) async {
    try {
      final wanted = forumIds.toSet();
      final canFollow = await _canFollowTags();
      final tags = (await _forum.tags()).where((t) => wanted.contains(t.id));
      return FCForumStatusResult(
        result: true,
        resultText: '',
        forums: [for (final tag in tags) _toForum(tag, canFollow: canFollow)],
      );
    } catch (e) {
      return FCForumStatusResult(result: false, resultText: describeFlarumError(e), forums: const []);
    }
  }

  List<FCForum> _tree(List<FlarumTag> tags, {required bool canFollow, required bool withDescription}) {
    final roots = tags.where((t) => t.isPrimary && t.parentId == null).toList()..sort(_byPosition);
    return [
      for (final root in roots)
        _toForum(
          root,
          canFollow: canFollow,
          withDescription: withDescription,
          children: [
            for (final child in _childrenOf(root.id, tags))
              _toForum(child, canFollow: canFollow, withDescription: withDescription),
          ],
        ),
    ];
  }

  static List<FlarumTag> _childrenOf(String parentId, List<FlarumTag> tags) =>
      tags.where((t) => t.parentId == parentId).toList()..sort(_byPosition);

  static int _byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);

  static FCForum _toForum(
    FlarumTag tag, {
    required bool canFollow,
    bool withDescription = true,
    List<FCForum> children = const [],
  }) =>
      FCForum(
        id: tag.id,
        name: tag.name,
        description: withDescription ? tag.description : null,
        parentId: tag.parentId,
        slug: tag.slug,
        color: tag.color,
        isSubscribed: tag.subscription == 'follow' || tag.subscription == 'lurk',
        canSubscribe: canFollow,
        canPost: tag.canStartDiscussion,
        topicCount: tag.discussionCount,
        isSubForumContainer: children.isNotEmpty,
        childForums: children,
      );

  /// [url]'s path segments below the forum's own address, or null when it's another site.
  List<String>? _pathWithinForum(String url) {
    final link = Uri.tryParse(url);
    final base = Uri.parse(_forum.baseUrl);
    if (link == null || link.host != base.host) return null;
    final basePath = base.pathSegments.where((s) => s.isNotEmpty).toList();
    final path = link.pathSegments.where((s) => s.isNotEmpty).toList();
    if (path.length < basePath.length) return null;
    for (var i = 0; i < basePath.length; i++) {
      if (path[i] != basePath[i]) return null;
    }
    return path.sublist(basePath.length);
  }
}

/// A failure as a short message for an `FC*Result`'s resultText.
String describeFlarumError(Object error) => error is FlarumApiException ? error.message : '$error';
