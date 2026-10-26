import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/discourse_color.dart';
import 'package:forum_kit/utils/discourse_icons.dart';
import 'package:forum_kit/utils/html_colors.dart';

/// The Material icon for a Flarum tag's Font Awesome icon (`fas fa-comments`),
/// or null when there's no good match.
IconData? flarumTagIcon(String? icon) {
  if (icon == null) return null;
  final name = icon.split(RegExp(r'\s+')).where((c) => c.startsWith('fa-')).lastOrNull;
  return materialIconForDiscourseIcon(name);
}

/// [tags] as the web lists them on a discussion: the primary ones, a child
/// after its parent, then the secondary ones.
List<FlarumTag> tagsInWebOrder(List<FlarumTag> tags) => [
      ...tags.where((t) => t.isPrimary && !t.isChild),
      ...tags.where((t) => t.isPrimary && t.isChild),
      ...tags.where((t) => !t.isPrimary),
    ];

/// A tag's colour, or null when it has none (or an unreadable one).
Color? flarumTagColor(FlarumTag tag) {
  final hex = tag.color?.trim();
  if (hex == null || hex.isEmpty) return null;
  return parseDiscourseHex(hex);
}

/// White or near-black, whichever reads better on [fill] by WCAG contrast. Flutter's
/// `estimateBrightnessForColor` puts white on mid-tones such as Flarum's orange and green, at
/// under 3:1; here they get black, at over 7:1.
Color textOn(Color fill) {
  final opaque = fill.withValues(alpha: 1);
  final dark = Color.alphaBlend(Colors.black87, opaque);
  return contrastRatio(Colors.white, opaque) >= contrastRatio(dark, opaque) ? Colors.white : Colors.black87;
}

/// A tag colour as a mark on [surface]: its own, moved only as far as it takes to show (a
/// near-black tag on a dark screen), as the Discourse app draws a category's mark.
Color tagMarkColor(Color color, Color surface) => readableOn(color, surface, minContrast: 1.8);

/// A tag on a discussion, as the Discourse app badges a category and its tags.
///
/// A primary tag is a small mark in its colour (its icon, or a square split with its parent's
/// colour for a child tag) and its name in the page's quiet text colour; a secondary tag is a
/// neutral chip, with a dot of its colour when it has one. A tag's name used to sit on its own
/// colour, as the web draws it, and most of Flarum's palette (orange, green, teal, grey) left
/// white text under 3:1. With [onTap] it's 32dp high to tap, and opens the tag.
class TagLabel extends StatelessWidget {
  const TagLabel({super.key, required this.tag, this.parent, this.onTap, this.large = false});

  final FlarumTag tag;

  /// A child tag's parent, whose colour shares the mark.
  final FlarumTag? parent;
  final VoidCallback? onTap;

  /// The discussion page's size; the default suits a list row.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final label = tag.isPrimary ? _primary(context) : _secondary(context);
    final tap = onTap;
    final semantic = Semantics(label: tag.name, button: tap != null, excludeSemantics: true, child: label);
    if (tap == null) return semantic;
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: semantic),
    );
  }

  Widget _primary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final markSize = large ? 14.0 : 12.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TagMark(tag: tag, parent: parent, size: markSize),
        SizedBox(width: large ? 6 : 4),
        Flexible(
          child: Text(
            tag.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (large ? theme.textTheme.labelLarge : theme.textTheme.labelMedium)
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _secondary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = flarumTagColor(tag);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: tagMarkColor(color, colorScheme.surfaceContainerHighest),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                tag.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (large ? theme.textTheme.labelLarge : theme.textTheme.labelMedium)
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A primary tag's mark: its icon in its colour, or a square of its colour, split with its
/// parent's for a child tag, as the Discourse app marks a subcategory. A tag without a colour
/// gets the outline colour.
class TagMark extends StatelessWidget {
  const TagMark({super.key, required this.tag, this.parent, this.size = 12});

  final FlarumTag tag;
  final FlarumTag? parent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color tone(FlarumTag t) => tagMarkColor(flarumTagColor(t) ?? colorScheme.outline, colorScheme.surface);
    final own = tone(tag);
    final icon = flarumTagIcon(tag.icon);
    if (icon != null) return Icon(icon, size: size + 2, color: own);
    final parent = this.parent;
    return Container(
      width: size - 2,
      height: size - 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: parent == null ? own : null,
        gradient: parent == null
            ? null
            : LinearGradient(colors: [tone(parent), tone(parent), own, own], stops: const [0, 0.5, 0.5, 1]),
      ),
    );
  }
}

/// [tag]'s parent among [tags], for a child tag's mark.
FlarumTag? parentAmong(FlarumTag tag, Iterable<FlarumTag> tags) =>
    tag.parentId == null ? null : tags.where((t) => t.id == tag.parentId).firstOrNull;

/// A primary tag as a tile, as the Discourse app marks a category: a rounded square in its colour
/// with its icon, at 20dp in the drawer, 24dp on a card or in a collapsed bar, 40dp in the tag's
/// header. The small mark on a discussion row is [TagMark].
class TagTileMark extends StatelessWidget {
  const TagTileMark({super.key, required this.tag, this.size = 24});

  final FlarumTag tag;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = tagMarkColor(flarumTagColor(tag) ?? colorScheme.outline, colorScheme.surface);
    final icon = flarumTagIcon(tag.icon);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.28)),
      child: icon == null ? null : Icon(icon, size: size * 0.6, color: textOn(color)),
    );
  }
}
