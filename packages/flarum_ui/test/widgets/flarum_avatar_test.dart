import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/src/widgets/flarum_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a letter avatar has the colour Flarum gives the name', () {
    // From Flarum's own stringToColor (core js/src/common/utils/stringToColor.ts), run in node.
    const web = {'alice': 0xa0e5c3, 'bob': 0xe5a0dd, 'Maya Chen': 0xc7e5a0, 'Hüseyin': 0xa0e5c9, '?': 0xe2e5a0};
    for (final MapEntry(key: name, value: rgb) in web.entries) {
      expect(flarumAvatarColor(name), Color(0xFF000000 | rgb), reason: name);
    }
  });

  testWidgets('without a picture: the first letter of the display name, on its colour', (tester) async {
    const maya = FlarumUser(id: '8', username: 'maya', displayName: 'Maya Chen');
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FlarumAvatar(user: maya))));
    expect(find.text('M'), findsOneWidget);
    expect(tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor, const Color(0xFFC7E5A0));
  });
}
