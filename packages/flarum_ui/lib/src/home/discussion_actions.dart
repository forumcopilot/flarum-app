import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../navigation/web_links.dart';
import '../render/links.dart';
import 'discussion_list_model.dart';

/// Marks [d] read to its last post, as the web does from a row's unread count, and puts the row
/// right. Says why when it can't.
Future<void> markDiscussionRead(BuildContext context, DiscussionListModel list, FlarumDiscussion d) async {
  final last = d.lastPostNumber;
  if (last == null) return;
  try {
    await list.forum.api.markDiscussionRead(d.id, last);
  } catch (e) {
    if (context.mounted) SnackbarHelper.showError(context, describeError(context, e));
    return;
  }
  await list.reload(d.id);
}

/// A discussion's controls, from a long press on its row, as the web's row menu offers them to a
/// reader: Mark as Read, its Follow level, Bookmark, Share and Copy Link.
Future<void> showDiscussionActions(
  BuildContext context,
  SiteContext site,
  DiscussionListModel list,
  FlarumDiscussion d,
) {
  final forum = list.forum;
  final signedIn = forum.isSignedIn;
  final link = WebLinks.discussion(site, d.id, slug: d.slug);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final l10n = flarumL10n(sheet);
      final theme = Theme.of(sheet);
      Future<void> run(Future<void> Function() action) async {
        Navigator.pop(sheet);
        await action();
      }

      Future<void> change(Future<FlarumDiscussion> Function() request) => run(() async {
            try {
              await request();
            } catch (e) {
              if (context.mounted) SnackbarHelper.showError(context, describeError(context, e));
              return;
            }
            await list.reload(d.id);
          });

      Widget level(String? value, IconData icon, String label) => ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: d.subscription == value ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
            onTap: d.subscription == value ? () => Navigator.pop(sheet) : () => change(() => forum.api.setSubscription(d.id, value)),
          );

      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                child: Text(d.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (signedIn && list.unreadIn(d) > 0)
                ListTile(
                  leading: const Icon(Icons.done),
                  title: Text(l10n.markAsRead),
                  onTap: () => run(() => markDiscussionRead(context, list, d)),
                ),
              if (signedIn) ...[
                const Divider(height: 1),
                level(null, Icons.star_border, l10n.notFollowing),
                level('follow', Icons.star, l10n.following),
                level('ignore', Icons.visibility_off, l10n.ignoring),
                const Divider(height: 1),
              ],
              if (signedIn && forum.extensions.bookmarks)
                ListTile(
                  leading: Icon(d.bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  title: Text(d.bookmarked ? l10n.removeBookmark : l10n.bookmark),
                  onTap: () => change(() => forum.api.bookmarkDiscussion(d.id, bookmarked: !d.bookmarked)),
                ),
              Builder(
                builder: (tile) => ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(l10n.share),
                  onTap: () {
                    // Where an iPad points the share sheet from: read before this sheet goes.
                    final box = tile.findRenderObject();
                    final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
                    run(() => shareLink(link, origin: origin));
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(l10n.copyLink),
                onTap: () => run(() => copyLink(context, link)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
