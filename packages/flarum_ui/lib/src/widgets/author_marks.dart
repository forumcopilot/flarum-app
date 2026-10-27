import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/discourse_color.dart';

import '../tags/tag_label.dart' show flarumTagIcon, textOn;

/// A group as the web badges a post's author with it: a small circle in the group's colour with
/// its icon (its initial where its icon has no Material match), its name for screen readers and
/// on a long press.
class GroupIconBadge extends StatelessWidget {
  const GroupIconBadge({super.key, required this.group, this.size = 18});

  final FlarumGroup group;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = group.color == null ? null : parseDiscourseHex(group.color!.trim());
    final background = color ?? colorScheme.secondaryContainer;
    final foreground = color == null ? colorScheme.onSecondaryContainer : textOn(color);
    final icon = flarumTagIcon(group.icon);
    final initial = group.nameSingular.isEmpty ? '' : group.nameSingular.characters.first.toUpperCase();
    return Tooltip(
      message: group.nameSingular,
      child: Semantics(
        label: group.nameSingular,
        excludeSemantics: true,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: icon != null
              ? Icon(icon, size: size * 0.62, color: foreground)
              : Text(initial,
                  style: TextStyle(fontSize: size * 0.55, height: 1, fontWeight: FontWeight.w700, color: foreground)),
        ),
      ),
    );
  }
}

/// [code] (ISO 3166, `CH`) as its flag emoji; null for none or one that isn't two letters.
String? countryFlag(String? code) {
  final letters = code?.trim().toUpperCase() ?? '';
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(letters)) return null;
  return String.fromCharCodes(letters.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
}
