import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import 'forum_web_page.dart';

/// Deleting the reader's account, as the Discourse app's Delete Account does it: in the app where
/// the forum allows it, and otherwise by its staff.
///
/// Flarum itself lets no member delete their account. Forums running flarum/gdpr
/// ([FlarumExtensions.gdpr]; fof/gdpr before it moved to Flarum) take requests, which this page
/// makes as the website's Erase Account does: with the reader's password, after which the forum
/// emails a link that confirms the request, and its staff anonymize or delete the account within
/// 30 days of the confirmation. The page says each step and where the request stands, and cancels
/// it. On other forums only the staff can delete an account, and the page says so and opens the
/// forum, logged in, to ask them.
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DeleteAccountPage(site: site)));

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _password = TextEditingController();
  final _reason = TextEditingController();

  FlarumErasureRequest? _request;
  /// Reading where the reader's request stands (and the forum's info, if the app has none yet).
  late bool _loading = _info?.actor == null || _canRequest;
  Object? _loadError;
  bool _sending = false;
  bool _obscure = true;
  String? _passwordError;

  /// The form again while a request waits for its email: "Send a New Link".
  bool _askingAgain = false;

  FlarumForumInfo? get _info => _forum.info;

  /// Whether the forum takes erasure requests: flarum/gdpr with at least one way of erasing (with
  /// neither, its staff could not carry a request out).
  bool get _canRequest =>
      _forum.extensions.gdpr && ((_info?.erasureAnonymizes ?? false) || (_info?.erasureDeletes ?? false));

  String get _forumName => _info?.title ?? widget.site.site.name;

  @override
  void initState() {
    super.initState();
    if (_loading) _load(first: true);
  }

  @override
  void dispose() {
    _password.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load({bool first = false}) async {
    if (!first) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final reader = _info?.actor ?? (await _forum.refresh()).actor;
      if (reader == null) throw StateError('Not logged in');
      if (_canRequest) {
        final request = await _forum.api.erasureRequest(reader.id);
        if (mounted) setState(() => _request = request);
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final l10n = flarumL10n(context);
    final askPassword = !(_info?.passwordlessSignUp ?? false);
    setState(() {
      _sending = true;
      _passwordError = null;
    });
    try {
      final request = await _forum.api.requestErasure(
        password: askPassword ? _password.text : null,
        reason: _reason.text.trim(),
      );
      if (!mounted) return;
      _password.clear();
      setState(() {
        _request = request;
        _askingAgain = false;
        _sending = false;
      });
    } on FlarumApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      if (e.isValidationError && e.errors.any((error) => error.pointer?.endsWith('/password') ?? false)) {
        setState(() => _passwordError = l10n.deleteAccountWrongPassword);
      } else {
        SnackbarHelper.showError(context, describeError(context, e));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  Future<void> _cancel() async {
    final l10n = flarumL10n(context);
    final request = _request;
    if (request == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.deleteAccountCancelQuestion),
        content: Text(l10n.deleteAccountCancelQuestionBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(l10n.deleteAccountKeepRequest)),
          TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(l10n.deleteAccountCancelRequest)),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _sending = true);
    try {
      await _forum.api.cancelErasure(request.id);
      if (!mounted) return;
      setState(() {
        _request = null;
        _askingAgain = false;
        _sending = false;
      });
      SnackbarHelper.showSuccess(context, l10n.deleteAccountRequestCancelled);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  String _date(DateTime? time) =>
      time == null ? '' : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(time.toLocal());

  /// What erasing does on this forum, by the ways its admins allow.
  String _whatErasingDoes(FlarumLocalizations l10n) {
    final anonymizes = _info?.erasureAnonymizes ?? false;
    final deletes = _info?.erasureDeletes ?? false;
    if (anonymizes && deletes) return l10n.deleteAccountEither;
    return deletes ? l10n.deleteAccountDeletes : l10n.deleteAccountAnonymizes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final request = _request;
    final List<Widget> content;
    // Which of the page's states shows: each starts at the top (the request is sent from the
    // bottom of a long form, and its answer is a new page's worth).
    final String stage;
    if (_loading) {
      stage = 'loading';
      content = [const Padding(padding: EdgeInsets.all(DesignTokens.spacingXL), child: Center(child: CircularProgressIndicator()))];
    } else if (_loadError != null) {
      stage = 'error';
      content = [
        Text(describeError(context, _loadError), style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: DesignTokens.spacingL),
        Center(child: FilledButton(onPressed: _load, child: Text(l10n.retry))),
      ];
    } else if (!_canRequest) {
      stage = 'staff';
      content = _byStaff(context);
    } else if (request != null && request.status == FlarumErasureStatus.confirmed) {
      stage = 'confirmed';
      content = _confirmed(context, request);
    } else if (request != null && request.status == FlarumErasureStatus.processed) {
      stage = 'done';
      content = [_Header(icon: Icons.check_circle_outline, title: l10n.deleteAccountDone(_forumName))];
    } else if (request != null && request.status == FlarumErasureStatus.awaitingConfirmation && !_askingAgain) {
      stage = 'awaiting';
      content = _awaiting(context, request);
    } else {
      stage = 'form';
      content = _form(context);
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccount)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // Readable lines on a tablet.
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: ValueKey(stage),
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXL),
              children: content,
            ),
          ),
        ),
      ),
    );
  }

  /// No request yet (or a cancelled one): what will happen, then the password, a reason, and the
  /// request.
  List<Widget> _form(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final email = _info?.actor?.email;
    final askPassword = !(_info?.passwordlessSignUp ?? false);
    return [
      _Header(icon: Icons.person_remove_outlined, title: l10n.deleteAccountTitle(_forumName), danger: true),
      _Paragraph(l10n.deleteAccountIntro(_forumName)),
      _Step(1, email == null ? l10n.deleteAccountStepEmailNoAddress(_forumName) : l10n.deleteAccountStepEmail(_forumName, email)),
      _Step(2, l10n.deleteAccountStepConfirm),
      _Step(3, l10n.deleteAccountStepStaff),
      _Paragraph(_whatErasingDoes(l10n), muted: true),
      const SizedBox(height: DesignTokens.spacingS),
      if (askPassword) ...[
        TextField(
          controller: _password,
          enabled: !_sending,
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.deleteAccountPassword,
            helperText: l10n.deleteAccountPasswordHelp(_forumName),
            helperMaxLines: 3,
            errorText: _passwordError,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _obscure ? l10n.deleteAccountShowPassword : l10n.deleteAccountHidePassword,
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingL),
      ],
      TextField(
        controller: _reason,
        enabled: !_sending,
        minLines: 2,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.deleteAccountReason,
          helperText: l10n.deleteAccountReasonHelp,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: DesignTokens.spacingL),
      FilledButton(
        onPressed: _sending ? null : _send,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          minimumSize: const Size.fromHeight(48),
        ),
        child: _sending
            ? SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onError))
            : Text(l10n.deleteAccountRequest),
      ),
      if (_askingAgain) ...[
        const SizedBox(height: DesignTokens.spacingS),
        TextButton(
          onPressed: _sending ? null : () => setState(() => _askingAgain = false),
          child: Text(l10n.cancel),
        ),
      ],
    ];
  }

  /// Asked for: the forum has emailed the link that confirms it.
  List<Widget> _awaiting(BuildContext context, FlarumErasureRequest request) {
    final l10n = flarumL10n(context);
    final email = _info?.actor?.email;
    final sent = _date(request.createdAt);
    return [
      _Header(icon: Icons.mark_email_unread_outlined, title: l10n.deleteAccountCheckEmail),
      _Paragraph(email == null
          ? l10n.deleteAccountEmailSentNoAddress(_forumName, sent)
          : l10n.deleteAccountEmailSent(_forumName, email, sent)),
      _Paragraph(l10n.deleteAccountAfterConfirming),
      _Paragraph(_whatErasingDoes(l10n), muted: true),
      if (request.reason case final reason?) _Paragraph(l10n.deleteAccountYourReason(reason), muted: true),
      const SizedBox(height: DesignTokens.spacingS),
      OutlinedButton(
        onPressed: _sending ? null : _cancel,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: Text(l10n.deleteAccountCancelRequest),
      ),
      const SizedBox(height: DesignTokens.spacingL),
      _Paragraph(l10n.deleteAccountNoEmail, muted: true),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          onPressed: _sending ? null : () => setState(() => _askingAgain = true),
          child: Text(l10n.deleteAccountSendAgain),
        ),
      ),
    ];
  }

  /// Confirmed from the email: the staff erase the account within 30 days.
  List<Widget> _confirmed(BuildContext context, FlarumErasureRequest request) {
    final l10n = flarumL10n(context);
    return [
      _Header(icon: Icons.hourglass_top_rounded, title: l10n.deleteAccountConfirmedTitle),
      _Paragraph(l10n.deleteAccountConfirmedBody(_date(request.confirmedAt), _date(request.dueBy))),
      _Paragraph(_whatErasingDoes(l10n), muted: true),
      if (request.reason case final reason?) _Paragraph(l10n.deleteAccountYourReason(reason), muted: true),
      _Paragraph(l10n.deleteAccountUntilThen),
      const SizedBox(height: DesignTokens.spacingS),
      OutlinedButton(
        onPressed: _sending ? null : _cancel,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: Text(l10n.deleteAccountCancelRequest),
      ),
    ];
  }

  /// A forum without flarum/gdpr: only its staff can delete accounts. The forum opens logged in,
  /// where the reader can write to them.
  List<Widget> _byStaff(BuildContext context) {
    final l10n = flarumL10n(context);
    return [
      _Header(icon: Icons.support_agent_outlined, title: l10n.deleteAccountByStaffTitle),
      _Paragraph(l10n.deleteAccountByStaff(_forumName)),
      _Paragraph(l10n.deleteAccountLogOutNote(_forumName), muted: true),
      const SizedBox(height: DesignTokens.spacingS),
      FilledButton.icon(
        onPressed: () => ForumWebPage.open(context, widget.site, path: '/', title: _forumName),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        icon: const Icon(Icons.forum_outlined),
        label: Text(l10n.deleteAccountContactStaff),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title, this.danger = false});

  final IconData icon;
  final String title;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: danger ? colorScheme.errorContainer : colorScheme.secondaryContainer,
            child: Icon(icon, size: 28, color: danger ? colorScheme.onErrorContainer : colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Text(
        text,
        style: (muted ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)
            ?.copyWith(color: muted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface),
      ),
    );
  }
}

/// One step of what happens, numbered.
class _Step extends StatelessWidget {
  const _Step(this.number, this.text);

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Text('$number', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(text, style: theme.textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
