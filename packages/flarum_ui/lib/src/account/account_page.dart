import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/links.dart';
import '../../config/app_forum_config.dart';
import '../app/appearance.dart';
import '../app/debug_forums.dart';
import '../bookmarks/bookmarks_page.dart';
import '../private/private_discussions_page.dart';
import '../safety/ignored_users_page.dart';
import 'sign_in_page.dart';
import '../widgets/flarum_avatar.dart';

/// The reader's account: sign in (or create an account on the forum's
/// page), or who is signed in, and sign out; and the app's appearance.
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

  Future<void> _signIn() async {
    if (await SignInPage.open(context, widget.site)) {
      if (mounted) setState(() {});
      widget.onSignInChanged?.call();
    }
  }

  /// Signs out here even when the forum can't be reached (the token then
  /// stays valid there until it expires or is revoked on the web).
  Future<void> _signOut() async {
    setState(() => _busy = true);
    await FlarumUserProxy(widget.site).logoutUserAsync();
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onSignInChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final reader = _forum.isSignedIn ? _forum.info?.actor : null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        children: [
          if (reader == null) ...[
            Text(l10n.signInHint, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: DesignTokens.spacingXL),
            FilledButton(onPressed: _signIn, child: Text(l10n.signIn)),
            // Sign-up happens on the forum's page, when the forum takes new members.
            if (_forum.info?.allowSignUp ?? false) ...[
              const SizedBox(height: DesignTokens.spacingS),
              OutlinedButton(
                onPressed: () => openExternally(widget.site.site.url),
                child: Text(l10n.createAccount),
              ),
            ],
          ] else ...[
            Center(child: FlarumAvatar(user: reader, radius: 40)),
            const SizedBox(height: DesignTokens.spacingM),
            Text(reader.displayName, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            Text(l10n.signedInAs('@${reader.username}'),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: DesignTokens.spacingXL),
            if (_forum.extensions.bookmarks) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bookmark_border),
                title: Text(l10n.bookmarks),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => BookmarksPage.open(context, widget.site),
              ),
            ],
            if (_forum.extensions.byobu)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.privateDiscussions),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => PrivateDiscussionsPage.open(context, widget.site),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_off_outlined),
              title: Text(l10n.ignoredUsers),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => IgnoredUsersPage.open(context, widget.site),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            OutlinedButton.icon(
              onPressed: _busy ? null : _signOut,
              icon: _busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),
          ],
          if (widget.appearance case final appearance?) ...[
            const SizedBox(height: DesignTokens.spacingXXL),
            Text(l10n.appearance, style: theme.textTheme.titleSmall),
            const SizedBox(height: DesignTokens.spacingS),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appearance,
              builder: (context, mode, _) => SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(l10n.appearanceSystem)),
                  ButtonSegment(value: ThemeMode.light, label: Text(l10n.light)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(l10n.dark)),
                ],
                selected: {mode},
                onSelectionChanged: (choice) => appearance.choose(choice.single),
              ),
            ),
          ],
          if (showForumSwitcher && widget.onSwitchForum != null) ...[
            const SizedBox(height: DesignTokens.spacingXXL),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Forum (debug)'),
              subtitle: Text(widget.site.site.url),
              onTap: () async {
                final forum = await DebugForumPage.open(context, widget.site.site.url);
                if (forum != null) await widget.onSwitchForum!(forum);
              },
            ),
          ],
        ],
      ),
    );
  }
}
