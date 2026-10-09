import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonApiDocument', () {
    final document = JsonApiDocument.fromJson({
      'links': {'first': 'https://forum.test/api/discussions', 'next': 'https://forum.test/discussions?page%5Boffset%5D=20'},
      'data': [
        {
          'type': 'discussions',
          'id': 1,
          'attributes': {'title': 'Hello'},
          'relationships': {
            'user': {
              'data': {'type': 'users', 'id': '7'},
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '99'},
              ],
            },
            'lastPostedUser': {'data': null},
          },
        },
      ],
      'included': [
        {'type': 'users', 'id': '7', 'attributes': {'username': 'alice'}},
        {'type': 'tags', 'id': '1', 'attributes': {'name': 'General'}},
      ],
    });
    final discussion = document.data.single;

    test('reads a collection and stringifies numeric ids', () {
      expect(document.isCollection, isTrue);
      expect(discussion.id, '1');
    });

    test('resolves to-one and to-many relationships from included', () {
      expect(document.find(discussion.toOne('user'))?.attributes['username'], 'alice');
      expect(document.findAll(discussion.toMany('tags')).map((t) => t.id), ['1'], reason: 'tag 99 was not included');
    });

    test('treats empty and missing relationships as absent', () {
      expect(discussion.toOne('lastPostedUser'), isNull);
      expect(discussion.toOne('firstPost'), isNull);
      expect(discussion.toMany('recipients'), isEmpty);
    });

    test('reports a next page without exposing its URL', () {
      expect(document.hasNext, isTrue);
    });

    test('single requires exactly one resource', () {
      expect(() => document.single, returnsNormally);
      expect(() => JsonApiDocument.fromJson({'data': []}).single, throwsFormatException);
    });
  });

  group('FlarumAttributes', () {
    // Values as 1.x and 2.0 actually send them.
    final attributes = <String, dynamic>{
      'debugV1': true,
      'debugV2': '1',
      'passwordlessSignUpV1': false,
      'passwordlessSignUpV2': '',
      'minPrimaryTags': '1',
      'pollMaxOptions': 10,
      'logoUrl': null,
      'description': '',
      'createdAt': '2026-10-08T16:07:33+00:00',
    };

    test('reads booleans sent as true, "1", false or ""', () {
      expect(attributes.boolean('debugV1'), isTrue);
      expect(attributes.boolean('debugV2'), isTrue);
      expect(attributes.boolean('passwordlessSignUpV1'), isFalse);
      expect(attributes.boolean('passwordlessSignUpV2'), isFalse);
      expect(attributes.boolean('missing'), isNull);
    });

    test('reads integers sent as numbers or strings', () {
      expect(attributes.integer('minPrimaryTags'), 1);
      expect(attributes.integer('pollMaxOptions'), 10);
    });

    test('treats null and empty strings as absent where asked', () {
      expect(attributes.nonEmptyString('logoUrl'), isNull);
      expect(attributes.nonEmptyString('description'), isNull);
      expect(attributes.string('description'), '');
    });

    test('parses dates', () {
      expect(attributes.date('createdAt'), DateTime.utc(2026, 10, 8, 16, 7, 33));
    });
  });
}
