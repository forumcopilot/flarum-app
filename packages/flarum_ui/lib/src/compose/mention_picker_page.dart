import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';

/// Finds a member to @-mention: a search field and the members it matches, through the forum's
/// user search (its search-users permission). Pops the chosen [FlarumUser].
class MentionPickerPage extends StatefulWidget {
  const MentionPickerPage({super.key, required this.site});

  final SiteContext site;

  static Future<FlarumUser?> open(BuildContext context, SiteContext site) => Navigator.of(context).push(
        MaterialPageRoute<FlarumUser>(fullscreenDialog: true, builder: (_) => MentionPickerPage(site: site)),
      );

  @override
  State<MentionPickerPage> createState() => _MentionPickerPageState();
}

class _MentionPickerPageState extends State<MentionPickerPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _query = TextEditingController();
  Timer? _debounce;
  List<FlarumUser>? _users;
  Object? _error;
  bool _loading = false;

  /// The search whose answer is wanted: a slower earlier one is dropped.
  int _searches = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(text.trim()));
  }

  Future<void> _search(String text) async {
    final search = ++_searches;
    if (text.length < 2) {
      setState(() {
        _users = null;
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final page = await _forum.api.searchUsers(text, limit: 20);
      if (!mounted || search != _searches) return;
      setState(() {
        _users = page.items;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || search != _searches) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final users = _users;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.searchUsers, border: InputBorder.none),
          textInputAction: TextInputAction.search,
          onChanged: _changed,
          onSubmitted: (text) => _search(text.trim()),
        ),
      ),
      body: switch ((users, _error)) {
        (_, FlarumApiException(isForbidden: true)) =>
          EmptyStateView(icon: Icons.person_search, message: l10n.memberSearchNotAllowed),
        (_, final Object error) => EmptyStateView.error(
            message: describeFlarumError(error),
            onRetry: () => _search(_query.text.trim()),
          ),
        _ when _loading => const Center(child: CircularProgressIndicator()),
        (final List<FlarumUser> users, _) when users.isEmpty =>
          EmptyStateView(icon: Icons.person_search, message: l10n.noMembersFound),
        (final List<FlarumUser> users, _) => ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) => ListTile(
              leading: FlarumAvatar(user: users[i], radius: 18),
              title: Text(users[i].displayName),
              subtitle: users[i].displayName == users[i].username ? null : Text('@${users[i].username}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
              onTap: () => Navigator.of(context).pop(users[i]),
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
