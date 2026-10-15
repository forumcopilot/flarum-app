import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/src/compose/uploads.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/utils/image_shrink.dart';
import 'package:image_picker/image_picker.dart' show XFile;

const _url = 'https://forum.example';

/// fof/upload's answer: the file, with its BBCode.
ScriptedReply _uploaded(String name) => (
      201,
      {
        'data': [
          {
            'type': 'files',
            'id': '1',
            'attributes': {
              'uuid': 'uuid-$name',
              'url': '$_url/assets/files/$name',
              'baseName': name,
              'bbcode': '[upl-image-preview uuid=uuid-$name url=$_url/assets/files/$name alt={TEXT?}]',
              'size': 1000,
              'canDelete': false,
            },
          },
        ],
      }
    );

/// As a request past PHP's post_max_size is refused: no files arrived, and the message names
/// fof/upload's limit.
const ScriptedReply _tooLarge = (
  400,
  {
    'errors': [
      {'status': '400', 'code': 'fof-upload.no_files_made_it_to_upload', 'detail': 'Please upload files no larger than 2048 kb.'},
    ],
  }
);

void main() {
  late Directory dir;
  late List<(File, int)> shrunk;

  setUp(() async {
    FlarumForum.resetForTesting();
    ComposerUploader.resetForTesting();
    dir = await Directory.systemTemp.createTemp('uploads_test');
    shrunk = [];
  });
  tearDown(() => dir.delete(recursive: true));

  Future<XFile> file(String name, int bytes) async {
    final f = File('${dir.path}/$name');
    await f.writeAsBytes(List.filled(bytes, 7));
    return XFile(f.path);
  }

  /// A stand-in for forum_kit's shrinkImageToFit, which needs the phone's image codec.
  Future<ShrinkResult?> shrink(File image, int maxBytes) async {
    shrunk.add((image, maxBytes));
    final out = File('${dir.path}/small/${image.uri.pathSegments.last}');
    await out.create(recursive: true);
    await out.writeAsBytes(List.filled(1000, 7));
    return ShrinkResult(
      file: out,
      originalBytes: await image.length(),
      newBytes: 1000,
      originalSize: (width: 4000, height: 3000),
      newSize: (width: 1600, height: 1200),
    );
  }

  ComposerUploader uploader(ScriptedAdapter adapter, {Future<ShrinkResult?> Function(File, int)? shrinkWith}) =>
      ComposerUploader(FlarumForum.forTesting(_url, adapter.dio()), shrink: shrinkWith ?? shrink);

  test('a photo the forum refuses as too big is shrunk to its limit and sent again; the next is shrunk first', () async {
    final adapter = ScriptedAdapter([_tooLarge, _uploaded('photo.jpg'), _uploaded('second.jpg')]);
    final resized = <ResizedUpload>[];
    final photo = await uploader(adapter).upload(await file('photo.jpg', 3 << 20), onResized: resized.add);
    expect(photo.bbcode, startsWith('[upl-image-preview uuid=uuid-photo.jpg '));
    expect(shrunk.single.$2, lessThan(2048 * 1024), reason: 'under the limit, with room for the rest of the request');
    expect(resized.single, (name: 'photo.jpg', bytes: 1000, limit: 2048 * 1024, dimensions: ' (4000×3000 → 1600×1200)'));

    await uploader(adapter).upload(await file('second.jpg', 3 << 20));
    expect(adapter.requests, hasLength(3), reason: 'the second photo went once, already shrunk');
    expect(shrunk, hasLength(2));
  });

  test('a file over the limit is refused, and once the limit is known, before it goes', () async {
    final adapter = ScriptedAdapter([_tooLarge]);
    Future<UploadTooLarge> refusal(Future<Object?> call) async {
      try {
        await call;
      } on UploadTooLarge catch (e) {
        return e;
      }
      fail('Expected the upload to be refused');
    }

    final first = await refusal(uploader(adapter).upload(await file('video.mp4', 3 << 20)));
    expect((first.name, first.bytes, first.limit, first.couldNotResize), ('video.mp4', 3 << 20, 2048 * 1024, false));
    await refusal(uploader(adapter).upload(await file('again.mp4', 3 << 20)));
    expect(adapter.requests, hasLength(1));
    expect(shrunk, isEmpty, reason: 'only photos are shrunk');

    final gif = await refusal(uploader(adapter, shrinkWith: (_, __) async => null).upload(await file('anim.gif', 3 << 20)));
    expect(gif.couldNotResize, isTrue);
  });

  test('anything else the forum says is passed on', () async {
    final adapter = ScriptedAdapter([(422, errors('422', 'validation_error'))]);
    await expectLater(
      uploader(adapter).upload(await file('notes.exe', 10)),
      throwsA(isA<FlarumApiException>().having((e) => e.isValidationError, 'validation', isTrue)),
    );
  });

  test("photos the picker names (Android's media id, iOS's image_picker_<UUID>) get a camera's name; others keep theirs", () async {
    final picked = [
      await file('1000000057.jpg', 10),
      await file('PXL_20261001_101010.jpg', 10),
      await file('1000000058.JPG', 10),
      // iOS's picker.
      await file('image_picker_5A1F2C3D-4E5F-4A6B-8C7D-9E0F1A2B3C4D.jpg', 10),
    ];
    final named = await nameLikeACamera(picked, DateTime(2026, 10, 13, 22, 12, 3));
    expect([for (final f in named) f.name],
        ['IMG_20261013_221203.jpg', 'PXL_20261001_101010.jpg', 'IMG_20261013_221203_2.jpg', 'IMG_20261013_221203_3.jpg']);
    expect([for (final f in named) File(f.path).existsSync()], everyElement(isTrue));
    expect(File(picked.first.path).existsSync(), isFalse, reason: 'moved, not copied');
  });
}
