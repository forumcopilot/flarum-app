import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/user_avatar.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tag_label.dart';

/// A discussion in a list, as the web's discussion row: the starter's
/// avatar, the title (bold while there's something unread), its tags, who
/// replied last and when, and how many replies (or unread ones).
class DiscussionTile extends StatelessWidget {
  const DiscussionTile({super.key, required this.discussion, this.unread = 0, this.onTap});

  final FlarumDiscussion discussion;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(username: d.author?.username ?? '', iconUrl: d.author?.avatarUrl, radius: 20),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: [
                      if (d.isSticky) _glyph(Icons.push_pin, muted),
                      if (d.isLocked) _glyph(Icons.lock, muted),
                      TextSpan(text: d.title),
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
                      for (final tag in _shownTags(d.tags)) TagLabel(tag: tag),
                      Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    ],
                  ),
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

  static InlineSpan _glyph(IconData icon, Color color) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(padding: const EdgeInsets.only(right: 4), child: Icon(icon, size: 16, color: color)),
      );

  /// The tags as the web lists them on a row: the primary ones, a child after
  /// its parent, then the secondary ones.
  static List<FlarumTag> _shownTags(List<FlarumTag> tags) => [
        ...tags.where((t) => t.isPrimary && !t.isChild),
        ...tags.where((t) => t.isPrimary && t.isChild),
        ...tags.where((t) => !t.isPrimary),
      ];
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
