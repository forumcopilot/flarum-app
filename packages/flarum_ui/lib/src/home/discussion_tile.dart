import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import 'package:forum_kit/utils/time_utils.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tag_label.dart';
import '../widgets/flarum_avatar.dart';
import '../search/highlight.dart';

/// A discussion in a list, as the web's discussion row: the starter's
/// avatar, the title (bold while there's something unread), its tags, who
/// replied last and when, and how many replies (or unread ones).
class DiscussionTile extends StatelessWidget {
  const DiscussionTile(
      {super.key,
      required this.discussion,
      this.unread = 0,
      this.recipients = const [],
      this.onTap,
      this.highlight,
      this.excerpt,
      this.onLongPress});

  final FlarumDiscussion discussion;

  /// Who a private discussion is with, shown where the web shows its tags.
  final List<FlarumUser> recipients;

  /// The first post's opening words, under the row as flarum/sticky shows a sticky discussion's.
  final String? excerpt;

  /// Its controls (Mark as Read, Follow, Bookmark, Share), as the web's row menu.
  final VoidCallback? onLongPress;

  /// A search: its words are bold in the title.
  final String? highlight;

  /// Posts the reader hasn't read; zero for a guest.
  final int unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final d = discussion;
    final replies = d.commentCount > 0 ? d.commentCount - 1 : 0;
    final replied = replies > 0 && d.lastPostedUser != null && d.lastPostedAt != null;
    final who = (replied ? d.lastPostedUser : d.author)?.displayName ?? l10n.someone;
    final when = replied ? d.lastPostedAt : d.createdAt;
    final meta = when == null
        ? who
        : (replied ? l10n.discussionReplied : l10n.discussionStarted)(who, formatTimeAgo(when.toLocal(), context));
    final muted = colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlarumAvatar(user: d.author),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The web's discussion badges, in its colours: what a reader scans the list for.
                  Text.rich(
                    TextSpan(children: [
                      for (final badge in discussionBadges(context, d))
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(padding: const EdgeInsets.only(right: 4), child: badge),
                        ),
                      if (highlight case final query?) ...highlighted(d.title, query) else TextSpan(text: d.title),
                    ]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                      color: unread > 0 ? colorScheme.onSurface : muted,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingXS),
                  Wrap(
                    spacing: DesignTokens.spacingS,
                    runSpacing: DesignTokens.spacingXS,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final tag in tagsInWebOrder(d.tags)) TagLabel(tag: tag),
                      if (recipients.isNotEmpty)
                        Text(l10n.privateWith(recipients.map((user) => user.displayName).join(', ')),
                            style: theme.textTheme.bodySmall?.copyWith(color: muted, fontWeight: FontWeight.w600)),
                      Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    ],
                  ),
                  if (excerpt case final excerpt?) ...[
                    const SizedBox(height: DesignTokens.spacingXS),
                    Text(excerpt, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
            _Count(replies: replies, unread: unread),
          ],
        ),
      ),
    );
  }

}

/// The replies count, or the unread count, highlighted, while there are some.
class _Count extends StatelessWidget {
  const _Count({required this.replies, required this.unread});

  final int replies;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (unread > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: 2),
        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(12)),
        child: Text('$unread', style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary)),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chat_bubble_outline, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: DesignTokens.spacingXS),
        Text('$replies', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

/// [d]'s badges as the web draws them by a discussion, in its colours: Hidden and Awaiting
/// approval (for moderators), the red Sticky pin, Locked, byobu's private map, a Following star,
/// the green Answered check, Poll.
List<Widget> discussionBadges(BuildContext context, FlarumDiscussion d) {
  final l10n = flarumL10n(context);
  return [
    if (d.isHidden) discussionBadge(Icons.delete_outline, const Color(0xFF888888), l10n.badgeHidden),
    if (!d.isApproved) discussionBadge(Icons.gavel, const Color(0xFF888888), l10n.awaitingApproval),
    if (d.isSticky) discussionBadge(Icons.push_pin, const Color(0xFFD13E32), l10n.badgeSticky),
    if (d.isLocked) discussionBadge(Icons.lock, const Color(0xFF888888), l10n.badgeLocked),
    if (d.isPrivate) discussionBadge(Icons.map_outlined, const Color(0xFF4D698E), l10n.privateDiscussion),
    if (d.subscription == 'follow') discussionBadge(Icons.star, const Color(0xFFFFA000), l10n.following),
    if (d.hasBestAnswer) discussionBadge(Icons.check, ForumColors.of(context).success, l10n.answered),
    if (d.hasPoll) discussionBadge(Icons.poll_outlined, const Color(0xFF4D698E), l10n.poll),
  ];
}

/// A badge as the web draws one: a white icon on a round colour, named for screen readers.
Widget discussionBadge(IconData icon, Color color, String label, {double size = 18}) => Tooltip(
      message: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.6, color: Colors.white, semanticLabel: label),
      ),
    );
