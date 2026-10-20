import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupFlarumLocalizations(const Locale('en'));
  const you = FlarumUser(id: '1', username: 'alice', displayName: 'alice');
  const jamie = FlarumUser(id: '2', username: 'jamie', displayName: 'Jamie Chen');
  const dmitri = FlarumUser(id: '3', username: 'dmitri', displayName: 'Dmitri Volkov');
  FlarumPost post(int count, List<FlarumUser> by) =>
      FlarumPost(id: '9', number: 2, contentType: 'comment', likesCount: count, likedBy: by);

  test('who likes a post, worded as flarum/likes words it', () {
    expect(likedBy(post(0, []), '1', l10n), isNull);
    expect(likedBy(post(1, [jamie]), '1', l10n), 'Jamie Chen likes this.');
    expect(likedBy(post(2, [jamie, dmitri]), '1', l10n), 'Jamie Chen and Dmitri Volkov like this.');
    expect(likedBy(post(5, [jamie, dmitri]), '1', l10n), 'Jamie Chen, Dmitri Volkov, and 3 others like this.');
    expect(likedBy(post(2, [jamie]), '1', l10n), 'Jamie Chen and 1 other like this.');
  });

  test('the reader is You, first', () {
    expect(likedBy(post(1, [you]), '1', l10n), 'You like this.');
    expect(likedBy(post(2, [you, jamie]), '1', l10n), 'You and Jamie Chen like this.');
    expect(likedBy(post(4, [you, jamie, dmitri]), '1', l10n), 'You, Jamie Chen, and 2 others like this.');
    expect(likedBy(post(1, [you]), null, l10n), 'alice likes this.', reason: 'a guest sees the name');
  });
}
