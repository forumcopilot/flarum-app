import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';

/// Above the tabs while the reader is suspended (flarum/suspend): until when, and what the forum
/// told them. They can read, as a guest can, and post nothing.
class SuspendedStrip extends StatelessWidget {
  const SuspendedStrip({super.key, required this.reader});

  final FlarumUser reader;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final until = reader.suspendedUntil!.toLocal();
    final headline = reader.isSuspendedIndefinitely
        ? l10n.youAreSuspendedIndefinitely
        : l10n.youAreSuspended(DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(until));
    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
        child: Row(
          children: [
            Icon(Icons.block, color: colorScheme.onErrorContainer),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Text(
                [headline, if (reader.suspendMessage case final message?) message].join(' '),
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
