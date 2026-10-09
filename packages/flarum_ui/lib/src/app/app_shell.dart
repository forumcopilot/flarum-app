import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/home_page.dart';
import '../tags/tags_page.dart';

/// The app's top level: the forum's discussions and its tags, one tab each.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.site});

  final SiteContext site;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomePage(site: widget.site, title: widget.site.site.name),
          TagsPage(site: widget.site),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.sell_outlined), selectedIcon: const Icon(Icons.sell), label: l10n.tags),
        ],
      ),
    );
  }
}
