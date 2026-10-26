import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/emoji_shortcodes.dart';
import 'package:forum_kit/views/widgets/post_action_button.dart';
import 'package:forum_kit/views/widgets/sheet_title.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';

/// A reaction's glyph: its emoji, from the shortcode it's named by; else its name.
String reactionGlyph(FlarumReaction reaction) =>
    (reaction.type == 'emoji' ? discourseEmojiChar(reaction.identifier) : null) ??
    reaction.display ??
    reaction.identifier;

/// The row under a post, as the Discourse app's: on the left, how many replied to it (which lists
/// them); on the right, its likes and reactions in one count (which shows who), Like (a long press
/// offers the forum's reactions, fof/reactions), the reader's own reaction, Bookmark and Reply.
///
/// The buttons are icons in 48dp targets, as Material 3's icon buttons are. They used to be text
/// buttons on the left ("Like" turned "Unlike"), the reactions separate chips with a button of
/// their own, and who liked the post a line of text under it.
class PostActionsRow extends StatelessWidget {
  const PostActionsRow({
    super.key,
    required this.post,
    this.readerId,
    this.reactions = const [],
    this.onLike,
    this.onReact,
    this.onBookmark,
    this.onReply,
    this.onShowReplies,
    this.repliesLabel,
    this.likesLabel,
    this.onOpenUser,
  });

  final FlarumPost post;

  /// The signed-in reader's id: whether they liked the post.
  final String? readerId;

  /// The reactions the forum offers (fof/reactions).
  final List<FlarumReaction> reactions;
  final VoidCallback? onLike;
  final void Function(FlarumReaction reaction)? onReact;
  final VoidCallback? onBookmark;
  final VoidCallback? onReply;

  /// Lists the replies to the post; null when there are none to list.
  final VoidCallback? onShowReplies;

  /// What a screen reader says for the replies ("bob and alice replied to this.").
  final String? repliesLabel;

  /// Who likes the post, as flarum/likes words it ("You and Jamie like this."), over the likers in
  /// the sheet of who reacted.
  final String? likesLabel;

  /// Opens a liker's profile, from the sheet of who liked the post.
  final void Function(FlarumUser user)? onOpenUser;

  /// The post's reactions with any count, the most used first.
  List<(FlarumReaction, int)> get _used => [
        for (final r in reactions)
          if ((post.reactionCounts[r.id] ?? 0) > 0) (r, post.reactionCounts[r.id]!),
      ]..sort((a, b) => b.$2.compareTo(a.$2));

