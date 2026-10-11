import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/user_avatar.dart';

/// A user's avatar as Flarum draws it: their picture, or else the first letter
/// of their display name on a colour taken from that name, so a member looks
/// the same in the app as on the forum's website.
class FlarumAvatar extends StatelessWidget {
  const FlarumAvatar({super.key, required this.user, this.radius = 20, this.onTap});

  /// Null for a deleted user: a "?" on the colour of "?".
  final FlarumUser? user;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    final picture = user?.avatarUrl;
    if (user != null && picture != null && picture.isNotEmpty) {
      return UserAvatar(username: user.username, iconUrl: picture, radius: radius, onTap: onTap);
    }
    final name = user?.displayName ?? '';
    final letter = name.isEmpty ? '?' : String.fromCharCodes(name.runes.take(1)).toUpperCase();
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: flarumAvatarColor(name.isEmpty ? '?' : name),
      child: Text(letter, style: TextStyle(color: Colors.white, fontSize: radius * 0.9, height: 1)),
    );
    return onTap == null ? avatar : GestureDetector(onTap: onTap, child: avatar);
  }
}

/// The colour Flarum gives a user without a picture: its `stringToColor` of
/// their display name (the hue from the sum of its UTF-16 code units, at
/// saturation 0.3 and value 0.9).
Color flarumAvatarColor(String displayName) {
  final hue = displayName.codeUnits.fold(0, (sum, unit) => sum + unit) % 360 / 360;
  const s = 0.3;
  const v = 0.9;
  final i = (hue * 6).floor();
  final f = hue * 6 - i;
  const p = v * (1 - s);
  final q = v * (1 - f * s);
  final t = v * (1 - (1 - f) * s);
  final (r, g, b) = switch (i % 6) {
    0 => (v, t, p),
    1 => (q, v, p),
    2 => (p, v, t),
    3 => (p, q, v),
    4 => (t, p, v),
    _ => (v, p, q),
  };
  int channel(double x) => (x * 255).floor();
  return Color.fromARGB(255, channel(r), channel(g), channel(b));
}
