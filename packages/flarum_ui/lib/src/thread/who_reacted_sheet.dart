import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/sheet_title.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';
import 'post_actions_row.dart' show reactionGlyph;

/// A page of everyone who liked a post, from [offset] (`FlarumApi.likers`).
typedef LikersLoader = Future<FlarumPage<FlarumUser>> Function(int offset);

/// A page of who reacted to a post, from [offset] (`FlarumApi.postReactions`).
typedef ReactionsLoader = Future<FlarumPage<FlarumPostReaction>> Function(int offset);

/// Who liked and reacted to a post, as the Discourse app's sheet of who reacted: a chip for
/// everyone, the likes and each reaction used, with their counts (when there's more than one kind),
/// and a row per person with what they gave, the reader first as "You".
///
/// The likers the post carries (up to four) show at once; everyone loads after, for a reader who
/// may search users ([loadLikers]), and the rest are counted where they can't be named. Who reacted
/// loads where the reader may see it ([loadReactions], fof/reactions' `canSeeReactions`, which no
/// group has by default); elsewhere the reactions show their counts.
class WhoReactedSheet extends StatefulWidget {
  const WhoReactedSheet({
    super.key,
    required this.post,
    this.reactions = const [],
    this.readerId,
    this.loadLikers,
    this.loadReactions,
    this.likesLabel,
    this.onOpenUser,
    this.onReact,
  });

  final FlarumPost post;

  /// The reactions the forum offers, in its order.
  final List<FlarumReaction> reactions;
  final String? readerId;
  final LikersLoader? loadLikers;
  final ReactionsLoader? loadReactions;

  /// Who likes the post, as flarum/likes words it, under the likes when they can't all be named.
  final String? likesLabel;
  final void Function(FlarumUser user)? onOpenUser;

  /// Opens the reaction picker; null when the reader may not react.
  final VoidCallback? onReact;

  static Future<void> show(
    BuildContext context, {
    required FlarumPost post,
    List<FlarumReaction> reactions = const [],
    String? readerId,
    LikersLoader? loadLikers,
    ReactionsLoader? loadReactions,
    String? likesLabel,
    void Function(FlarumUser user)? onOpenUser,
    VoidCallback? onReact,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => WhoReactedSheet(
          post: post,
          reactions: reactions,
          readerId: readerId,
          loadLikers: loadLikers,
          loadReactions: loadReactions,
          likesLabel: likesLabel,
          onOpenUser: onOpenUser,
          onReact: onReact,
        ),
      );

  @override
  State<WhoReactedSheet> createState() => _WhoReactedSheetState();
}

/// The chip for the likes; the reactions' chips are their ids.
const _likes = 'likes';

class _WhoReactedSheetState extends State<WhoReactedSheet> {
  /// Null for everyone, [_likes], or a reaction's id.
  String? _filter;

  late List<FlarumUser> _likers = widget.post.likedBy;
  bool _likersHaveMore = false;

  /// Null until loaded, or where the reader may not see who reacted.
  List<FlarumPostReaction>? _reactors;
  bool _reactorsHaveMore = false;
  bool _loading = false;

  FlarumPost get _post => widget.post;

  /// The post's reactions with any count, the most used first.
  List<(FlarumReaction, int)> get _used => [
        for (final r in widget.reactions)
          if ((_post.reactionCounts[r.id] ?? 0) > 0) (r, _post.reactionCounts[r.id]!),
      ]..sort((a, b) => b.$2.compareTo(a.$2));

  @override
  void initState() {
    super.initState();
    _load(likers: _likers.length < _post.likesCount, reactors: _used.isNotEmpty);
  }

