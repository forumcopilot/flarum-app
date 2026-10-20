import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/composers.dart';
import '../thread/thread_page.dart';

/// The reader's drafts (fof/drafts), the latest first: a reply opens in its discussion's composer,
/// a new discussion or a private one in theirs, and posting it deletes the draft. Drafts are saved
/// from the composer, when it's closed.
class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DraftsPage(site: site)));

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _drafts = <FlarumDraft>[];
  bool _loading = false;
  bool _hasMore = false;
  Object? _error;

  /// The titles of the discussions reply drafts are for, as they're read.
  final _titles = <String, String>{};

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _refresh() async {
    await _load(reset: true);
    // Failed over the list it had: it stays, and the reader learns why it didn't change.
    final error = _error;
    if (error != null && _drafts.isNotEmpty && mounted) SnackbarHelper.showError(context, describeError(context, error));
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final page = await _forum.api.drafts(offset: reset ? 0 : _drafts.length);
      if (!mounted) return;
      setState(() {
        if (reset) _drafts.clear();
        _drafts.addAll(page.items);
        _hasMore = page.hasMore;
      });
      _readTitles(page.items);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _readTitles(List<FlarumDraft> drafts) {
    for (final id in {for (final draft in drafts) if (draft.discussionId case final id?) id}) {
      if (_titles.containsKey(id)) continue;
      _forum.api.discussion(id).then((discussion) {
        if (mounted) setState(() => _titles[id] = discussion.title);
      }, onError: (_) {});
    }
  }

  Future<void> _resume(FlarumDraft draft) async {
    final Object? posted;
    try {
      posted = await resumeDraft(context, widget.site, draft);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
      return;
    }
    if (!mounted) return;
    switch (posted) {
      case FlarumPost(:final discussionId?, :final number):
        await ThreadPage.open(context, widget.site, discussionId, near: number);
      case FlarumDiscussion(:final id, :final title):
        await ThreadPage.open(context, widget.site, id, title: title);
    }
    if (mounted) _load(reset: true);
  }

  Future<void> _delete(FlarumDraft draft) async {
    final l10n = flarumL10n(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.deleteDraftQuestion),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(kitL10n(context).cancel)),
          TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(kitL10n(context).delete)),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await _forum.api.deleteDraft(draft.id);
      if (!mounted) return;
      setState(() => _drafts.removeWhere((d) => d.id == draft.id));
      _forum.refresh().ignore();
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drafts)),
      body: RefreshIndicator(onRefresh: _refresh, child: _body(l10n)),
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    if (_drafts.isEmpty) {
      if (_error != null) {
        return EmptyStateView.error(message: l10n.draftsLoadFailed, hint: describeError(context, _error), onRetry: _refresh);
      }
      if (_loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView.scrollable(icon: Icons.edit_note, message: l10n.noDrafts);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400 && _hasMore && _error == null) _load(reset: false);
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _drafts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final draft = _drafts[i];
          return _DraftTile(
            draft: draft,
            title: switch (draft.discussionId) {
              final id? => l10n.draftReplyTo(_titles[id] ?? '…'),
              null => draft.title ?? l10n.draftUntitled,
            },
            onTap: () => _resume(draft),
            onDelete: () => _delete(draft),
          );
        },
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.draft, required this.title, required this.onTap, required this.onDelete});

  final FlarumDraft draft;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final updated = draft.updatedAt;
    final text = draft.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
      leading: Icon(
        draft.isReply
            ? Icons.reply
            : draft.isPrivateDiscussion
                ? Icons.map_outlined
                : Icons.forum_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [if (updated != null) formatTimeAgo(updated.toLocal(), context), text].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: flarumL10n(context).deleteDraft,
        onPressed: onDelete,
      ),
    );
  }
}
