import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import 'ignored_users.dart';

/// Ignores [user] after asking, or stops ignoring them, from a post's menu or their profile; says
/// why if the forum refuses.
Future<void> toggleIgnore(BuildContext context, SiteContext site, FlarumUser user) async {
  final l10n = flarumL10n(context);
  final ignored = IgnoredUsers.of(site);
  final ignoring = !ignored.isIgnored(user);
  if (ignoring) {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.ignoreUserConfirm(user.displayName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(kitL10n(context).cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.ignoreUser(user.displayName))),
        ],
      ),
    );
    if (sure != true) return;
  }
  try {
    await ignored.setIgnored(user, ignoring);
  } catch (e) {
    if (context.mounted) SnackbarHelper.showError(context, describeError(context, e));
  }
}
