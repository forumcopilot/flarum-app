import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/account_page.dart';
import '../home/home_page.dart';
import '../tags/tags_page.dart';

/// The app's top level: the forum's discussions, its tags, and the reader's
/// account, one tab each. Signing in or out starts the other tabs afresh.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.site});

  final SiteContext site;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  /// Bumped on sign-in and sign-out, so the lists reload as the new reader.
  int _session = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomePage(key: ValueKey(('home', _session)), site: widget.site, title: widget.site.site.name),
          TagsPage(key: ValueKey(('tags', _session)), site: widget.site),
          AccountPage(site: widget.site, onSignInChanged: () => setState(() => _session++)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.sell_outlined), selectedIcon: const Icon(Icons.sell), label: l10n.tags),
          NavigationDestination(
              icon: const Icon(Icons.account_circle_outlined),
              selectedIcon: const Icon(Icons.account_circle),
              label: l10n.account),
        ],
      ),
    );
  }
}
