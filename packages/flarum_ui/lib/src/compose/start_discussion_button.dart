import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import 'composers.dart';

/// The Start a discussion button for a list of discussions (a tag's, with [tag]), when the
/// reader may start one there; null when they may not. It opens the composer, then the new
/// discussion; [onStarted] refreshes the list behind it.
Widget? startDiscussionButton(BuildContext context, SiteContext site, {FlarumTag? tag, VoidCallback? onStarted}) {
  final forum = FlarumForum.of(site);
  if (!forum.isSignedIn || !(forum.info?.can('canStartDiscussion') ?? false)) return null;
  if (tag != null && !tag.canStartDiscussion) return null;
  final l10n = flarumL10n(context);
  return FloatingActionButton.extended(
    onPressed: () async {
      final discussion = await composeDiscussion(context, site, tag: tag);
      if (discussion == null || !context.mounted) return;
      onStarted?.call();
      if (!discussion.isApproved) {
        SnackbarHelper.showInfo(context, l10n.postAwaitingApproval);
        return;
      }
      ThreadPage.open(context, site, discussion.id, title: discussion.title);
    },
    icon: const Icon(Icons.edit_outlined),
    label: Text(l10n.startDiscussion),
  );
}