  Future<void> _load({required bool likers, required bool reactors}) async {
    final loadLikers = likers ? widget.loadLikers : null;
    final loadReactions = reactors ? widget.loadReactions : null;
    if (loadLikers == null && loadReactions == null) return;
    setState(() => _loading = true);
    // Either can fail (a forum that refuses the reader): what the post carries stays.
    await Future.wait([
      if (loadLikers != null)
        _attempt(() async {
          final more = _likersHaveMore;
          final page = await loadLikers(more ? _likers.length : 0);
          if (!mounted) return;
          setState(() {
            _likers = [if (more) ..._likers, ...page.items];
            _likersHaveMore = page.hasMore;
          });
        }),
      if (loadReactions != null)
        _attempt(() async {
          final loaded = _reactors ?? const [];
          final page = await loadReactions(_reactorsHaveMore ? loaded.length : 0);
          if (!mounted) return;
          setState(() {
            _reactors = [if (_reactorsHaveMore) ...loaded, ...page.items];
            _reactorsHaveMore = page.hasMore;
          });
        }),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _attempt(Future<void> Function() load) async {
    try {
      await load();
    } on FlarumApiException {
      // Shown as counted.
    }
  }

  /// Everyone named, each with what they gave, the reader first.
  List<_Person> get _people {
    final byId = <String, _Person>{};
    for (final user in _likers) {
      byId[user.id] = _Person(user, liked: true);
    }
    for (final r in _reactors ?? const <FlarumPostReaction>[]) {
      final user = r.user;
      if (user == null) continue;
      byId[user.id] = _Person(user, liked: byId[user.id]?.liked ?? false, reactionId: r.reactionId);
    }
    final people = byId.values.toList();
    final reader = people.indexWhere((p) => p.user.id == widget.readerId);
    if (reader > 0) people.insert(0, people.removeAt(reader));
    return people;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final used = _used;
    final named = _reactors != null;
    final total = _post.likesCount + used.fold<int>(0, (sum, r) => sum + r.$2);
    final kinds = (_post.likesCount > 0 ? 1 : 0) + (named ? used.length : 0);

    final people = [
      for (final p in _people)
        if (_filter == null || (_filter == _likes ? p.liked : p.reactionId == _filter)) p,
    ];
    // Those the forum counts but didn't name: likers past what loaded, anonymous reactions.
    final likesUnnamed = _likersHaveMore ? 0 : _post.likesCount - _likers.length;
    final reactionsUnnamed = !named || _reactorsHaveMore
        ? 0
        : [
            for (final (r, count) in used)
              if (_filter == null || _filter == r.id) count - _reactors!.where((x) => x.reactionId == r.id && x.user != null).length,
          ].fold<int>(0, (sum, n) => sum + n);
    final unnamed = (_filter == null || _filter == _likes ? likesUnnamed : 0) + reactionsUnnamed;
    final hasMore = switch (_filter) {
      null => _likersHaveMore || _reactorsHaveMore,
      _likes => _likersHaveMore,
      _ => _reactorsHaveMore,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(l10n.likesAndReactions),
            if (kinds > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                child: Row(
                  children: [
                    _chip(null, Text(kitL10n(context).all), total, '${kitL10n(context).all}, $total'),
                    if (_post.likesCount > 0)
                      _chip(_likes, Icon(Icons.thumb_up, size: DesignTokens.iconSizeS, color: theme.colorScheme.primary),
                          _post.likesCount, '${l10n.likesTab}, ${_post.likesCount}'),
                    for (final (reaction, count) in used)
                      _chip(reaction.id, Text(reactionGlyph(reaction), style: const TextStyle(fontSize: 16)), count,
                          '${reaction.display ?? reaction.identifier}, $count'),
                  ],
                ),
              ),
            SizedBox(height: 2, child: _loading ? const LinearProgressIndicator() : null),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                children: [
                  for (final person in people)
                    _PersonRow(
                      person: person,
                      isReader: person.user.id == widget.readerId,
                      // What they gave, where it isn't the chip's.
                      liked: person.liked && _filter != _likes,
                      reaction: _filter == null || _filter == _likes
                          ? widget.reactions.where((r) => r.id == person.reactionId).firstOrNull
                          : null,
                      onTap: widget.onOpenUser == null
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              widget.onOpenUser!(person.user);
                            },
                    ),
                  if (unnamed > 0)
                    ListTile(
                      leading: const SizedBox(width: 36),
                      // With no one named, flarum/likes' own words ("6 people like this").
                      title: Text(
                          people.isEmpty && reactionsUnnamed == 0 && widget.likesLabel != null
                              ? widget.likesLabel!
                              : l10n.andOthers(unnamed),
                          style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                    ),
                  if (hasMore)
                    Center(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => _load(
                                  likers: _filter != null && _filter != _likes ? false : _likersHaveMore,
                                  reactors: _filter == _likes ? false : _reactorsHaveMore,
                                ),
                        child: Text(l10n.loadMore),
                      ),
                    ),
                  // Without who reacted, how many used each reaction.
                  if (!named && used.isNotEmpty) ...[
                    if (people.isNotEmpty || unnamed > 0)
                      const Divider(indent: DesignTokens.spacingL, endIndent: DesignTokens.spacingL),
                    ListTile(dense: true, title: Text(l10n.reactions, style: theme.textTheme.titleSmall)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
                      child: Wrap(
                        spacing: DesignTokens.spacingS,
                        runSpacing: DesignTokens.spacingS,
                        children: [
                          for (final (reaction, count) in used)
                            _countChip(theme, reaction, count, mine: reaction.id == _post.userReactionId),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.onReact != null && widget.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingM),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onReact!();
                    },
                    icon: const Icon(Icons.add_reaction_outlined),
                    label: Text(l10n.react),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String? filter, Widget glyph, int count, String semantics) {
    final selected = _filter == filter;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
      child: Semantics(
        label: semantics,
        selected: selected,
        button: true,
        excludeSemantics: true,
        child: ChoiceChip(
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => setState(() => _filter = filter),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [glyph, const SizedBox(width: DesignTokens.spacingXS), Text('$count')],
          ),
        ),
      ),
    );
  }

  Widget _countChip(ThemeData theme, FlarumReaction reaction, int count, {required bool mine}) => Chip(
        avatar: Text(reactionGlyph(reaction), style: const TextStyle(fontSize: 18)),
        label: Text('$count'),
        side: mine ? BorderSide(color: theme.colorScheme.primary, width: 1.5) : null,
        backgroundColor: mine ? theme.colorScheme.primaryContainer : null,
      );
}

class _Person {
  const _Person(this.user, {required this.liked, this.reactionId});

  final FlarumUser user;
  final bool liked;
  final String? reactionId;
}

/// A person in the sheet: their avatar and name ("You" for the reader), their username where their
/// name differs, and what they gave.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, required this.isReader, required this.liked, this.reaction, this.onTap});

  final _Person person;
  final bool isReader;
  final bool liked;
  final FlarumReaction? reaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final user = person.user;
    final reaction = this.reaction;
    return ListTile(
      leading: FlarumAvatar(user: user, radius: 18),
      title: Text(isReader ? l10n.you : user.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: user.displayName == user.username ? null : Text('@${user.username}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: !liked && reaction == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (liked) Icon(Icons.thumb_up, size: DesignTokens.iconSizeS, color: theme.colorScheme.primary),
                if (liked && reaction != null) const SizedBox(width: DesignTokens.spacingS),
                if (reaction != null) Text(reactionGlyph(reaction), style: const TextStyle(fontSize: 18)),
              ],
            ),
      onTap: onTap,
    );
  }
}
