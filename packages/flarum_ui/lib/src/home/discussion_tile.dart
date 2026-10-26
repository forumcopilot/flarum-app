import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/unread_badge.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tag_label.dart';
import '../widgets/flarum_avatar.dart';
import '../search/highlight.dart';

/// A discussion in a list, laid out as the Discourse app's topic row (a Material 3 list item):
/// the starter's avatar, the title (full strength while there's something unread) with the unread
/// count, the opening words for a sticky one, its tags, then who replied last and when, the
/// replies, and its state ("Answered", "Locked", "Sticky"…) in a word.
class DiscussionTile extends StatelessWidget {
  const DiscussionTile(
      {super.key,
      required this.discussion,
      this.unread = 0,
      this.recipients = const [],
      this.onTap,
      this.highlight,
      this.excerpt,
      this.onLongPress,
      this.onTagTap,
      this.hiddenTagId,
      this.read = false});

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

  /// Read to the end by a signed-in reader: the title steps back, as visited ones do on the web.
  /// A guest's rows, and discussions the reader hasn't caught up with, keep full strength.
  final bool read;
  final VoidCallback? onTap;

  /// Opens a tag the row shows; null leaves the tags as labels.
  final ValueChanged<FlarumTag>? onTagTap;

  /// The tag whose page the list is on: the page already names it, so the row doesn't.
  final String? hiddenTagId;

  /// Secondary tags beyond this become "+N": a row is a glance, not an index.
  static const maxSecondaryTags = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final d = discussion;
    final title = Text.rich(
      TextSpan(children: [
        if (highlight case final query?) ...highlighted(d.title, query) else TextSpan(text: d.title),
      ]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: read ? DesignTokens.fontWeightNormal : DesignTokens.fontWeightMedium,
        color: read ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
      ),
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlarumAvatar(user: d.author),
            const SizedBox(width: DesignTokens.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      if (unread > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: DesignTokens.spacingS, top: 6),
                          child: UnreadBadge(count: unread, semanticLabel: l10n.unreadReplies(unread)),
                        ),
                    ],
                  ),
                  if (excerpt case final excerpt?)
                    Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
                      child: Text(excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ),
                  _Taxonomy(
                    tags: d.tags,
                    recipients: recipients,
                    hiddenTagId: hiddenTagId,
                    onTagTap: onTagTap,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
                    child: _MetaRow(discussion: d),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The row's tags (the primary ones, then up to [DiscussionTile.maxSecondaryTags] secondary ones
/// and "+N"), or who a private discussion is with.
class _Taxonomy extends StatelessWidget {
  const _Taxonomy({required this.tags, required this.recipients, this.hiddenTagId, this.onTagTap});

  final List<FlarumTag> tags;
  final List<FlarumUser> recipients;
  final String? hiddenTagId;
  final ValueChanged<FlarumTag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final ordered = tagsInWebOrder(tags).where((t) => t.id != hiddenTagId).toList();
    final primary = ordered.where((t) => t.isPrimary).toList();
    final secondary = ordered.where((t) => !t.isPrimary).toList();
    final shown = [...primary, ...secondary.take(DiscussionTile.maxSecondaryTags)];
    final more = secondary.length - DiscussionTile.maxSecondaryTags;
    if (shown.isEmpty && recipients.isEmpty) return const SizedBox(height: DesignTokens.spacingXS);
    final tap = onTagTap;
    return Wrap(
      spacing: DesignTokens.spacingS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (recipients.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: DesignTokens.iconSizeXS, color: muted),
                const SizedBox(width: DesignTokens.spacingXS),
                Flexible(
                  child: Text(
                    flarumL10n(context).privateWith(recipients.map((user) => user.displayName).join(', ')),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
          ),
        for (final tag in shown)
          TagLabel(tag: tag, parent: parentAmong(tag, tags), onTap: tap == null ? null : () => tap(tag)),
        if (more > 0) Text('+$more', style: theme.textTheme.labelMedium?.copyWith(color: muted)),
      ],
    );
  }
}

/// "bob replied 2 days ago", the replies, and the discussion's state, as the Discourse app's topic
/// row ends: the activity gives way to the counts beside it, and both to the state at the end.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.discussion});

  final FlarumDiscussion discussion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = flarumL10n(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.bodySmall?.copyWith(color: muted);
    final d = discussion;
    final replies = d.commentCount > 0 ? d.commentCount - 1 : 0;
    final replied = replies > 0 && d.lastPostedUser != null && d.lastPostedAt != null;
    final who = (replied ? d.lastPostedUser : d.author)?.displayName ?? l10n.someone;
    final when = replied ? d.lastPostedAt : d.createdAt;
    final activity = when == null
        ? who
        : (replied ? l10n.discussionReplied : l10n.discussionStarted)(who, formatTimeAgo(when.toLocal(), context));
    final status = discussionStatuses(context, d).firstOrNull;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(child: Text(activity, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
              if (replies > 0)
                Padding(
                  padding: const EdgeInsets.only(left: DesignTokens.spacingM),
                  child: Semantics(
                    label: l10n.replyCount(replies),
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: DesignTokens.iconSizeS, color: muted),
                        const SizedBox(width: DesignTokens.spacingXS),
                        Text('$replies', style: style),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (status != null) ...[
          const SizedBox(width: DesignTokens.spacingS),
          Icon(status.icon, size: DesignTokens.iconSizeS, color: status.color, semanticLabel: status.label),
          const SizedBox(width: DesignTokens.spacingXS),
          ExcludeSemantics(child: Text(status.label, maxLines: 1, style: style?.copyWith(color: status.color))),
        ],
      ],
    );
  }
}

/// A discussion's state: its icon, its name and its colour.
typedef DiscussionStatus = ({IconData icon, String label, Color color});

/// [d]'s states, the one that most changes what the reader should expect first: Hidden and
/// Awaiting approval (for moderators), Answered (fof/best-answer), Locked, Sticky, Poll, and the
/// reader Following it. The Discourse app's topic row ends with one, in a word; the discussion's
/// page shows them all. They used to be white icons on the web's coloured circles, ahead of the
/// title.
List<DiscussionStatus> discussionStatuses(BuildContext context, FlarumDiscussion d) {
  final l10n = flarumL10n(context);
  final muted = Theme.of(context).colorScheme.onSurfaceVariant;
  return [
    if (d.isHidden) (icon: Icons.delete_outline, label: l10n.badgeHidden, color: Theme.of(context).colorScheme.error),
    if (!d.isApproved) (icon: Icons.gavel, label: l10n.awaitingApproval, color: muted),
    if (d.hasBestAnswer) (icon: Icons.check_circle, label: l10n.answered, color: ForumColors.of(context).success),
    if (d.isLocked) (icon: Icons.lock_outline, label: l10n.badgeLocked, color: muted),
    if (d.isSticky) (icon: Icons.push_pin_outlined, label: l10n.badgeSticky, color: muted),
    if (d.hasPoll) (icon: Icons.poll_outlined, label: l10n.poll, color: muted),
    if (d.subscription == 'follow') (icon: Icons.star_outline, label: l10n.following, color: muted),
  ];
}
