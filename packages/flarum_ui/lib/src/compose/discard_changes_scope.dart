import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';

import '../../l10n/flarum_l10n.dart';

/// Asks before a form with unsaved changes is closed, whichever way: its ✕,
/// Back, Android's back gesture (forum_kit's, in Flarum's words).
///
/// The [question] is Flarum's own for what's being written ("You have not
/// posted your reply. Do you wish to discard it?"), with Discard and Cancel.
/// A form with a forum draft (fof/drafts) also offers Save Draft, which keeps
/// it and closes.
///
/// A form without changes closes at once, and keeps Android's predictive
/// back animation; so does one whose changes are all saved. While [busy]
/// (sending), it does not close at all.
class DiscardChangesScope extends StatefulWidget {
  const DiscardChangesScope({
    super.key,
    required this.listenable,
    required this.hasChanges,
    required this.child,
    required this.question,
    this.busy = false,
    this.onSaveDraft,
    this.onDiscard,
    this.describeFailure,
  });

  /// What the answer of [hasChanges] follows: the form's text controllers.
  final Listenable listenable;

  /// Whether closing now would lose something.
  final bool Function() hasChanges;

  /// What closing asks, in Flarum's words for what's being written.
  final String question;

  /// Set while the form is sending: Back does nothing until it answers.
  final bool busy;

  /// Keeps what was written for later, before closing. Offered as Save
  /// draft only when given.
  final Future<void> Function()? onSaveDraft;

  /// Throws away what was written (a server draft, say), before closing.
  final Future<void> Function()? onDiscard;

  final Widget child;

  /// Words a failed save or discard for the reader; without it, the error's
  /// own message is shown.
  final String Function(Object error, BuildContext context)? describeFailure;

  @override
  State<DiscardChangesScope> createState() => _DiscardChangesScopeState();
}

enum _Choice { discard, saveDraft }

class _DiscardChangesScopeState extends State<DiscardChangesScope> {
  bool _asking = false;
  bool _closing = false;

  Future<void> _ask() async {
    if (_asking || widget.busy) return;
    _asking = true;
    final l10n = flarumL10n(context);
    final kit = kitL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final choice = await showDialog<_Choice>(
      context: context,
      builder: (dialog) => AlertDialog(
        // When the three choices do not fit side by side they stack, with
        // the action at the top and Cancel at the bottom, as Material 3
        // stacks a dialog's buttons.
        actionsOverflowDirection: VerticalDirection.up,
        content: Text(widget.question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(kit.cancel),
          ),
          if (widget.onSaveDraft != null)
            TextButton(
              onPressed: () => Navigator.pop(dialog, _Choice.saveDraft),
              child: Text(l10n.saveDraft),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialog, _Choice.discard),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) {
      _asking = false;
      return;
    }
    setState(() => _closing = true);
    Object? failure;
    try {
      switch (choice) {
        case _Choice.saveDraft:
          await widget.onSaveDraft?.call();
        case _Choice.discard:
          await widget.onDiscard?.call();
      }
    } catch (error) {
      failure = error;
    }
    if (mounted) setState(() => _closing = false);
    var close = failure == null;
    if (failure != null && mounted) {
      final message = (widget.describeFailure ?? _plainError)(failure, context);
      if (choice == _Choice.discard) {
        // Offline, or after the sign-in changed under the form, Discard
        // cannot reach the draft, and Save draft cannot either: without
        // this the only way out was to delete every word.
        close = await _askCloseAnyway(message);
      } else {
        SnackbarHelper.showError(context, message);
      }
    }
    _asking = false;
    if (!close || !mounted) return;
    final route = ModalRoute.of(context);
    // Navigator.pop closes the form regardless of the scope below.
    if (route != null && route.isCurrent) Navigator.of(context).pop();
  }

  /// Why Discard failed, and whether to close without it. Closing keeps
  /// whatever draft the forum already has; the form saves nothing more.
  Future<bool> _askCloseAnyway(String reason) async {
    final l10n = kitL10n(context);
    final close = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        actionsOverflowDirection: VerticalDirection.up,
        content: Text('$reason\n\n${l10n.discardFailedCloseQuestion}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.closeAnyway),
          ),
        ],
      ),
    );
    return close == true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.listenable,
      builder: (context, child) => PopScope(
        canPop: !_closing && !widget.busy && !widget.hasChanges(),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _ask();
        },
        child: AbsorbPointer(absorbing: _closing, child: child!),
      ),
      child: widget.child,
    );
  }
}

/// The error's own message without Dart's "Exception: " prefix, or the
/// generic wording when that is empty or a machine detail (long, or markup).
String _plainError(Object error, BuildContext context) {
  final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (text.isEmpty || text.length > 200 || text.contains('<html') || text.contains('<!DOCTYPE')) {
    return kitL10n(context).somethingWentWrongTryAgain;
  }
  return text;
}
