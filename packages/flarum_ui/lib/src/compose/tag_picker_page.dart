import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tag_label.dart';

/// What keeps [selected] from meeting the forum's tag [rules], or null when it meets them (or
/// the reader may bypass them). Flarum counts top-level primary tags as primary; a child tag
/// goes with its parent.
String? tagRuleProblem(List<FlarumTag> selected, FlarumTagRules? rules, FlarumLocalizations l10n) {
  if (rules == null || rules.canBypass) return null;
  final primary = selected.where((t) => t.isPrimary && !t.isChild).length;
  final secondary = selected.where((t) => !t.isPrimary).length;
  if (primary < rules.minPrimary) return l10n.tagsNeedPrimary(rules.minPrimary - primary);
  if (primary > rules.maxPrimary) return l10n.tagsTooManyPrimary(rules.maxPrimary);
  if (secondary < rules.minSecondary) return l10n.tagsNeedSecondary(rules.minSecondary - secondary);
  if (secondary > rules.maxSecondary) return l10n.tagsTooManySecondary(rules.maxSecondary);
  return null;
}

/// Chooses a new discussion's tags (flarum/tags) within the forum's rules: its primary tags in
/// the forum's order, each child under its parent, then its other tags. Choosing a child chooses
/// its parent, as on the web; where only one primary tag is allowed, choosing another replaces
/// it. Tags the reader can't start a discussion in are shown, not offered. Pops the choice.
class TagPickerPage extends StatefulWidget {
  const TagPickerPage({super.key, required this.tags, this.rules, this.selected = const []});

  final List<FlarumTag> tags;
  final FlarumTagRules? rules;
  final List<FlarumTag> selected;

  static Future<List<FlarumTag>?> open(BuildContext context,
          {required List<FlarumTag> tags, FlarumTagRules? rules, List<FlarumTag> selected = const []}) =>
      Navigator.of(context).push(MaterialPageRoute<List<FlarumTag>>(
        fullscreenDialog: true,
        builder: (_) => TagPickerPage(tags: tags, rules: rules, selected: selected),
      ));

  @override
  State<TagPickerPage> createState() => _TagPickerPageState();
}

class _TagPickerPageState extends State<TagPickerPage> {
  late final Set<String> _chosen = {for (final tag in widget.selected) tag.id};

  List<FlarumTag> get _chosenTags => [for (final tag in widget.tags) if (_chosen.contains(tag.id)) tag];

  void _toggle(FlarumTag tag) {
    setState(() {
      if (_chosen.remove(tag.id)) {
        // A parent goes with its children.
        _chosen.removeAll(widget.tags.where((t) => t.parentId == tag.id).map((t) => t.id));
        return;
      }
      final primary = tag.isPrimary;
      final parent = tag.isChild ? tag.parentId : null;
      // One primary tag allowed: the new one replaces the old, children and all.
      if (primary && (widget.rules?.maxPrimary ?? 0) == 1 && !(widget.rules?.canBypass ?? false)) {
        final keep = parent ?? tag.id;
        _chosen.removeWhere((id) {
          final other = widget.tags.where((t) => t.id == id).firstOrNull;
          return other != null && other.isPrimary && id != keep && other.parentId != keep;
        });
      }
      _chosen.add(tag.id);
      if (parent != null) _chosen.add(parent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
    final primary = widget.tags.where((t) => t.isPrimary && !t.isChild).toList()..sort(byPosition);
    final secondary = widget.tags.where((t) => !t.isPrimary).toList()..sort((a, b) => a.name.compareTo(b.name));
    final problem = tagRuleProblem(_chosenTags, widget.rules, l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseTags),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(
              onPressed: problem == null ? () => Navigator.of(context).pop(_chosenTags) : null,
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (problem != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingL, 0),
              child: Text(problem, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          if (primary.isNotEmpty) _Section(l10n.primaryTags),
          for (final tag in primary) ...[
            _tile(tag),
            for (final child in widget.tags.where((t) => t.parentId == tag.id).toList()..sort(byPosition))
              _tile(child, indent: true),
          ],
          if (secondary.isNotEmpty) _Section(l10n.secondaryTags),
          for (final tag in secondary) _tile(tag),
        ],
      ),
    );
  }

  Widget _tile(FlarumTag tag, {bool indent = false}) {
    final color = flarumTagColor(tag) ?? Theme.of(context).colorScheme.outline;
    return CheckboxListTile(
      value: _chosen.contains(tag.id),
      onChanged: tag.canStartDiscussion ? (_) => _toggle(tag) : null,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsetsDirectional.only(
          start: indent ? DesignTokens.spacingL * 2.5 : DesignTokens.spacingL, end: DesignTokens.spacingS),
      secondary: Icon(flarumTagIcon(tag.icon) ?? (tag.isPrimary ? Icons.label : Icons.label_outline), color: color),
      title: Text(tag.name),
      subtitle: (tag.description ?? '').isEmpty ? null : Text(tag.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXS),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
