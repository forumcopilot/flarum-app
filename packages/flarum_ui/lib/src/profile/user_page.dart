import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/user_avatar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import '../thread/thread_page.dart';

/// A user's profile: who they are, when they joined and were last seen, and
/// what they wrote: their posts, newest first, and the discussions they
/// started.
class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.site, required this.username});

  final SiteContext site;
  final String username;

  static Future<void> open(BuildContext context, SiteContext site, String username) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => UserPage(site: site, username: username)));

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  FlarumUser? _user;
  Object? _error;

  late final _posts = _UserPostsModel(_forum, widget.username)..addListener(_changed);
  late final _discussions = DiscussionListModel(_forum, author: widget.username)..addListener(_changed);

  @override
  void initState() {
    super.initState();
    _load();
    _posts.refresh();
    _discussions.refresh();
  }

  @override
  void dispose() {
    _posts
      ..removeListener(_changed)
      ..dispose();
    _discussions
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final user = await _forum.api.userByUsername(widget.username);
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final user = _user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.username)),
        body: _error != null
            ? EmptyStateView.error(
                message: l10n.userLoadFailed,
                hint: describeFlarumError(_error!),
                onRetry: () {
                  setState(() => _error = null);
                  _load();
                },
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(user.displayName)),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _UserHeader(user: user)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedTabs(TabBar(tabs: [Tab(text: l10n.posts), Tab(text: l10n.discussionsTab)])),
            ),
          ],
          body: TabBarView(
            children: [
              _PostsList(site: widget.site, model: _posts),
              DiscussionListView(site: widget.site, list: _discussions),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final FlarumUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l10n = flarumL10n(context);
    final locale = Localizations.localeOf(context).toString();
    final joined = user.joinTime;
    final seen = user.lastSeenAt;
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      child: Row(
        children: [
          UserAvatar(username: user.username, iconUrl: user.avatarUrl, radius: 32),
          const SizedBox(width: DesignTokens.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${user.username}', style: theme.textTheme.titleMedium),
                if (joined != null)
                  Text(l10n.profileJoined(DateFormat.yMMM(locale).format(joined.toLocal())),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                if (seen != null)
                  Text(l10n.lastSeen(formatTimeAgo(seen.toLocal(), context)),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                if (user.discussionCount != null && user.commentCount != null)
                  Text(l10n.userStats(user.discussionCount!, user.commentCount!),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A user's comments, newest first, a page at a time.
class _UserPostsModel extends ChangeNotifier {
  _UserPostsModel(this.forum, this.username);

  final FlarumForum forum;
  final String username;
  final List<FlarumPost> items = [];
  bool hasMore = true;
  bool loading = false;
  Object? error;
  bool _disposed = false;

  Future<void> refresh() => _load(reset: true);

  Future<void> loadMore() async {
    if (loading || !hasMore || error != null) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    loading = true;
    if (reset) error = null;
    _notify();
    try {
      final page = await forum.api.userPosts(username, offset: reset ? 0 : items.length);
      if (reset) items.clear();
      items.addAll(page.items);
      hasMore = page.hasMore;
      error = null;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _PostsList extends StatelessWidget {
  const _PostsList({required this.site, required this.model});

  final SiteContext site;
  final _UserPostsModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    if (model.items.isEmpty) {
      if (model.error != null) {
        return EmptyStateView.error(
            message: l10n.userLoadFailed, hint: describeFlarumError(model.error!), onRetry: model.refresh);
      }
      if (model.loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView(icon: Icons.chat_bubble_outline, message: l10n.noPostsYet);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) model.loadMore();
        return false;
      },
      child: ListView.separated(
        itemCount: model.items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final post = model.items[i];
          final created = post.createdAt;
          final discussion = post.discussionId;
          return ListTile(
            title: Text(post.discussionTitle ?? l10n.aDiscussion, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(plainText(post.contentHtml ?? ''), maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: created == null
                ? null
                : Text(formatTimeAgo(created.toLocal(), context),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            onTap: discussion == null
                ? null
                : () => ThreadPage.open(context, site, discussion, near: post.number, title: post.discussionTitle),
          );
        },
      ),
    );
  }
}

/// The profile's tabs, kept under the app bar once the header scrolls away.
class _PinnedTabs extends SliverPersistentHeaderDelegate {
  _PinnedTabs(this.tabs);

  final TabBar tabs;

  @override
  double get minExtent => tabs.preferredSize.height;

  @override
  double get maxExtent => tabs.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(color: Theme.of(context).colorScheme.surface, child: tabs);

  @override
  bool shouldRebuild(_PinnedTabs oldDelegate) => oldDelegate.tabs != tabs;
}
