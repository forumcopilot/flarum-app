import 'dart:convert';

import 'package:dio/dio.dart' show MultipartFile;
import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// The composer's writes, replayed from fixtures recorded on both test forums
/// (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumApi api;

      setUp(() {
        fixtures = FixtureForum(version);
        api = fixtures.api();
      });

      Future<FlarumApiException> refusal(Future<Object?> call) async {
        try {
          await call;
        } on FlarumApiException catch (e) {
          return e;
        }
        fail('Expected the forum to refuse');
      }

      test('starts a discussion with its tags', () async {
        final discussion =
            await api.startDiscussion(WriteSamples.title, WriteSamples.content, tagIds: [fixtures.tagId('general')]);
        expect(discussion.title, WriteSamples.title);
        expect(discussion.tags.map((t) => t.slug), ['general']);
        final sent = fixtures.requests.single.data as Map;
        expect(sent['data']['relationships']['tags']['data'], [
          {'type': 'tags', 'id': fixtures.tagId('general')},
        ]);
      });

      test('without the tags the forum asks for, it says why', () async {
        final e = await refusal(api.startDiscussion(WriteSamples.title, WriteSamples.noTagsContent));
        expect(e.isValidationError, isTrue);
        expect(e.reasons, version == FlarumVersion.v2 ? 'The tags field is required.' : 'The number of primary tags must be 1.');
      });

      test('replies, and the reply comes back rendered with its source for its author', () async {
        final post = await api.reply('1', WriteSamples.reply);
        expect(post.number, 2);
        expect(post.contentHtml, '<p>${WriteSamples.reply}</p>');
        expect(post.source, WriteSamples.reply);
        expect(post.isApproved, isTrue);
      });

      test('a second post straight after meets the posting throttle', () async {
        final e = await refusal(api.reply('1', WriteSamples.throttledReply));
        expect(e.isThrottled, isTrue);
      });

      test('edits the reader\'s own post, and not someone else\'s', () async {
        final post = await api.reply('1', WriteSamples.reply);
        final edited = await api.editPost(post.id, WriteSamples.edit);
        expect(edited.source, WriteSamples.edit);
        expect(edited.editedAt, isNotNull);

        final e = await refusal(api.editPost(post.id, WriteSamples.editByOther));
        expect(e.isForbidden, isTrue);
      });

      test('uploads an image and a file, each with the BBCode that shows it', () async {
        final image = (await api.upload([
          MultipartFile.fromBytes(base64Decode(WriteSamples.uploadImageBase64), filename: WriteSamples.uploadImageName),
        ]))
            .single;
        expect(image.baseName, WriteSamples.uploadImageName);
        expect(image.type, 'image/png');
        expect(image.size, 69);
        expect(image.url, endsWith(WriteSamples.uploadImageName));
        expect(image.bbcode, startsWith('[upl-image-preview uuid=${image.uuid} url=${image.url} alt'));
        expect(image.bbcode, isNot(contains('{TEXT?}')), reason: "1.x's placeholder is filled in");
        expect(image.canDelete, isFalse, reason: 'fof/upload lets only moderators delete by default');

        final file = (await api.upload([
          MultipartFile.fromString(WriteSamples.uploadFileText, filename: WriteSamples.uploadFileName),
        ]))
            .single;
        expect(file.type, 'text/plain');
        expect(file.bbcode, '[upl-file uuid=${file.uuid} size=32B]${WriteSamples.uploadFileName}[/upl-file]');
      });

      test('a member may not delete an upload', () async {
        await api.upload([
          MultipartFile.fromBytes(base64Decode(WriteSamples.uploadImageBase64), filename: WriteSamples.uploadImageName),
        ]);
        final file = (await api
                .upload([MultipartFile.fromString(WriteSamples.uploadFileText, filename: WriteSamples.uploadFileName)]))
            .single;
        final e = await refusal(api.deleteUpload(file.uuid));
        expect(e.isForbidden, isTrue);
      });
    });
  }

  test('an upload refused as too big says so, with the most the forum takes', () {
    FlarumApiException refusal(int status, String code, [String? detail]) =>
        FlarumApiException(status, [FlarumApiError(code: code, detail: detail)]);
    // As both test forums refuse a 3 MB and a 9 MB file through their public hosts.
    final ini = refusal(413, 'fof-upload.max_upload_file_size_ini', 'Upload max filesize limit reached from php.ini.');
    final post = refusal(400, 'fof-upload.no_files_made_it_to_upload', 'Please upload files no larger than 2048 kb.');
    final rule = refusal(422, 'validation_error', 'Uploads over 512 kb are not accepted.');
    final nginx = FlarumApiException(413, const []);
    expect([ini, post, rule, nginx].map((e) => (e.isTooLarge, e.uploadLimit)), [
      (true, 2 << 20),
      (true, 2048 * 1024),
      (true, 512 * 1024),
      (true, 1 << 20),
    ]);
    final type = refusal(422, 'validation_error', 'This file type is not allowed.');
    expect((type.isTooLarge, type.uploadLimit), (false, null));
  });

  test('a refusal lists every reason the forum gave', () {
    final e = FlarumApiException(422, const [
      FlarumApiError(code: 'validation_error', detail: 'The title field is required.'),
      FlarumApiError(code: 'validation_error', detail: 'The content field is required.'),
    ]);
    expect(e.reasons, 'The title field is required.\nThe content field is required.');
    expect(e.message, 'The title field is required.');
  });
}
