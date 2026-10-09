import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_tag_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_tag.dart';
import 'package:forumcopilot_sdk/models/results/fc_tag_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';

import '../models/tag.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_topic_proxy.dart';

/// Every tag the reader can see, primary and secondary, addressed by slug
/// ([FCTag.name]); [FCTag.text] is the tag's display name.
///
/// Flarum sends the whole tag list at once, so searching it needs no request.
class FlarumTagProxy implements IFCTagProxy {
  FlarumTagProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// Most used first, then by name. Flarum has no private-message-only tags,
  /// so [includePmOnly] changes nothing.
  @override
  Future<FCTagListResult> getAllTagsAsync({bool includePmOnly = false}) async {
    try {
      final tags = [...await _forum.tags()]..sort(_byUse);
      return FCTagListResult(result: true, resultText: '', total: tags.length, items: [for (final tag in tags) toTag(tag)]);
    } catch (e) {
      return FCTagListResult(result: false, resultText: describeFlarumError(e), total: 0, items: const []);
    }
  }

  /// Slugs of the tags whose name or slug starts with [query], then those that
  /// contain it, each most used first. An empty query gives the most used.
  @override
  Future<FCTagSearchResult> searchTagsAsync(String query, {int limit = 10}) async {
    try {
      final q = query.trim().toLowerCase();
      bool starts(FlarumTag t) => t.name.toLowerCase().startsWith(q) || t.slug.startsWith(q);
      bool contains(FlarumTag t) => t.name.toLowerCase().contains(q) || t.slug.contains(q);
      final tags = [...await _forum.tags()]..sort(_byUse);
      final matches = [
        ...tags.where(starts),
        ...tags.where((t) => !starts(t) && contains(t)),
      ];
      return FCTagSearchResult(result: true, resultText: '', names: [for (final tag in matches.take(limit)) tag.slug]);
    } catch (e) {
      return FCTagSearchResult(result: false, resultText: describeFlarumError(e), names: const []);
    }
  }

  /// The tag's latest discussions, 20 to a [page] counted from 0.
  @override
  Future<FCTopicDataResult> getTopicsByTagAsync(String tagName, {int page = 0}) async {
    try {
      final tag = (await _forum.tags()).where((t) => t.slug == tagName).firstOrNull;
      if (tag == null) return FCTopicDataResult(result: false, resultText: 'This forum has no tag $tagName', totalTopicNum: 0);
      final start = (page < 0 ? 0 : page) * _pageSize;
      return FlarumTopicProxy(siteContext).getTopicAsync(tag.id, start, start + _pageSize - 1);
    } catch (e) {
      return FCTopicDataResult(result: false, resultText: describeFlarumError(e), totalTopicNum: 0);
    }
  }

  static const _pageSize = 20;

  static FCTag toTag(FlarumTag tag) => FCTag(
        id: int.tryParse(tag.id),
        name: tag.slug,
        text: tag.name,
        count: tag.discussionCount,
        description: tag.description,
      );

  static int _byUse(FlarumTag a, FlarumTag b) {
    final byCount = b.discussionCount.compareTo(a.discussionCount);
    return byCount != 0 ? byCount : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
