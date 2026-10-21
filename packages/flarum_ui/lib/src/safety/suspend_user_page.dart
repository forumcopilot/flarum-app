import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum_kit/theme/design_tokens.dart';

import '../../l10n/flarum_l10n.dart';

/// What a moderator chose: when the suspension ends (null: not suspended), the reason for
/// moderators and the message for the member (each null when left empty).
typedef SuspendChoice = ({DateTime? until, String? reason, String? message});

/// flarum/suspend's Suspend dialog as a page: the suspension status (not suspended, indefinitely,
/// or a number of days), the reason for moderators and the message for the member, as they stand.
/// Not suspended lifts a suspension. Null when closed.
Future<SuspendChoice?> showSuspendUserPage(BuildContext context, FlarumUser user) =>
    Navigator.of(context).push<SuspendChoice>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => SuspendUserPage(user: user),
    ));

enum _Status { notSuspended, indefinitely, limited }

class SuspendUserPage extends StatefulWidget {
  const SuspendUserPage({super.key, required this.user});

  final FlarumUser user;

  @override
  State<SuspendUserPage> createState() => _SuspendUserPageState();
}

class _SuspendUserPageState extends State<SuspendUserPage> {
  late _Status _status;
  late final TextEditingController _days;
  late final _reason = TextEditingController(text: widget.user.suspendReason ?? '');
  late final _message = TextEditingController(text: widget.user.suspendMessage ?? '');
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    // As the web opens it: the suspension as it stands, with the days it has left.
    final user = widget.user;
    final until = user.suspendedUntil;
    _status = !user.isSuspended
        ? _Status.notSuspended
        : user.isSuspendedIndefinitely
            ? _Status.indefinitely
            : _Status.limited;
    final left = until == null ? 1 : (until.difference(DateTime.now()).inHours / 24).ceil().clamp(1, 1 << 20);
    _days = TextEditingController(text: _status == _Status.limited ? '$left' : '');
  }

  @override
  void dispose() {
    _days.dispose();
    _reason.dispose();
    _message.dispose();
    super.dispose();
  }

  int? get _dayCount {
    final days = int.tryParse(_days.text.trim());
    return days != null && days > 0 ? days : null;
  }

  void _save() {
    final days = _dayCount;
    if (_status == _Status.limited && days == null) {
      setState(() => _showErrors = true);
      return;
    }
    String? text(TextEditingController field) => field.text.trim().isEmpty ? null : field.text.trim();
    Navigator.of(context).pop<SuspendChoice>((
      until: switch (_status) {
        _Status.notSuspended => null,
        _Status.indefinitely => FlarumUser.indefiniteSuspension,
        _Status.limited => DateTime.now().toUtc().add(Duration(days: days!)),
      },
      reason: text(_reason),
      message: text(_message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spacingL, bottom: DesignTokens.spacingXS),
          child: Text(text, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        );
    final suspending = _status != _Status.notSuspended;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.suspendUserTitle(widget.user.displayName)),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(key: const ValueKey('suspend-save'), onPressed: _save, child: Text(l10n.save)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingXL),
          children: [
            heading(l10n.suspensionStatus),
            RadioGroup<_Status>(
              groupValue: _status,
              onChanged: (status) => setState(() {
                _status = status ?? _Status.notSuspended;
                if (_status == _Status.limited && _days.text.isEmpty) _days.text = '1';
              }),
              child: Column(
                children: [
                  RadioListTile(value: _Status.notSuspended, contentPadding: EdgeInsets.zero, title: Text(l10n.notSuspended)),
                  RadioListTile(
                      value: _Status.indefinitely, contentPadding: EdgeInsets.zero, title: Text(l10n.suspendIndefinitely)),
                  RadioListTile(value: _Status.limited, contentPadding: EdgeInsets.zero, title: Text(l10n.suspendLimitedTime)),
                ],
              ),
            ),
            if (_status == _Status.limited)
              Padding(
                padding: const EdgeInsets.only(left: DesignTokens.spacingXXXL),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: TextField(
                        key: const ValueKey('suspend-days'),
                        controller: _days,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) {
                          if (_showErrors) setState(() => _showErrors = false);
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          isDense: true,
                          errorText: _showErrors && _dayCount == null ? '' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingS),
                    Text(l10n.suspendDays),
                  ],
                ),
              ),
            // Kept for the next suspension, as the web keeps them; not sent while not suspended.
            heading(l10n.suspendReasonLabel),
            TextField(
              key: const ValueKey('suspend-reason'),
              controller: _reason,
              enabled: suspending,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.optional, border: const OutlineInputBorder()),
            ),
            heading(l10n.suspendMessageLabel),
            TextField(
              key: const ValueKey('suspend-message'),
              controller: _message,
              enabled: suspending,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.optional, border: const OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
