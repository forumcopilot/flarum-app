import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';
import 'ignored_users.dart';

/// Everyone the reader ignores, each a tap from being seen again: the forum's list
/// (fof/ignore-users), or the one the app keeps on the phone.
class IgnoredUsersPage extends StatefulWidget {
  const IgnoredUsersPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => IgnoredUsersPage(site: site)));

  @override
  State<IgnoredUsersPage> createState() => _IgnoredUsersPageState();
}

class _IgnoredUsersPageState extends State<IgnoredUsersPage> {
  late final IgnoredUsers _ignored = IgnoredUsers.of(widget.site);
  List<FlarumUser>? _users;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final users = await _ignored.list();
      if (mounted) setState(() => _users = users);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _stopIgnoring(FlarumUser user) async {
    try {
      await _ignored.setIgnored(user, false);
      if (mounted) setState(() => _users = [for (final u in _users!) if (u.id != user.id) u]);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final users = _users;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ignoredUsers)),
      body: switch ((users, _error)) {
        (_, final error?) => EmptyStateView.error(
            message: l10n.ignoredUsers,
            hint: describeError(context, error),
            onRetry: () {
              setState(() => _error = null);
              _load();
            },
          ),
        (null, _) => const Center(child: CircularProgressIndicator()),
        (final users?, _) => ListView(
            children: [
              if (!_ignored.forumKeepsList)
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingL),
                  child: Text(l10n.ignoredOnThisPhone,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              if (users.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingXL),
                  child: Text(l10n.ignoredUsersEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                ),
              for (final user in users)
                ListTile(
                  leading: FlarumAvatar(user: user),
                  title: Text(user.displayName),
                  subtitle: user.displayName == user.username ? null : Text('@${user.username}'),
                  trailing: TextButton(onPressed: () => _stopIgnoring(user), child: Text(l10n.stopIgnoring)),
                ),
            ],
          ),
      },
    );
  }
}
