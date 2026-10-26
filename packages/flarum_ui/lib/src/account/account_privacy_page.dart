import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/section_header.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../safety/ignored_users_page.dart';
import 'forum_web_page.dart';

/// The reader's account and privacy, as the Discourse app groups them: who they ignore, here, and
/// the rest of the forum's settings (email, password, nickname, the forum's own extensions') on
/// its settings page, which the app opens logged in as the reader.
class AccountPrivacyPage extends StatelessWidget {
  const AccountPrivacyPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AccountPrivacyPage(site: site)));

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountAndPrivacy)),
      body: ListView(
        children: [
          SectionHeader(l10n.privacy),
          ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: Text(l10n.ignoredUsers),
            subtitle: Text(l10n.ignoredUsersHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => IgnoredUsersPage.open(context, site),
          ),
          SectionHeader(l10n.account),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(l10n.forumSettingsPage),
            subtitle: Text(l10n.forumSettingsPageHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ForumWebPage.open(context, site, path: '/settings', title: l10n.settings),
          ),
        ],
      ),
    );
  }
}
