import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/discourse_color.dart';
import 'package:forum_kit/utils/discourse_icons.dart';

/// The Material icon for a Flarum tag's Font Awesome icon (`fas fa-comments`),
/// or null when there's no good match.
IconData? flarumTagIcon(String? icon) {
  if (icon == null) return null;
  final name = icon.split(RegExp(r'\s+')).where((c) => c.startsWith('fa-')).lastOrNull;
  return materialIconForDiscourseIcon(name);
}

/// A tag's colour, or null when it has none (or an unreadable one).
Color? flarumTagColor(FlarumTag tag) {
  final hex = tag.color?.trim();
  if (hex == null || hex.isEmpty) return null;
  return parseDiscourseHex(hex);
}

/// A tag as the web labels it on a discussion: its name in its colour (a
/// filled label for a primary tag, an outlined one for a secondary tag).
class TagLabel extends StatelessWidget {
  const TagLabel({super.key, required this.tag});

  final FlarumTag tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = flarumTagColor(tag);
    final filled = tag.isPrimary && color != null;
    final foreground = filled
        ? (ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87)
        : colorScheme.onSurfaceVariant;
    final icon = flarumTagIcon(tag.icon);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color ?? colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: foreground), const SizedBox(width: 3)],
          Text(
            tag.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
