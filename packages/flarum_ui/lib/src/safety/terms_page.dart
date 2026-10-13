import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/links.dart';

/// The policies the reader must accept before they may post again (fof/terms): until they do, the
/// forum gives them a guest's permissions. Each links to its text; Accept accepts them all. Pops
/// true once accepted, with the forum's info read again.
class TermsPage extends StatefulWidget {
  const TermsPage({super.key, required this.site});

  final SiteContext site;

  static Future<bool> open(BuildContext context, SiteContext site) async =>
      await Navigator.of(context).push<bool>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TermsPage(site: site),
      )) ??
      false;

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final List<FlarumPolicy> _policies = _forum.info?.policiesToAccept ?? const [];
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      for (final policy in _policies) {
        await _forum.api.acceptPolicy(policy.id);
      }
      // The reader's permissions, back as they were.
      await _forum.refresh();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _accepting = false);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Text(l10n.termsIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: DesignTokens.spacingL),
          for (final policy in _policies)
            Card(
              child: ListTile(
                title: Text(policy.name),
                subtitle: policy.updateMessage == null ? null : Text(policy.updateMessage!),
                trailing: policy.url == null
                    ? null
                    : TextButton(onPressed: () => openExternally(policy.url!), child: Text(l10n.readPolicy)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child: FilledButton(
            onPressed: _accepting || _policies.isEmpty ? null : _accept,
            child: _accepting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.acceptTerms),
          ),
        ),
      ),
    );
  }
}

/// Above the tabs while the reader has policies to accept: what's wrong, and the way to fix it.
class TermsStrip extends StatelessWidget {
  const TermsStrip({super.key, required this.onReview});

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            DesignTokens.spacingL, DesignTokens.spacingXS, DesignTokens.spacingS, DesignTokens.spacingXS),
        child: Row(
          children: [
            Icon(Icons.policy_outlined, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(child: Text(l10n.termsBanner, style: TextStyle(color: colorScheme.onSecondaryContainer))),
            TextButton(onPressed: onReview, child: Text(l10n.termsReview)),
          ],
        ),
      ),
    );
  }
}
