import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/search_text_field.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_tile.dart';
import '../thread/thread_page.dart';

/// Search: discussions most relevant first, each with the post that matches
/// best, which it opens at; and posts (2.0 searches posts; on 1.x each
/// matching discussion's best post stands in, see FlarumApi.searchPosts).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SearchPage(site: site)));

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _query = TextEditingController();
  String _searched = '';
  bool _loading = false;
  Object? _error;
  List<FlarumDiscussion> _discussions = const [];
  List<FlarumPost> _posts = const [];

  /// Answers to an older query are dropped when a newer one has been asked.
  int _generation = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String text) async {
    final query = text.trim();
    if (query.isEmpty || query == _searched) return;
    final generation = ++_generation;
    setState(() {
      _searched = query;
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _forum.api.discussions(query: query, sort: null, withRelevantPost: true),
        _forum.api.searchPosts(query),
      ]);
      if (!mounted || generation != _generation) return;
      setState(() {
        _discussions = (results[0] as FlarumPage<FlarumDiscussion>).items;
        _posts = (results[1] as FlarumPage<FlarumPost>).items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: SearchTextField(
            controller: _query,
            hintText: l10n.searchHint,
            onSearch: _search,
            autoSearch: true,
            minLength: 2,
            debounceDuration: const Duration(milliseconds: 400),
          ),
          bottom: TabBar(tabs: [Tab(text: l10n.discussionsTab), Tab(text: l10n.posts)]),
        ),
        body: TabBarView(children: [_discussionResults(l10n), _postResults(l10n)]),
      ),
    );
  }

  Widget? _state(FlarumLocalizations l10n, bool empty) {
    if (_searched.isEmpty) return const SizedBox.shrink();
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyStateView.error(
        message: l10n.searchFailedWithError(describeFlarumError(_error!)),
        onRetry: () {
          final query = _searched;
          _searched = '';
          _search(query);
        },
      );
    }
    if (empty) return EmptyStateView(icon: Icons.search_off, message: l10n.noResultsFor(_searched));
    return null;
  }

  Widget _discussionResults(FlarumLocalizations l10n) =>
      _state(l10n, _discussions.isEmpty) ??
      ListView.separated(
        itemCount: _discussions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final d = _discussions[i];
          final best = d.mostRelevantPost;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DiscussionTile(
                discussion: d,
                onTap: () => ThreadPage.open(context, widget.site, d.id, near: best?.number, title: d.title),
              ),
              if (best != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(68, 0, DesignTokens.spacingL, DesignTokens.spacingM),
                  child: Text(
                    plainText(best.contentHtml ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      );

  Widget _postResults(FlarumLocalizations l10n) =>
      _state(l10n, _posts.isEmpty) ??
      ListView.separated(
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final post = _posts[i];
          final created = post.createdAt;
          final discussion = post.discussionId;
          return ListTile(
            title: Text(post.discussionTitle ?? l10n.aDiscussion, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${post.author?.displayName ?? l10n.someone}: ${plainText(post.contentHtml ?? '')}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: created == null ? null : Text(formatTimeAgo(created.toLocal(), context)),
            onTap: discussion == null
                ? null
                : () => ThreadPage.open(context, widget.site, discussion, near: post.number, title: post.discussionTitle),
          );
        },
      );
}
