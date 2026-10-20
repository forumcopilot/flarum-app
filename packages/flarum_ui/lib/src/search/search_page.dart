import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/search_text_field.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_tile.dart';
import '../profile/user_page.dart';
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';
import 'highlight.dart';

/// Search, as the web's: discussions most relevant first, each with the post that matches best
/// (opened at it), its words in bold in their context; posts on 2.0 (1.x can't search posts); and
/// users. Each list loads more as it's scrolled. With nothing typed, the searches made before.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SearchPage(site: site)));

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// One tab's results, a page at a time.
class _Results<T> {
  final List<T> items = [];
  bool hasMore = false;
  bool loading = false;
  Object? error;
}

class _SearchPageState extends State<SearchPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _query = TextEditingController();
  final _focus = FocusNode();
  String _searched = '';
  var _discussions = _Results<FlarumDiscussion>();
  var _posts = _Results<FlarumPost>();
  var _users = _Results<FlarumUser>();
  List<String> _recent = const [];

  /// Answers to an older query are dropped when a newer one has been asked.
  int _generation = 0;

  /// 1.x has no post search: its Posts tab would repeat the discussions' best posts.
  bool get _postsTab => _forum.info?.version != FlarumVersion.v1;

  String get _recentKey => 'flarum_ui.recent_searches.${widget.site.site.pluginUrl}';

  @override
  void initState() {
    super.initState();
    _readRecent();
    _forum.current().then((_) => mounted ? setState(() {}) : null, onError: (_) {});
    // Ready to type, as the web's search field is once opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _readRecent() async {
    try {
      final recent = (await SharedPreferences.getInstance()).getStringList(_recentKey) ?? const [];
      if (mounted) setState(() => _recent = recent);
    } catch (_) {
      // No history, then.
    }
  }

  Future<void> _remember(String query) async {
    final recent = [query, ..._recent.where((q) => q.toLowerCase() != query.toLowerCase())].take(8).toList();
    setState(() => _recent = recent);
    try {
      await (await SharedPreferences.getInstance()).setStringList(_recentKey, recent);
    } catch (_) {
      // Kept for this run.
    }
  }

  Future<void> _forgetRecent() async {
    setState(() => _recent = const []);
    try {
      await (await SharedPreferences.getInstance()).remove(_recentKey);
    } catch (_) {
      // Gone for this run.
    }
  }

  /// Clearing the field clears the results too, back to the recent searches.
  void _clear() {
    _generation++;
    setState(() {
      _searched = '';
      _discussions = _Results();
      _posts = _Results();
      _users = _Results();
    });
  }

  Future<void> _search(String text) async {
    final query = text.trim();
    if (query.isEmpty) return _clear();
    if (query == _searched) return;
    _generation++;
    setState(() {
      _searched = query;
      _discussions = _Results();
      _posts = _Results();
      _users = _Results();
    });
    _remember(query);
    await Future.wait([_more(_discussions), if (_postsTab) _more(_posts), _more(_users)]);
  }

  /// The next page of [results] for the current query.
  Future<void> _more<T>(_Results<T> results) async {
    if (results.loading || _searched.isEmpty) return;
    final query = _searched;
    final generation = _generation;
    setState(() {
      results.loading = true;
      results.error = null;
    });
    try {
      final offset = results.items.length;
      final FlarumPage<Object> page = switch (results) {
        _Results<FlarumDiscussion>() =>
          await _forum.api.discussions(query: query, sort: null, withRelevantPost: true, offset: offset),
        _Results<FlarumPost>() => await _forum.api.searchPosts(query, offset: offset),
        _ => await _forum.api.searchUsers(query, offset: offset),
      };
      if (!mounted || generation != _generation) return;
      setState(() {
        results.items.addAll(page.items.cast<T>());
        results.hasMore = page.hasMore;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() => results.error = e);
    } finally {
      if (mounted && generation == _generation) setState(() => results.loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final tabs = [
      (l10n.discussionsTab, _discussionResults(l10n)),
      if (_postsTab) (l10n.posts, _postResults(l10n)),
      (l10n.usersTab, _userResults(l10n)),
    ];
    // The tab count changes once the forum's version is known (no Posts on 1.x): the controller
    // follows it in place, so the field and its pending search stay.
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: SearchTextField(
            controller: _query,
            focusNode: _focus,
            hintText: l10n.searchHint,
            onSearch: _search,
            onClear: _clear,
            autoSearch: true,
            minLength: 2,
            debounceDuration: const Duration(milliseconds: 400),
          ),
          bottom: _searched.isEmpty ? null : TabBar(tabs: [for (final (label, _) in tabs) Tab(text: label)]),
        ),
        body: _searched.isEmpty ? _recentSearches(l10n) : TabBarView(children: [for (final (_, view) in tabs) view]),
      ),
    );
  }

  Widget _recentSearches(FlarumLocalizations l10n) {
    if (_recent.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingS, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l10n.recentSearches, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              TextButton(onPressed: _forgetRecent, child: Text(l10n.clearRecentSearches)),
            ],
          ),
        ),
        for (final query in _recent)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () {
              _query.text = query;
              _search(query);
            },
          ),
      ],
    );
  }

  /// [results]' list, loading more near its end; or what to say instead of it.
  Widget _list<T>(
    FlarumLocalizations l10n,
    _Results<T> results,
    Widget Function(BuildContext, T) row, {
    Widget? whenForbidden,
  }) {
    final error = results.error;
    if (results.items.isEmpty) {
      if (results.loading) return const Center(child: CircularProgressIndicator());
      if (error is FlarumApiException && error.isForbidden && whenForbidden != null) return whenForbidden;
      if (error != null) {
        return EmptyStateView.error(
          message: l10n.searchFailedWithError(describeError(context, error)),
          onRetry: () => _more(results),
        );
      }
      return EmptyStateView(icon: Icons.search_off, message: l10n.noResultsFor(_searched));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400 && results.hasMore && results.error == null) _more(results);
        return false;
      },
      child: ListView.separated(
        itemCount: results.items.length + (results.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i < results.items.length) return row(context, results.items[i]);
          return Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Center(
              child: results.error != null && !results.loading
                  ? TextButton.icon(onPressed: () => _more(results), icon: const Icon(Icons.refresh), label: Text(l10n.retry))
                  : const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        },
      ),
    );
  }

  /// [html]'s words around the first match, the query's words in bold.
  Widget _excerpt(BuildContext context, String html, {String? before}) {
    final theme = Theme.of(context);
    final text = excerptAround(plainText(html), _searched);
    return Text.rich(
      TextSpan(children: [
        if (before != null) TextSpan(text: before, style: const TextStyle(fontWeight: FontWeight.w600)),
        ...highlighted(text, _searched, bold: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
      ]),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  Widget _discussionResults(FlarumLocalizations l10n) => _list(l10n, _discussions, (context, d) {
        final best = d.mostRelevantPost;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiscussionTile(
              discussion: d,
              highlight: _searched,
              onTap: () => ThreadPage.open(context, widget.site, d.id, near: best?.number, title: d.title),
            ),
            if (best != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(68, 0, DesignTokens.spacingL, DesignTokens.spacingM),
                child: _excerpt(context, best.contentHtml ?? ''),
              ),
          ],
        );
      });

  Widget _postResults(FlarumLocalizations l10n) => _list(l10n, _posts, (context, post) {
        final created = post.createdAt;
        final discussion = post.discussionId;
        return ListTile(
          title: Text(post.discussionTitle ?? l10n.aDiscussion, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: _excerpt(context, post.contentHtml ?? '', before: '${post.author?.displayName ?? l10n.someone}: '),
          trailing: created == null ? null : Text(formatTimeAgo(created.toLocal(), context)),
          onTap: discussion == null
              ? null
              : () => ThreadPage.open(context, widget.site, discussion, near: post.number, title: post.discussionTitle),
        );
      });

  Widget _userResults(FlarumLocalizations l10n) => _list(
        l10n,
        _users,
        (context, user) => ListTile(
          leading: FlarumAvatar(user: user),
          title: Text.rich(TextSpan(children: highlighted(user.displayName, _searched))),
          subtitle: Text('@${user.username}'),
          onTap: () => UserPage.open(context, widget.site, user.slug ?? user.username),
        ),
        whenForbidden: EmptyStateView(icon: Icons.person_search, message: l10n.memberSearchNotAllowed),
      );
}
