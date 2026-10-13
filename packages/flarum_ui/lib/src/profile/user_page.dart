import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/suspend_user_page.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import '../compose/composers.dart';
import '../home/post_list.dart';
import '../messages/dialog_page.dart';
import '../messages/dialogs_page.dart';
import '../private/private_discussions_page.dart';
import '../safety/ignore_actions.dart';
import '../safety/ignored_users.dart';
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';

/// A user's profile: who they are, when they joined and were last seen, and
/// what they wrote: their posts, newest first, and the discussions they
/// started.
///
/// Found by [slug], as the forum's `/u/{slug}` links name users: the username
/// by default, the user's id on forums that use the ID slug driver. Their
/// posts and discussions are then filtered as the forum's version wants
/// ([FlarumApi.authorKey]: the username on 1.x, the slug on 2.0).
class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.site, required this.slug});

  final SiteContext site;
  final String slug;

  static Future<void> open(BuildContext context, SiteContext site, String slug) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => UserPage(site: site, slug: slug)));

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final IgnoredUsers _ignored = IgnoredUsers.of(widget.site)..addListener(_changed);
  FlarumUser? _user;
  Object? _error;

  // Made once the user is found, from their username.
  PostListModel? _posts;
  DiscussionListModel? _discussions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _posts
      ?..removeListener(_changed)
      ..dispose();
    _discussions
      ?..removeListener(_changed)
      ..dispose();
    _ignored.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final user = await _forum.api.userBySlug(widget.slug);
      final author = await _forum.api.authorKey(user);
      if (!mounted) return;
      setState(() {
        _user = user;
        _posts ??= PostListModel((offset) => _forum.api.userPosts(author, offset: offset))..addListener(_changed);
        _discussions ??= DiscussionListModel(_forum, author: author)..addListener(_changed);
      });
      _posts!.refresh();
      _discussions!.refresh();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Whether the reader may start a private discussion with [user] (fof/byobu): not with
  /// themselves, nor with someone who takes none.
  bool _canWriteTo(FlarumUser user) =>
      canStartPrivateDiscussion(_forum) && user.id != _forum.info?.actor?.id && !user.blocksPd;

  /// Suspends [user] (flarum/suspend) with forum_kit's Suspend User page, or lifts their suspension.
  /// The reason chosen is what they're told, and what moderators see.
  Future<void> _suspend(FlarumUser user) async {
    DateTime? until;
    String? reason;
    if (!user.isSuspended) {
      final choice = await showSuspendUserPage(context);
      if (choice == null) return;
      until = choice.expires == 0
          ? FlarumUser.indefiniteSuspension
          : DateTime.fromMillisecondsSinceEpoch(choice.expires * 1000, isUtc: true);
      reason = choice.reason;
    }
    try {
      final saved = await _forum.api.suspend(user.id, until, reason: reason, message: reason);
      if (mounted) setState(() => _user = saved);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeFlarumError(e));
    }
  }

  /// Whether the reader may send [user] a direct message (flarum/messages, 2.0).
  bool _canMessage(FlarumUser user) => canSendMessages(_forum) && user.id != _forum.info?.actor?.id;

  Future<void> _writeTo(FlarumUser user) async {
    final discussion = await composePrivateDiscussion(context, widget.site, to: user);
    if (discussion != null && mounted) ThreadPage.open(context, widget.site, discussion.id, title: discussion.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final user = _user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.slug)),
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
        appBar: AppBar(
          title: Text(user.displayName),
          actions: [
            if (_ignored.canIgnore(user) || _canWriteTo(user) || _canMessage(user) || user.canSuspend)
              PopupMenuButton<VoidCallback>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  if (_canMessage(user))
                    PopupMenuItem(
                      value: () => DialogPage.open(context, widget.site, to: user),
                      child: Text(l10n.sendMessage),
                    ),
                  if (_canWriteTo(user))
                    PopupMenuItem(value: () => _writeTo(user), child: Text(l10n.startPrivateDiscussion)),
                  if (user.canSuspend)
                    PopupMenuItem(
                      value: () => _suspend(user),
                      child: Text(user.isSuspended ? l10n.unsuspend : kitL10n(context).suspendUser),
                    ),
                  if (_ignored.canIgnore(user))
                    PopupMenuItem(
                      value: () => toggleIgnore(context, widget.site, user),
                      child: Text(_ignored.isIgnored(user)
                          ? l10n.stopIgnoringUser(user.displayName)
                          : l10n.ignoreUser(user.displayName)),
                    ),
                ],
              ),
          ],
        ),
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
              PostList(site: widget.site, model: _posts!, emptyMessage: flarumL10n(context).noPostsYet, failedMessage: flarumL10n(context).userLoadFailed),
              DiscussionListView(site: widget.site, list: _discussions!),
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
          FlarumAvatar(user: user, radius: 32),
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
                // Shown to them and to moderators (flarum/suspend).
                if (user.isSuspended)
                  Text(
                    user.isSuspendedIndefinitely
                        ? l10n.suspendedIndefinitely
                        : l10n.suspendedUntil(DateFormat.yMMMd(locale).format(user.suspendedUntil!.toLocal())),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A user's comments, newest first, a page at a time.
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