  FlarumReaction? get _mine => reactions.where((r) => r.id == post.userReactionId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final used = _used;
    final total = post.likesCount + used.fold<int>(0, (sum, r) => sum + r.$2);
    final mine = _mine;
    final react = onReact != null && reactions.isNotEmpty;
    final liked = post.isLikedBy(readerId);
    final replies = post.mentionedByCount;

    final actions = <Widget>[
      if (total > 0)
        _ReactionSummary(
          glyphs: [for (final (r, _) in used.take(3)) reactionGlyph(r)],
          total: total,
          onTap: () => _showWhoReacted(context),
        ),
      if (onLike != null)
        PostActionButton(
          icon: Icons.thumb_up_outlined,
          activeIcon: Icons.thumb_up,
          active: liked,
          onTap: onLike,
          onLongPress: react ? () => _pickReaction(context) : null,
          semanticLabel: liked ? l10n.unlike : l10n.like,
          semanticHint: react ? l10n.holdForReactions : null,
        )
      else if (react && mine == null)
        // A forum with reactions but no likes: the reactions have the button.
        PostActionButton(
          icon: Icons.add_reaction_outlined,
          onTap: () => _pickReaction(context),
          semanticLabel: l10n.react,
        ),
      if (mine != null)
        _MyReaction(
          glyph: reactionGlyph(mine),
          label: l10n.removeYourReaction(mine.display ?? mine.identifier),
          onTap: onReact == null ? null : () => onReact!(mine),
          onLongPress: react ? () => _pickReaction(context) : null,
        ),
      if (onBookmark != null)
        PostActionButton(
          icon: Icons.bookmark_border,
          activeIcon: Icons.bookmark,
          active: post.bookmarked,
          onTap: onBookmark,
          semanticLabel: post.bookmarked ? l10n.removeBookmark : l10n.bookmark,
        ),
      if (onReply != null)
        PostActionButton(icon: Icons.reply, onTap: onReply, semanticLabel: kitL10n(context).reply, emphasized: true),
    ];
    if (actions.isEmpty && replies == 0) return const SizedBox(height: DesignTokens.spacingM);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: replies == 0
                  ? const SizedBox.shrink()
                  : Semantics(
                      label: repliesLabel,
                      excludeSemantics: repliesLabel != null,
                      button: onShowReplies != null,
                      child: TextButton.icon(
                        onPressed: onShowReplies,
                        style: TextButton.styleFrom(
                          foregroundColor: muted,
                          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
                        ),
                        icon: const Icon(Icons.subdirectory_arrow_right, size: DesignTokens.iconSizeS),
                        label: Text(l10n.replyCount(replies)),
                      ),
                    ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  /// The forum's reactions in a sheet, each with how many used it here, the reader's own marked
  /// (choosing it again takes it back), as the Discourse app's picker.
  void _pickReaction(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final mine = _mine;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetTitle(l10n.react),
                if (mine != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                    child: Text(l10n.reactionTapAgainToRemove,
                        style: Theme.of(sheet).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: DesignTokens.spacingM,
                      runSpacing: DesignTokens.spacingM,
                      children: [
                        for (final reaction in reactions)
                          _ReactionTile(
                            glyph: reactionGlyph(reaction),
                            name: reaction.display ?? reaction.identifier,
                            count: post.reactionCounts[reaction.id] ?? 0,
                            selected: reaction.id == mine?.id,
                            onTap: () {
                              Navigator.of(sheet).pop();
                              onReact!(reaction);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Who liked the post (the forum names up to four, the reader first; the rest are counted) and
  /// how many used each reaction.
  void _showWhoReacted(BuildContext context) {
    final l10n = flarumL10n(context);
    final used = _used;
    final mine = _mine;
    final others = post.likesCount - post.likedBy.length;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) {
        final theme = Theme.of(sheet);
        final muted = theme.colorScheme.onSurfaceVariant;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.7),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
              children: [
                SheetTitle(l10n.likesAndReactions),
                if (post.likesCount > 0) ...[
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.thumb_up, color: theme.colorScheme.primary),
                    title: Text(l10n.likesTab, style: theme.textTheme.titleSmall),
                    subtitle: likesLabel == null ? null : Text(likesLabel!),
                    trailing: Text('${post.likesCount}', style: theme.textTheme.labelLarge?.copyWith(color: muted)),
                  ),
                  for (final user in post.likedBy)
                    ListTile(
                      leading: FlarumAvatar(user: user, radius: 18),
                      title: Text(user.id == readerId ? l10n.you : user.displayName),
                      onTap: onOpenUser == null
                          ? null
                          : () {
                              Navigator.of(sheet).pop();
                              onOpenUser!(user);
                            },
                    ),
                  if (others > 0)
                    ListTile(
                      leading: const SizedBox(width: 36),
                      title: Text(l10n.andOthers(others), style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                    ),
                ],
                if (used.isNotEmpty) ...[
                  if (post.likesCount > 0) const Divider(indent: DesignTokens.spacingL, endIndent: DesignTokens.spacingL),
                  ListTile(dense: true, title: Text(l10n.reactions, style: theme.textTheme.titleSmall)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
                    child: Wrap(
                      spacing: DesignTokens.spacingS,
                      runSpacing: DesignTokens.spacingS,
                      children: [
                        for (final (reaction, count) in used)
                          Chip(
                            avatar: Text(reactionGlyph(reaction), style: const TextStyle(fontSize: 18)),
                            label: Text('$count'),
                            side: reaction.id == mine?.id ? BorderSide(color: theme.colorScheme.primary, width: 1.5) : null,
                            backgroundColor: reaction.id == mine?.id ? theme.colorScheme.primaryContainer : null,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The post's likes and reactions in one count, with its most used reactions' glyphs; a tap shows
/// who.
class _ReactionSummary extends StatelessWidget {
  const _ReactionSummary({required this.glyphs, required this.total, required this.onTap});

  final List<String> glyphs;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final glyphSize = PostActionButton.iconSizeOf(context, DesignTokens.iconSizeM);
    return Semantics(
      label: flarumL10n(context).likesAndReactionsCount(total),
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinInteractiveDimension, minWidth: kMinInteractiveDimension),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: DesignTokens.spacingS, end: DesignTokens.spacingXS),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final glyph in glyphs) ...[
                  Text(glyph, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: glyphSize * 0.85, height: 1)),
                  const SizedBox(width: 2),
                ],
                if (glyphs.isNotEmpty) const SizedBox(width: DesignTokens.spacingXS),
                Text('$total', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The reader's reaction, its glyph on the accent's container: a tap takes it back, a long press
/// offers another.
class _MyReaction extends StatelessWidget {
  const _MyReaction({required this.glyph, required this.label, this.onTap, this.onLongPress});

  final String glyph;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = PostActionButton.iconSizeOf(context, DesignTokens.iconSizeM);
    return Semantics(
      label: label,
      button: true,
      selected: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          width: kMinInteractiveDimension,
          height: kMinInteractiveDimension,
          child: Center(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: colorScheme.primaryContainer,
                shape: StadiumBorder(side: BorderSide(color: colorScheme.primary, width: 1.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingXS + 2),
                child: Text(glyph, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: size * 0.85, height: 1)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A reaction in the picker: its glyph in a circle, how many used it on the post.
class _ReactionTile extends StatelessWidget {
  const _ReactionTile({
    required this.glyph,
    required this.name,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String glyph;
  final String name;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 2 : 0.5,
        ),
      ),
      child: Text(glyph,
          textScaler: TextScaler.noScaling,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontSize: 26, height: 1)),
    );
    return Tooltip(
      message: name,
      child: Semantics(
        label: count > 0 ? '$name, $count' : name,
        button: true,
        selected: selected,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size + 8,
            height: size + 8,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                tile,
                if (count > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: selected ? colorScheme.primary : colorScheme.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
