import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/flarum_content.dart';
import '../render/flarum_html.dart';

/// The forum's welcome message over its discussions, as the web's welcome hero shows it: the
/// title, the message, and ✕ to hide it. Hidden, it stays hidden on this phone until the forum
/// changes its message.
class WelcomeHero extends StatefulWidget {
  const WelcomeHero({super.key, required this.site, this.title, this.message});

  final SiteContext site;
  final String? title;

  /// The message's HTML.
  final String? message;

  @override
  State<WelcomeHero> createState() => _WelcomeHeroState();
}

class _WelcomeHeroState extends State<WelcomeHero> {
  /// Null until the phone says whether this message was hidden.
  bool? _hidden;

  String get _key => 'flarum_ui.welcome_hidden.${widget.site.site.pluginUrl}';

  /// What was hidden: a change of title or message shows the hero again, as the web's does.
  String get _fingerprint => '${widget.title ?? ''}\u0000${widget.message ?? ''}'.hashCode.toRadixString(16);

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    var hidden = false;
    try {
      hidden = (await SharedPreferences.getInstance()).getString(_key) == _fingerprint;
    } catch (_) {
      // Shown, then.
    }
    if (mounted) setState(() => _hidden = hidden);
  }

  Future<void> _hide() async {
    setState(() => _hidden = true);
    try {
      await (await SharedPreferences.getInstance()).setString(_key, _fingerprint);
    } catch (_) {
      // Hidden for this run.
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final message = widget.message;
    if (_hidden != false || (title == null && message == null)) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      color: colorScheme.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingXS, DesignTokens.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) Text(title, style: theme.textTheme.titleMedium),
                  if (message != null) ...[
                    const SizedBox(height: DesignTokens.spacingXS),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      child: FlarumContent(
                        siteContext: widget.site,
                        content: FlarumHtml.parse(message, forumBaseUrl: widget.site.site.url).html,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: flarumL10n(context).hideWelcomeMessage,
            onPressed: _hide,
          ),
        ],
      ),
    );
  }
}
