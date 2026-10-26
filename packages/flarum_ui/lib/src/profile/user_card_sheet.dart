import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/account_page.dart' show ProfileStats;
import '../compose/composers.dart';
import '../messages/dialog_page.dart';
import '../messages/dialogs_page.dart';
import '../private/private_discussions_page.dart';
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';
import 'user_page.dart' show GroupBadge;

/// A member's card from their avatar on a post, as the Discourse app (and Flarum's website) shows
/// one before the whole profile: who they are, their groups, when they joined and were last seen,
/// their numbers, then Profile and Message. A post brings only their name and picture; the rest
/// is read when the card opens.
Future<void> showUserCard(BuildContext context, SiteContext site, FlarumUser user, {required VoidCallback onOpenProfile}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => _UserCard(site: site, user: user, onOpenProfile: () {
        Navigator.of(sheet).pop();
        onOpenProfile();
      }),
    );

class _UserCard extends StatefulWidget {
  const _UserCard({required this.site, required this.user, required this.onOpenProfile});

  final SiteContext site;
  final FlarumUser user;
  final VoidCallback onOpenProfile;

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late FlarumUser _user = widget.user;

  @override
  void initState() {
    super.initState();
    _forum.api.userBySlug(widget.user.slug ?? widget.user.username).then((user) {
      if (mounted) setState(() => _user = user);
    }, onError: (_) {
      // The card shows what the post said.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = flarumL10n(context);
    final locale = Localizations.localeOf(context).toString();
    final user = _user;
    final seen = user.lastSeenAt;
    final joined = user.joinTime;
    final online = seen != null && DateTime.now().difference(seen.toLocal()) < const Duration(minutes: 5);
    final info = [
      if (online) l10n.online else if (seen != null) l10n.lastSeen(formatTimeAgo(seen.toLocal(), context)),
      if (joined != null) l10n.profileJoined(DateFormat.yMMM(locale).format(joined.toLocal())),
    ];
    final groups = [for (final group in user.groups) if (!group.isHidden && group.nameSingular.isNotEmpty) group];
    final own = user.id == _forum.info?.actor?.id;
    final canMessage = !own && canSendMessages(_forum);
    final canWrite = !own && canStartPrivateDiscussion(_forum) && !user.blocksPd;
    Future<void> message() async {
      Navigator.of(context).pop();
      if (canMessage) {
        await DialogPage.open(context, widget.site, to: user);
        return;
      }
      final discussion = await composePrivateDiscussion(context, widget.site, to: user);
      if (discussion != null && context.mounted) ThreadPage.open(context, widget.site, discussion.id, title: discussion.title);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              FlarumAvatar(user: user, radius: 32),
              const SizedBox(width: DesignTokens.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (user.displayName != user.username)
                      Text('@${user.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ]),
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
                Flexible(
                  child: Text(info.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ]),
            ],
            ProfileStats(user: user),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: widget.onOpenProfile, child: Text(l10n.profile))),
              if (canMessage || canWrite) ...[
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: message,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.message),
                  ),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}
