import 'package:flarum_ui/src/compose/flarum_markup.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _value(String text, int start, [int? end]) =>
    TextEditingValue(text: text, selection: TextSelection(baseOffset: start, extentOffset: end ?? start));

void main() {
  group('the toolbar writes Flarum\'s markup', () {
    test('wraps a selection, or puts the cursor between empty markers', () {
      expect(FlarumMarkup.apply(_value('make it bold', 8, 12), 'B').text, 'make it **bold**');
      final empty = FlarumMarkup.apply(_value('x ', 2), 'I');
      expect(empty.text, 'x **');
      expect(empty.selection.baseOffset, 3);
      expect(FlarumMarkup.apply(_value('under', 0, 5), 'U').text, '[u]under[/u]', reason: 'BBCode: Markdown has none');
    });

    test('spoilers are Flarum\'s own: inline between ||, a block behind >!', () {
      expect(FlarumMarkup.apply(_value('the end', 4, 7), 'SPOILER').text, 'the ||end||');
      expect(FlarumMarkup.apply(_value('one\ntwo', 0, 7), 'SPOILER').text, '>! one\n>! two\n');
    });

    test('quotes and lists mark each line, starting on a line of their own', () {
      expect(FlarumMarkup.apply(_value('said this\nand that', 0, 18), 'QUOTE').text, '> said this\n> and that\n');
      expect(FlarumMarkup.apply(_value('Shopping: eggs\nmilk', 10, 19), 'LIST=1').text, 'Shopping: \n1. eggs\n2. milk\n');
      expect(FlarumMarkup.apply(_value('end', 3), 'LIST').text, 'end\n- ');
    });

    test('an unknown action leaves the text alone', () {
      final value = _value('text', 0, 4);
      expect(FlarumMarkup.apply(value, 'CENTER'), value);
    });
  });

  test('mentions and quotes as flarum/mentions writes them', () {
    expect(FlarumMarkup.userMention('Maya Chen', '8'), '@"Maya Chen"#8');
    expect(FlarumMarkup.postMention('bob', '13'), '@"bob"#p13');
    expect(FlarumMarkup.quote('alice', '12', 'Hi all!\nGlad to be here.'), '> @"alice"#p12 Hi all!\n> Glad to be here.\n\n');
    expect(FlarumMarkup.userMention('The "Real" Bob', '3'), '@"The \'Real\' Bob"#3', reason: 'a " would end the name');
  });
}
