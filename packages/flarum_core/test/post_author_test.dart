import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// A post as discuss.flarum.org (Flarum 2.0, fof/geoip, fof/user-bio) sends it with
/// `include=user,user.groups,ipInfo`: what the thread shows beside the author's name.
void main() {
  final document = JsonApiDocument.fromJson({
    'data': {
      'type': 'posts',
      'id': '1',
      'attributes': {'number': 2, 'contentType': 'comment', 'contentHtml': '<p>Hi</p>'},
      'relationships': {
        'user': {
          'data': {'type': 'users', 'id': '7'},
        },
        'ipInfo': {
          'data': {'type': 'ip_info', 'id': 'abc'},
        },
      },
    },
    'included': [
      {
        'type': 'users',
        'id': '7',
        // discuss.flarum.org: no HTML, the text in `bio`.
        'attributes': {'username': 'ClaudiusH', 'displayName': 'ClaudiusH', 'bioHtml': '', 'bio': 'PM at Glowing Blue\nGerman language pack'},
        'relationships': {
          'groups': {
            'data': [
              {'type': 'groups', 'id': '8'},
              {'type': 'groups', 'id': '24'},
            ],
          },
        },
      },
      {
        'type': 'groups',
        'id': '8',
        'attributes': {'nameSingular': 'Flarum Team', 'color': '#e7672e', 'icon': 'fa-duotone fa-comment-alt'},
      },
      {
        'type': 'groups',
        'id': '24',
        'attributes': {'nameSingular': 'Translator', 'color': '', 'icon': 'fa-duotone fa-language'},
      },
      {
        'type': 'ip_info',
        'id': 'abc',
        'attributes': {'countryCode': 'CH'},
      },
    ],
  });

  test("a post's author comes with their groups, bio and country", () {
    final post = FlarumPost.fromResource(document.single, document);
    expect(post.author?.groups.map((g) => g.nameSingular), ['Flarum Team', 'Translator']);
    expect(post.author?.groups.first.color, '#e7672e');
    expect(post.author?.bio, 'PM at Glowing Blue\nGerman language pack');
    expect(post.authorCountryCode, 'CH');
    expect(post.copyWith(likesCount: 1).authorCountryCode, 'CH', reason: 'kept through a like');
  });
}
