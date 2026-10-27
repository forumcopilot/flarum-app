import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForumLink.fromPush', () {
    test('reads what a push opens from its data, as Firebase delivers it', () {
      expect(ForumLink.fromPush({'discussion_id': '12', 'post_number': '7'}), const DiscussionLink('12', 7));
      expect(ForumLink.fromPush({'discussion_id': '12'}), const DiscussionLink('12'));
      expect(ForumLink.fromPush({'dialog_id': '4'}), const DialogLink('4'));
      expect(ForumLink.fromPush({'user_id': '3'}), const UserIdLink('3'));
    });

    test('a push that names nothing, or nothing it can read, opens the forum\'s home', () {
      expect(ForumLink.fromPush({'type': 'flarum_notification'}), isNull);
      expect(ForumLink.fromPush({'discussion_id': '0'}), isNull);
      expect(ForumLink.fromPush({'discussion_id': '12x'}), isNull);
      expect(ForumLink.fromPush({'discussion_id': '12', 'post_number': 'x'}), const DiscussionLink('12'));
    });
  });
}
