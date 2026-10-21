import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';

/// The notification part of the forum's settings page: for each kind of notification the forum
/// sends (as its extensions name them), whether it comes on the web (the forum's list, and the
/// app's Notifications) and by email; then flarum/subscriptions' follow settings. Each change is
/// saved at once.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NotificationSettingsPage(site: site)));

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  Map<String, Object?> _prefs = const {};
  bool _loading = true;

  /// The kinds the web's settings grid lists, in its words, in the order a reader thinks of them.
  static List<(String, String Function(FlarumLocalizations))> get _kinds => [
        ('newPost', (l) => l.notifyPrefNewPost),
        ('postMentioned', (l) => l.notifyPrefPostMentioned),
        ('userMentioned', (l) => l.notifyPrefUserMentioned),
        ('groupMentioned', (l) => l.notifyPrefGroupMentioned),
        ('postLiked', (l) => l.notifyPrefPostLiked),
        ('postReacted', (l) => l.notifyPrefPostReacted),
        ('discussionRenamed', (l) => l.notifyPrefDiscussionRenamed),
        ('discussionLocked', (l) => l.notifyPrefDiscussionLocked),
        ('messageReceived', (l) => l.notifyPrefMessageReceived),
        ('byobuPrivateDiscussionCreated', (l) => l.notifyPrefByobuPrivateDiscussionCreated),
        ('byobuPrivateDiscussionReplied', (l) => l.notifyPrefByobuPrivateDiscussionReplied),
        ('byobuPrivateDiscussionAdded', (l) => l.notifyPrefByobuPrivateDiscussionAdded),
        ('byobuRecipientRemoved', (l) => l.notifyPrefByobuRecipientRemoved),
        ('awardedBestAnswer', (l) => l.notifyPrefAwardedBestAnswer),
        ('bestAnswerInDiscussion', (l) => l.notifyPrefBestAnswerInDiscussion),
        ('selectBestAnswer', (l) => l.notifyPrefSelectBestAnswer),
        ('newDiscussionInTag', (l) => l.notifyPrefNewDiscussionInTag),
        ('newPostInTag', (l) => l.notifyPrefNewPostInTag),
        ('newDiscussionTag', (l) => l.notifyPrefNewDiscussionTag),
      ];

  @override
  void initState() {
    super.initState();
    _forum.refresh().then((info) {
      if (mounted) setState(() => _prefs = Map.of(info.preferences));
    }, onError: (Object e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    }).whenComplete(() {
      if (mounted) setState(() => _loading = false);
    });
  }

  bool? _value(String key) => switch (_prefs[key]) {
        final bool value => value,
        final num value => value != 0,
        final String value => value == '1' || value == 'true',
        _ => null,
      };

  /// Saves one setting at once; put back, with why, if the forum refuses.
  Future<void> _set(String key, bool value) async {
    final reader = _forum.info?.actor?.id;
    if (reader == null) return;
    final before = _prefs[key];
    setState(() => _prefs[key] = value);
    try {
      await _forum.api.savePreferences(reader, {key: value});
    } catch (e) {
      if (!mounted) return;
      setState(() => _prefs[key] = before);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final kinds = [
      for (final (kind, label) in _kinds)
        if (_prefs.containsKey('notify_${kind}_alert') || _prefs.containsKey('notify_${kind}_email')) (kind, label(l10n)),
    ];
    Widget column(IconData icon, String label) => SizedBox(
          width: 56,
          child: Semantics(
            label: label,
            child: Tooltip(message: label, child: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant)),
          ),
        );
    Widget box(String key) {
      final value = _value(key);
      return SizedBox(
        width: 56,
        child: value == null ? const SizedBox.shrink() : Checkbox(value: value, onChanged: (v) => _set(key, v ?? false)),
      );
    }

    Widget toggle(String key, String label) => SwitchListTile(
          title: Text(label),
          value: _value(key) ?? false,
          onChanged: (v) => _set(key, v),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: _loading && _prefs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingS, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      column(Icons.notifications_outlined, l10n.notifyByWeb),
                      column(Icons.mail_outline, l10n.notifyByEmail),
                    ],
                  ),
                ),
                for (final (kind, label) in kinds)
                  MergeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingS, 0),
                      child: Row(
                        children: [
                          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                          box('notify_${kind}_alert'),
                          box('notify_${kind}_email'),
                        ],
                      ),
                    ),
                  ),
                if (['followAfterReply', 'followAfterCreate', 'flarum-subscriptions.notify_for_all_posts']
                    .any(_prefs.containsKey))
                  const Divider(height: DesignTokens.spacingXL),
                if (_prefs.containsKey('followAfterReply')) toggle('followAfterReply', l10n.followAfterReply),
                if (_prefs.containsKey('followAfterCreate')) toggle('followAfterCreate', l10n.followAfterCreate),
                if (_prefs.containsKey('flarum-subscriptions.notify_for_all_posts'))
                  toggle('flarum-subscriptions.notify_for_all_posts', l10n.notifyForAllPosts),
              ],
            ),
    );
  }
}
