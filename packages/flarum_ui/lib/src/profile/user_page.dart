import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/discourse_color.dart';
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
import '../media/image_viewer_page.dart';
import '../messages/dialog_page.dart';
import '../messages/dialogs_page.dart';
import '../private/private_discussions_page.dart';
import '../safety/ignore_actions.dart';
import '../safety/ignored_users.dart';
import '../tags/tag_label.dart' show flarumTagIcon;
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';
import '../navigation/web_links.dart';

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

  /// What they like (flarum/likes) and where they're mentioned (flarum/mentions), as the web's
  /// profile lists them.
  PostListModel? _likes;
  PostListModel? _mentions;
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
    for (final model in [_likes, _mentions]) {
      model
        ?..removeListener(_changed)
        ..dispose();
    }
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
      // Which extensions the forum runs (a Mentions tab needs flarum/mentions).
      try {
        await _forum.current();
      } catch (_) {
        // Without the forum's info, the tabs every forum has.
      }
      if (!mounted) return;
      setState(() {
        _user = user;
        _posts ??= PostListModel((offset) => _forum.api.userPosts(author, offset: offset))..addListener(_changed);
        _likes ??= PostListModel((offset) => _forum.api.likedPosts(user.id, offset: offset))..addListener(_changed);
        if (_forum.extensions.mentions) {
          _mentions ??= PostListModel((offset) => _forum.api.mentionedPosts(user.id, offset: offset))..addListener(_changed);
        }
        _discussions ??= DiscussionListModel(_forum, author: author)..addListener(_changed);
      });
      _posts!.refresh();
      _discussions!.refresh();
      _likes!.refresh();
      _mentions?.refresh();
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
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
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
                hint: describeError(context, _error!),
                onRetry: () {
                  setState(() => _error = null);
                  _load();
                },
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final tabs = [
      (
        l10n.posts,
        PostList(site: widget.site, model: _posts!, emptyMessage: l10n.noPostsYet, failedMessage: l10n.userLoadFailed),
      ),
      (l10n.discussionsTab, DiscussionListView(site: widget.site, list: _discussions!)),
      (l10n.likesTab, PostList(site: widget.site, model: _likes!, emptyMessage: l10n.noPostsYet, failedMessage: l10n.userLoadFailed)),
      if (_mentions case final mentions?)
        (l10n.mentionsTab, PostList(site: widget.site, model: mentions, emptyMessage: l10n.noPostsYet, failedMessage: l10n.userLoadFailed)),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.displayName),
          actions: [
            PopupMenuButton<VoidCallback>(
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              onSelected: (action) => action(),
              itemBuilder: (menu) => [
                PopupMenuItem(value: () => shareFrom(context, WebLinks.user(widget.site, user)), child: Text(l10n.share)),
                PopupMenuItem(value: () => copyLink(context, WebLinks.user(widget.site, user)), child: Text(l10n.copyLink)),
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
              delegate: _PinnedTabs(TabBar(
                isScrollable: tabs.length > 3,
                tabAlignment: tabs.length > 3 ? TabAlignment.start : null,
                tabs: [for (final (label, _) in tabs) Tab(text: label)],
              )),
            ),
          ],
          body: TabBarView(children: [for (final (_, view) in tabs) view]),
        ),
      ),
    );
  }
}

/// The web's user card: a band in the member's colour (the colour of their letter avatar; a quiet
/// band behind a picture, whose colour the web reads from the image), their avatar, which opens
/// large, their name, group badges, online or last seen, when they joined, and their best answers.
class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final FlarumUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = flarumL10n(context);
    final locale = Localizations.localeOf(context).toString();
    final joined = user.joinTime;
    final seen = user.lastSeenAt;
    final avatar = user.avatarUrl;
    final band = avatar == null ? flarumAvatarColor(user.displayName) : theme.colorScheme.surfaceContainer;
    final onBand = avatar == null
        ? (ThemeData.estimateBrightnessForColor(band) == Brightness.dark ? Colors.white : Colors.black87)
        : theme.colorScheme.onSurface;
    final online = seen != null && DateTime.now().difference(seen.toLocal()) < const Duration(minutes: 5);
    final info = [
      if (online) l10n.online else if (seen != null) l10n.lastSeen(formatTimeAgo(seen.toLocal(), context)),
      if (joined != null) l10n.profileJoined(DateFormat.yMMM(locale).format(joined.toLocal())),
      if (user.bestAnswerCount case final answers?) l10n.bestAnswerCount(answers),
    ];
    final groups = [for (final group in user.groups) if (!group.isHidden && group.nameSingular.isNotEmpty) group];
    return Container(
      color: band,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXL),
      child: Column(
        children: [
          FlarumAvatar(
            user: user,
            radius: 40,
            onTap: avatar == null ? null : () => ImageViewerPage.open(context, avatar, [avatar]),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(user.displayName, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(color: onBand)),
          if (user.displayName != user.username)
            Text('@${user.username}', style: theme.textTheme.bodyMedium?.copyWith(color: onBand.withValues(alpha: 0.8))),
          if (groups.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: DesignTokens.spacingXS,
              runSpacing: DesignTokens.spacingXS,
              children: [for (final group in groups) _GroupBadge(group: group)],
            ),
          ],
          if (info.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(info.join(' · '),
                textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: onBand.withValues(alpha: 0.85))),
          ],
          if (user.discussionCount != null && user.commentCount != null)
            Text(l10n.userStats(user.discussionCount!, user.commentCount!),
                textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: onBand.withValues(alpha: 0.85))),
          // Shown to them and to moderators (flarum/suspend).
          if (user.isSuspended)
            Text(
              user.isSuspendedIndefinitely
                  ? l10n.suspendedIndefinitely
                  : l10n.suspendedUntil(DateFormat.yMMMd(locale).format(user.suspendedUntil!.toLocal())),
              style: theme.textTheme.bodySmall?.copyWith(color: avatar == null ? onBand : theme.colorScheme.error),
            ),
        ],
      ),
    );
  }
}

/// A group's badge, as the web shows it on a profile: its icon and name on its colour.
class _GroupBadge extends StatelessWidget {
  const _GroupBadge({required this.group});

  final FlarumGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = group.color == null ? null : parseDiscourseHex(group.color!.trim());
    final background = color ?? colorScheme.secondaryContainer;
    final foreground = color == null
        ? colorScheme.onSecondaryContainer
        : (ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87);
    final icon = flarumTagIcon(group.icon);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(DesignTokens.radiusXS)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: foreground), const SizedBox(width: 4)],
          Text(group.nameSingular,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w600)),
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
