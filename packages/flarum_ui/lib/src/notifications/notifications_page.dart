import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/user_avatar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import 'notifications_model.dart';

/// The reader's notifications: who did what, where, and when, unread ones
/// highlighted. A tap marks one read and opens the post it's about.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.site});

  final SiteContext site;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final NotificationsModel _model = NotificationsModel(_forum)..addListener(_changed);

  @override
  void initState() {
    super.initState();
    if (_forum.isSignedIn) _model.refresh();
  }

  @override
  void dispose() {
    _model
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _open(FlarumNotification n) async {
    _model.markRead(n);
    final discussion = n.discussionId;
    if (discussion == null) return;
    await ThreadPage.open(context, widget.site, discussion, near: n.openAt, title: n.discussionTitle);
  }

  Future<void> _markAllRead() async {
    final l10n = flarumL10n(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _model.markAllRead();
    messenger.showSnackBar(
        SnackBar(content: Text(ok ? l10n.allNotificationsMarkedAsRead : l10n.failedToMarkNotificationsRead)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final signedIn = _forum.isSignedIn;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (signedIn && _model.items.any((n) => !n.isRead))
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllRead, onPressed: _markAllRead),
        ],
      ),
      body: !signedIn
          ? EmptyStateView(icon: Icons.notifications_none, message: l10n.notificationsSignIn)
          : RefreshIndicator(onRefresh: _model.refresh, child: _body(l10n)),
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    if (_model.items.isEmpty) {
      if (_model.error != null) {
        return EmptyStateView.error(
          message: l10n.notificationsLoadFailed,
          hint: describeFlarumError(_model.error!),
          onRetry: _model.refresh,
        );
      }
      if (_model.loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView.scrollable(icon: Icons.notifications_none, message: l10n.noNotificationsYet);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) _model.loadMore();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _model.items.length + (_model.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == _model.items.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          final n = _model.items[i];
          return NotificationTile(notification: n, onTap: () => _open(n));
        },
      ),
    );
  }
}

/// One notification: the person, the line, when; unread ones on a tinted row.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final FlarumNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final n = notification;
    final created = n.createdAt;
    return Material(
      color: n.isRead ? Colors.transparent : colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        onTap: onTap,
        leading: UserAvatar(username: n.fromUser?.username ?? '', iconUrl: n.fromUser?.avatarUrl, radius: 20),
        title: Text(
          message(n, flarumL10n(context)),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600),
        ),
        subtitle: created == null ? null : Text(formatTimeAgo(created.toLocal(), context)),
      ),
    );
  }

  /// [n]'s line, worded as the web words it.
  static String message(FlarumNotification n, FlarumLocalizations l10n) {
    final user = n.fromUser?.displayName ?? l10n.someone;
    final title = n.discussionTitle ?? l10n.aDiscussion;
    return switch (n.contentType) {
      'newPost' || 'newPostInTag' => l10n.notifNewPost(user, title),
      'postLiked' => l10n.notifPostLiked(user, title),
      'postReacted' => l10n.notifPostReacted(user, title),
      'postMentioned' => l10n.notifPostMentioned(user, title),
      'userMentioned' => l10n.notifUserMentioned(user, title),
      'groupMentioned' => l10n.notifGroupMentioned(user, title),
      'discussionRenamed' => l10n.notifRenamed(user, title),
      'discussionLocked' => l10n.notifLocked(user, title),
      'newDiscussionInTag' => l10n.notifNewDiscussion(user, title),
      'newDiscussionTag' => l10n.notifMovedToTag(user, title),
      'byobuPrivateDiscussionCreated' => l10n.notifPrivateCreated(user, title),
      'byobuPrivateDiscussionReplied' => l10n.notifPrivateReplied(user, title),
      'byobuPrivateDiscussionAdded' => l10n.notifPrivateAdded(user, title),
      'byobuRecipientRemoved' => l10n.notifPrivateRemoved(user, title),
      'byobuMadePublic' => l10n.notifMadePublic(user, title),
      'awardedBestAnswer' => l10n.notifBestAnswerAwarded(user, title),
      'bestAnswerInDiscussion' => l10n.notifBestAnswerChosen(user, title),
      'selectBestAnswer' => l10n.notifBestAnswerPending(title),
      'messageReceived' => l10n.notifMessage(user),
      'userSuspended' => l10n.notifSuspended,
      'userUnsuspended' => l10n.notifUnsuspended,
      'gdprExportAvailable' => l10n.notifExport,
      _ => l10n.notifOther,
    };
  }
}
