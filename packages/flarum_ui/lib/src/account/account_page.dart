import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/forum_icon_tile.dart';
import 'package:forum_kit/views/widgets/sheet_title.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';

import '../../l10n/flarum_l10n.dart';
import '../app/forum_drawer.dart';
import 'account_privacy_page.dart';
import 'edit_profile_page.dart';
import 'forum_web_page.dart';
import '../notifications/notification_settings_page.dart';
import '../safety/flagged_posts_page.dart';
import '../../config/app_forum_config.dart';
import '../app/appearance.dart';
import '../app/debug_forums.dart';
import '../bookmarks/bookmarks_page.dart';
import '../compose/composers.dart' show canSaveDrafts;
import '../drafts/drafts_page.dart';
import 'log_in_first.dart';
import '../widgets/flarum_avatar.dart';
import '../profile/user_page.dart';

/// The reader's own tab, as the Discourse app's Profile tab: who they are (View Profile, Edit
/// Profile, their numbers), their stuff (posts, drafts, bookmarks, flags to review), then the
/// settings (notifications, the app's colour scheme, account and privacy) and Log Out. A guest gets
/// the forum and Log In. It used to be one flat list, with Settings on the forum's web page.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.site, this.appearance, this.onSignInChanged, this.onSwitchForum});

  final SiteContext site;

  /// The reader's light/dark choice, offered here when given.
  final Appearance? appearance;

  /// Called after signing in or out, so the rest of the app can reload.
  final VoidCallback? onSignInChanged;

  /// Restarts the app on another forum; offered in debug builds only.
  final Future<void> Function(AppForumConfig forum)? onSwitchForum;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  bool _busy = false;

  /// Logged in, but who the reader is hasn't come from the forum yet (the app started offline,
  /// say): it's read again here, rather than the page offering Log In to someone logged in.
  late bool _readingReader = _forum.isSignedIn && _forum.info?.actor == null;
  Object? _readerError;

  /// Back in the app with the email still to confirm: the reader may just have followed the
  /// link, so the forum is asked again.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(onResume: () {
    if (_forum.isSignedIn && !(_forum.info?.actorEmailConfirmed ?? true) && !_readingReader) _readReader();
  });

  @override
  void initState() {
    super.initState();
    _lifecycle;
    if (_readingReader) _readReader(first: true);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _readReader({bool first = false}) async {
    if (!first) {
      setState(() {
        _readingReader = true;
        _readerError = null;
      });
    }
    try {
      await _forum.refresh();
    } catch (e) {
      _readerError = e;
    }
    if (mounted) setState(() => _readingReader = false);
  }

  Future<void> _signIn({bool signUp = false}) async {
    if (await logInFirst(context, widget.site, signUp: signUp)) {
      if (mounted) setState(() {});
      widget.onSignInChanged?.call();
    }
  }

  void _openProfile(FlarumUser reader) => UserPage.open(context, widget.site, reader.slug ?? reader.username);

  /// Signs out here even when the forum can't be reached (the token then
  /// stays valid there until it expires or is revoked on the web). Asked
  /// first, as the forum's own log-out page asks.
  Future<void> _signOut() async {
    final l10n = flarumL10n(context);
    final error = Theme.of(context).colorScheme.error;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.logOutQuestion(_forum.info?.title ?? widget.site.site.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(kitL10n(dialog).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: TextButton.styleFrom(foregroundColor: error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _busy = true);
    await FlarumUserProxy(widget.site).logoutUserAsync();
    await forgetWebLogin(widget.site);
    ForumSession.changed(widget.site);
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onSignInChanged?.call();
  }

  /// The app's light or dark choice, in a sheet, as the Discourse app offers it.
  void _chooseAppearance(Appearance appearance) {
    final l10n = flarumL10n(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: appearance,
          builder: (context, mode, _) => RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (choice) {
              if (choice == null) return;
              appearance.choose(choice);
              Navigator.of(sheet).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l10n.appearance),
                for (final choice in ThemeMode.values)
                  RadioListTile<ThemeMode>(value: choice, title: Text(_appearanceLabel(choice, l10n))),
                const SizedBox(height: DesignTokens.spacingS),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _appearanceLabel(ThemeMode mode, FlarumLocalizations l10n) => switch (mode) {
        ThemeMode.system => l10n.appearanceSystem,
        ThemeMode.light => l10n.light,
        ThemeMode.dark => l10n.dark,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final reader = _forum.isSignedIn ? _forum.info?.actor : null;
    final readerUnknown = _forum.isSignedIn && reader == null && (_readingReader || _readerError != null);
    return Scaffold(
      appBar: AppBar(leading: forumDrawerButton(context), title: Text(l10n.profile)),
      body: readerUnknown
          ? _unknownReader(context)
          : RefreshIndicator(
              onRefresh: _readReader,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
                children: [
                  ...reader == null ? _guest(context) : _hub(context, reader),
                  ..._settings(context, reader),
                  if (showForumSwitcher && widget.onSwitchForum != null)
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Forum (debug)'),
                      subtitle: Text(widget.site.site.url),
                      onTap: () async {
                        final forum = await DebugForumPage.open(context, widget.site.site.url);
                        if (forum != null) await widget.onSwitchForum!(forum);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  /// Logged in, but the forum hasn't said who the reader is: wait, or retry, or log out.
  Widget _unknownReader(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacingXL),
      children: [
        if (_readerError case final error?) ...[
          Text(describeError(context, error), style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: DesignTokens.spacingXL),
          FilledButton(onPressed: _readReader, child: Text(l10n.retry)),
        ] else
          const Center(child: CircularProgressIndicator()),
        const SizedBox(height: DesignTokens.spacingS),
        OutlinedButton(onPressed: _busy ? null : _signOut, child: Text(l10n.signOut)),
      ],
    );
  }

  /// The forum, and Log In (and Sign Up, on the forum's page, where it takes new members).
  List<Widget> _guest(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final name = _forum.info?.title ?? widget.site.site.name;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForumIconTile(name: name, url: _forum.info?.faviconUrl, size: 48),
            const SizedBox(height: DesignTokens.spacingM),
            Text(l10n.joinForum(name), style: theme.textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spacingXS),
            Text(l10n.logInToTakePart,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: DesignTokens.spacingL),
            Row(children: [
              Expanded(child: FilledButton(onPressed: _signIn, child: Text(l10n.signIn))),
              if (_forum.info?.allowSignUp ?? false) ...[
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _signIn(signUp: true),
                    child: Text(l10n.createAccount),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: DesignTokens.spacingS),
            Text(l10n.signInHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    ];
  }

  /// Who the reader is, their numbers, and their stuff.
  List<Widget> _hub(BuildContext context, FlarumUser reader) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingM),
        child: Row(children: [
          FlarumAvatar(user: reader, radius: 32, onTap: () => _openProfile(reader)),
          const SizedBox(width: DesignTokens.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reader.displayName, style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(l10n.signedInAs('@${reader.username}'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ]),
      ),
      if (!(_forum.info?.actorEmailConfirmed ?? true)) _ConfirmEmail(forum: _forum, reader: reader),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
        child: Row(children: [
          Expanded(child: FilledButton.tonal(onPressed: () => _openProfile(reader), child: Text(l10n.viewProfile))),
          const SizedBox(width: DesignTokens.spacingS),
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                await EditProfilePage.open(context, widget.site);
                if (mounted) setState(() {});
              },
              child: Text(l10n.editProfile),
            ),
          ),
        ]),
      ),
      ProfileStats(user: reader, onTap: () => _openProfile(reader)),
      const _Band(),
      _Heading(l10n.yourStuff),
      _Row(icon: Icons.forum_outlined, label: l10n.myPosts, onTap: () => _openProfile(reader)),
      if (canSaveDrafts(_forum))
        _Row(
          icon: Icons.edit_note,
          label: l10n.drafts,
          count: _forum.info?.draftCount,
          onTap: () async {
            await DraftsPage.open(context, widget.site);
            if (mounted) setState(() {});
          },
        ),
      if (_forum.extensions.bookmarks)
        _Row(icon: Icons.bookmark_border, label: l10n.bookmarks, onTap: () => BookmarksPage.open(context, widget.site)),
      // A moderator's flag list, with the web's count of new flags.
      if (canViewFlags(_forum))
        _Row(
          icon: Icons.flag_outlined,
          label: l10n.flaggedPosts,
          count: _forum.info?.newFlagCount,
          onTap: () async {
            await FlaggedPostsPage.open(context, widget.site);
            if (mounted) setState(() {});
          },
        ),
    ];
  }

  /// Notifications, the colour scheme, account and privacy, and Log Out.
  List<Widget> _settings(BuildContext context, FlarumUser? reader) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final appearance = widget.appearance;
    final rows = [
      if (reader != null)
        _Row(
          icon: Icons.notifications_none,
          label: l10n.notificationSettings,
          onTap: () => NotificationSettingsPage.open(context, widget.site),
        ),
      if (appearance != null)
        ValueListenableBuilder<ThemeMode>(
          valueListenable: appearance,
          builder: (context, mode, _) => _Row(
            icon: Icons.brightness_6_outlined,
            label: l10n.appearance,
            trailing: Text(_appearanceLabel(mode, l10n),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            onTap: () => _chooseAppearance(appearance),
          ),
        ),
      if (reader != null)
        _Row(
          icon: Icons.shield_outlined,
          label: l10n.accountAndPrivacy,
          onTap: () => AccountPrivacyPage.open(context, widget.site),
        ),
      if (reader != null)
        _Row(
          icon: Icons.logout,
          label: l10n.signOut,
          color: theme.colorScheme.error,
          onTap: _busy ? null : _signOut,
        ),
    ];
    if (rows.isEmpty) return const [];
    return [const _Band(), _Heading(l10n.settings), ...rows];
  }
}

/// A member's numbers, as the Discourse app's stats strip: each number over what it counts.
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.user, this.onTap});

  final FlarumUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final discussions = user.discussionCount;
    final posts = user.commentCount;
    final answers = user.bestAnswerCount;
    final stats = [
      if (discussions != null) (discussions, l10n.statDiscussions(discussions)),
      if (posts != null) (posts, l10n.statPosts(posts)),
      if (answers != null) (answers, l10n.statBestAnswers(answers)),
    ];
    if (stats.isEmpty) return const SizedBox(height: DesignTokens.spacingL);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingM),
      child: Row(children: [for (final (value, label) in stats) _Stat(value: value, label: label, onTap: onTap)]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      // The number and its label read as one ("26 posts").
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: Column(children: [
              Text('$value', style: textTheme.titleLarge?.copyWith(color: colorScheme.primary)),
              Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The band set between the tab's sections.
class _Band extends StatelessWidget {
  const _Band();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const SizedBox(height: DesignTokens.spacingS, width: double.infinity),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXS),
        child: Semantics(
          header: true,
          child: Text(label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

/// One destination on the tab: an icon, a label, and a count or value.
class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap, this.count, this.trailing, this.color});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int? count;
  final Widget? trailing;

  /// For Log Out.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: color ?? colorScheme.onSurfaceVariant),
      title: Text(label, style: textTheme.bodyLarge?.copyWith(color: color ?? colorScheme.onSurface)),
      trailing: trailing ??
          ((count ?? 0) > 0
              ? Text('$count', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))
              : null),
      onTap: onTap,
    );
  }
}

/// Flarum signs a new account in before its email is confirmed, with only a guest's permissions
/// until then: where the link went, and Resend, as the website's banner offers.
class _ConfirmEmail extends StatefulWidget {
  const _ConfirmEmail({required this.forum, required this.reader});

  final FlarumForum forum;
  final FlarumUser reader;

  @override
  State<_ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<_ConfirmEmail> {
  bool _sending = false;

  Future<void> _resend() async {
    final l10n = flarumL10n(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await widget.forum.api.sendEmailConfirmation(widget.reader.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.confirmationEmailSent)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(describeError(context, e))));
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final email = widget.forum.info?.actorEmail;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingM),
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingS, DesignTokens.spacingXS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.mark_email_unread_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(child: Text(l10n.confirmEmailTitle, style: theme.textTheme.titleMedium)),
              ]),
              const SizedBox(height: DesignTokens.spacingXS),
              Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spacingS),
                child: Text(email == null ? l10n.confirmEmailTextNoAddress : l10n.confirmEmailText(email),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(onPressed: _sending ? null : _resend, child: Text(l10n.resendConfirmationEmail)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
