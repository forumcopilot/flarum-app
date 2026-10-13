import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/links.dart';

/// Reports a post to the forum's moderators (flarum/flags), with the web's reasons: off-topic,
/// inappropriate, spam, or the reporter's own words. Pops true once the forum has the report.
class FlagPostPage extends StatefulWidget {
  const FlagPostPage({super.key, required this.site, required this.post});

  final SiteContext site;
  final FlarumPost post;

  /// Opens the page; true when the post was reported.
  static Future<bool> open(BuildContext context, SiteContext site, FlarumPost post) async =>
      await Navigator.of(context).push<bool>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FlagPostPage(site: site, post: post),
      )) ??
      false;

  @override
  State<FlagPostPage> createState() => _FlagPostPageState();
}

/// The reasons the forum knows, and "Other" (null), which needs the reporter's words.
const _reasons = ['off_topic', 'inappropriate', 'spam', null];

class _FlagPostPageState extends State<FlagPostPage> {
  final _details = TextEditingController();
  String? _reason;
  bool _chosen = false;
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = flarumL10n(context);
    final detail = _details.text.trim();
    if (_reason == null && detail.isEmpty) {
      SnackbarHelper.showError(context, l10n.flagDetailsNeeded);
      return;
    }
    setState(() => _sending = true);
    try {
      await FlarumForum.of(widget.site).api.flagPost(widget.post.id, reason: _reason, detail: detail);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final textTheme = Theme.of(context).textTheme;
    final guidelines = FlarumForum.of(widget.site).info?.guidelinesUrl;
    (String, String?) describe(String? reason) => switch (reason) {
          'off_topic' => (l10n.flagReasonOffTopic, l10n.flagReasonOffTopicText),
          'inappropriate' => (l10n.flagReasonInappropriate, l10n.flagReasonInappropriateText),
          'spam' => (l10n.flagReasonSpam, l10n.flagReasonSpamText),
          _ => (l10n.flagReasonOther, null),
        };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flagPostTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(
              onPressed: _chosen && !_sending ? _send : null,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.flagAction),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        children: [
          RadioGroup<String?>(
            groupValue: _chosen ? _reason : '',
            onChanged: (reason) => setState(() {
              _reason = reason;
              _chosen = true;
            }),
            child: Column(
              children: [
                for (final reason in _reasons)
                  RadioListTile<String?>(
                    value: reason,
                    enabled: !_sending,
                    title: Text(describe(reason).$1),
                    subtitle: describe(reason).$2 == null ? null : Text(describe(reason).$2!),
                  ),
              ],
            ),
          ),
          if (guidelines != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
                child: TextButton.icon(
                  onPressed: () => openExternally(guidelines),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.communityGuidelines),
                ),
              ),
            ),
          if (_chosen)
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: TextField(
                controller: _details,
                enabled: !_sending,
                autofocus: _reason == null,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _reason == null ? describe(null).$1 : l10n.flagDetails,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                style: textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}
