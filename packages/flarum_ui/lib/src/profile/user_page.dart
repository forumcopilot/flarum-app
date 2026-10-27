import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/discourse_color.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/account_page.dart' show ProfileStats;
import '../account/edit_profile_page.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import '../safety/suspend_user_page.dart';
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
import '../tags/tag_label.dart' show flarumTagIcon, textOn;
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

  /// Suspends [user] (flarum/suspend), or lifts their suspension, with Flarum's Suspend page: how
  /// long, the reason for moderators and the message they're told.
  Future<void> _suspend(FlarumUser user) async {
    final choice = await showSuspendUserPage(context, user);
    if (choice == null) return;
    try {
      final saved = await _forum.api.suspend(user.id, choice.until, reason: choice.reason, message: choice.message);
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
    final own = user.id == _forum.info?.actor?.id;
    // Message is the button: a direct message where the forum has them, else a private discussion.
    final VoidCallback? message = _canMessage(user)
        ? () => DialogPage.open(context, widget.site, to: user)
        : _canWriteTo(user)
            ? () => _writeTo(user)
            : null;
    PopupMenuItem<VoidCallback> item(VoidCallback action, IconData icon, String label) => PopupMenuItem(
          value: action,
          child: Row(children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: DesignTokens.spacingM),
            Flexible(child: Text(label)),
          ]),
        );
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
                item(() => shareFrom(context, WebLinks.user(widget.site, user)), Icons.share_outlined, l10n.share),
                item(() => copyLink(context, WebLinks.user(widget.site, user)), Icons.link, l10n.copyLink),
                // The button writes the one kind; the other is here.
                if (_canMessage(user) && _canWriteTo(user))
                  item(() => _writeTo(user), Icons.forum_outlined, l10n.startPrivateDiscussion),
                if (user.canSuspend) item(() => _suspend(user), Icons.gavel, l10n.suspend),
                if (_ignored.canIgnore(user))
                  _ignored.isIgnored(user)
                      ? item(() => toggleIgnore(context, widget.site, user), Icons.person_outline,
                          l10n.stopIgnoringUser(user.displayName))
                      : item(() => toggleIgnore(context, widget.site, user), Icons.person_off_outlined,
                          l10n.ignoreUser(user.displayName)),
              ],
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: _UserHeader(
                user: user,
                onMessage: own ? null : message,
                onEditProfile: own
                    ? () async {
                        await EditProfilePage.open(context, widget.site);
                        if (mounted) _load();
                      }
                    : null,
              ),
            ),
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

/// A member's profile head, as the Discourse app's: a band of their colour (the colour of their
/// letter avatar, as the web's card has it; a quiet band behind a picture) with their avatar over
/// its edge, which opens large; then their name, group badges, whether they're online and when
/// they joined, and Message (or Edit Profile on the reader's own), then their numbers. It used to
/// be the web's card, everything centred on the band.
class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user, this.onMessage, this.onEditProfile});

  final FlarumUser user;

  /// Writes to them: a direct message (flarum/messages) or a private discussion (byobu).
  final VoidCallback? onMessage;

  /// The reader's own profile: its page on the forum, where it's edited.
  final VoidCallback? onEditProfile;

  static const _band = 88.0;
  static const _avatar = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final locale = Localizations.localeOf(context).toString();
    final joined = user.joinTime;
    final seen = user.lastSeenAt;
    final avatar = user.avatarUrl;
    final dark = theme.brightness == Brightness.dark;
    final band = avatar == null
        ? Color.lerp(colorScheme.surface, flarumAvatarColor(user.displayName), dark ? 0.45 : 0.6)!
        : colorScheme.surfaceContainerHigh;
    final online = seen != null && DateTime.now().difference(seen.toLocal()) < const Duration(minutes: 5);
    final info = [
      if (online) l10n.online else if (seen != null) l10n.lastSeen(formatTimeAgo(seen.toLocal(), context)),
      if (joined != null) l10n.profileJoined(DateFormat.yMMM(locale).format(joined.toLocal())),
    ];
    final groups = [for (final group in user.groups) if (!group.isHidden && group.nameSingular.isNotEmpty) group];
    final muted = theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _band + _avatar,
          child: Stack(
            children: [
              Positioned(left: 0, right: 0, top: 0, height: _band, child: ColoredBox(color: band)),
              Positioned(
                left: DesignTokens.spacingL,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle),
                  child: FlarumAvatar(
                    user: user,
                    radius: _avatar,
                    onTap: avatar == null ? null : () => ImageViewerPage.open(context, avatar, [avatar]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingL, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              if (user.displayName != user.username) Text('@${user.username}', style: muted),
              if (groups.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingS),
                Wrap(
                  spacing: DesignTokens.spacingXS,
                  runSpacing: DesignTokens.spacingXS,
                  children: [for (final group in groups) GroupBadge(group: group)],
                ),
              ],
              if (info.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingS),
                Row(children: [
                  if (online) ...[
                    Icon(Icons.circle, size: 10, color: ForumColors.of(context).success),
                    const SizedBox(width: DesignTokens.spacingXS),
                  ],
                  Flexible(child: Text(info.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))),
                ]),
              ],
              // Shown to them and to moderators (flarum/suspend).
              if (user.isSuspended) ...[
                const SizedBox(height: DesignTokens.spacingS),
                Chip(
                  avatar: Icon(Icons.gavel, size: 16, color: colorScheme.onErrorContainer),
                  label: Text(user.isSuspendedIndefinitely
                      ? l10n.suspendedIndefinitely
                      : l10n.suspendedUntil(DateFormat.yMMMd(locale).format(user.suspendedUntil!.toLocal()))),
                  backgroundColor: colorScheme.errorContainer,
                  labelStyle: TextStyle(color: colorScheme.onErrorContainer),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
              ],
              if (onMessage != null || onEditProfile != null) ...[
                const SizedBox(height: DesignTokens.spacingM),
                if (onEditProfile case final edit?)
                  OutlinedButton.icon(onPressed: edit, icon: const Icon(Icons.edit_outlined), label: Text(l10n.editProfile))
                else
                  FilledButton.tonalIcon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.message),
                  ),
              ],
            ],
          ),
        ),
        ProfileStats(user: user),
      ],
    );
  }
}

/// A group's badge, as the web shows it on a profile: its icon and name on its colour.
class GroupBadge extends StatelessWidget {
  const GroupBadge({super.key, required this.group});

  final FlarumGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = group.color == null ? null : parseDiscourseHex(group.color!.trim());
    final background = color ?? colorScheme.secondaryContainer;
    final foreground = color == null
        ? colorScheme.onSecondaryContainer
        : textOn(color);
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
