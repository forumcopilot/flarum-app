import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';

import '../../l10n/flarum_l10n.dart';

/// What the website writes between two posts more than 4 days apart ("5 days later"), counted as
/// it counts them (dayjs: days up to 25, then a month, months up to 10, then a year); null when
/// they're closer, or either time is missing.
String? timeLapsed(DateTime? before, DateTime? after, FlarumLocalizations l10n) {
  if (before == null || after == null) return null;
  final gap = after.difference(before);
  if (gap <= const Duration(days: 4)) return null;
  final days = (gap.inHours / 24).round();
  if (days <= 25) return l10n.timeGapDays(days);
  if (days <= 45) return l10n.timeGapMonths(1);
  final months = (days / 30.44).round();
  if (months <= 10) return l10n.timeGapMonths(months);
  if (months <= 17) return l10n.timeGapYears(1);
  return l10n.timeGapYears((days / 365.25).round());
}

/// The website's mark of a long silence between posts or messages, or of a conversation's start:
/// small, bold, in capitals, muted.
class TimeGap extends StatelessWidget {
  const TimeGap({super.key, required this.text, this.centered = false});

  final String text;

  /// Centred, between a conversation's messages; at the start of the line, between posts.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, 0),
      child: Text(
        text.toUpperCase(),
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
