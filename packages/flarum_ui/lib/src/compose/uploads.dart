import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:forum_kit/utils/file_picker_utils.dart';
import 'package:forum_kit/utils/image_shrink.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../render/file_kind.dart';

/// Where the composer's upload buttons pick from.
enum UploadSource { photos, camera, files }

/// Files for [source]: photos from the gallery, one from the camera, or any files. Empty when the
/// writer cancels.
Future<List<XFile>> pickUploads(UploadSource source) async => switch (source) {
      // No imageQuality: any value makes image_picker re-encode a photo that may well fit.
      UploadSource.photos => await nameLikeACamera(await FilePickerUtils.pickMultiImage(), DateTime.now()),
      UploadSource.camera => [if (await FilePickerUtils.takePhoto() case final photo?) photo],
      UploadSource.files => await FilePickerUtils.pickFiles(),
    };

/// [photos], each named by Android's photo picker after its media id ("1000000057.jpg") renamed
/// the way a phone camera names a photo, as forum_kit names one just taken (IMG_20261013_221233.jpg,
/// then _2, _3 for the others picked with it): the name is what a post shows for the image, and
/// 1.x's alt text. Each goes into a directory of its own, next to where the picker copied it.
/// Photos with names of their own keep them, and any that can't be moved stay as they are.
@visibleForTesting
Future<List<XFile>> nameLikeACamera(List<XFile> photos, DateTime now) async {
  String two(int n) => '$n'.padLeft(2, '0');
  final stamp = 'IMG_${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  final renamed = <XFile>[];
  var count = 0;
  for (final photo in photos) {
    final dot = photo.name.lastIndexOf('.');
    final base = dot < 0 ? photo.name : photo.name.substring(0, dot);
    if (!RegExp(r'^\d+$').hasMatch(base)) {
      renamed.add(photo);
      continue;
    }
    count++;
    final name = '$stamp${count == 1 ? '' : '_$count'}${dot < 0 ? '' : photo.name.substring(dot).toLowerCase()}';
    try {
      final file = File(photo.path);
      final dir = await Directory('${file.parent.path}${Platform.pathSeparator}picked_${now.microsecondsSinceEpoch}_$count')
          .create();
      renamed.add(XFile((await file.rename('${dir.path}${Platform.pathSeparator}$name')).path));
    } on FileSystemException {
      renamed.add(photo);
    }
  }
  return renamed;
}

/// A photo shrunk to fit the forum's limit, to tell the writer what changed.
typedef ResizedUpload = ({String name, int bytes, int limit, String dimensions});

/// A file over the forum's limit; [couldNotResize] when it was a photo that couldn't be shrunk.
class UploadTooLarge implements Exception {
  const UploadTooLarge(this.name, this.bytes, this.limit, {this.couldNotResize = false});

  final String name;
  final int bytes;
  final int limit;
  final bool couldNotResize;
}

/// Sends the composer's files through fof/upload, as picked. Flarum doesn't tell the app its
/// limit, so a photo the forum refuses as too big is shrunk to the limit the refusal names
/// (fof/upload's and PHP's are both 2 MB by default) and sent once more; the limit is remembered
/// for the forum, and the next file over it is shrunk, or refused, before it goes.
class ComposerUploader {
  ComposerUploader(this.forum, {this.shrink = _shrinkToFit});

  final FlarumForum forum;

  /// Brings an image under a size, or null when it can't (a GIF, say): forum_kit's
  /// [shrinkImageToFit] in the app.
  final Future<ShrinkResult?> Function(File image, int maxBytes) shrink;

  static Future<ShrinkResult?> _shrinkToFit(File image, int maxBytes) => shrinkImageToFit(image, maxBytes: maxBytes);

  /// Each forum's limit, by its URL, once a refusal has named it.
  static final _limits = <String, int>{};

  @visibleForTesting
  static void resetForTesting() => _limits.clear();

  String get _forumKey => forum.api.client.baseUrl;

  /// Uploads [file]. Throws [UploadTooLarge] for a file over the forum's limit, and the forum's own
  /// refusal for anything else.
  Future<FlarumUpload> upload(XFile file, {void Function(ResizedUpload)? onResized}) async {
    final image = isImageFile(file.name);
    final bytes = await File(file.path).length();
    var path = file.path;
    if (_limits[_forumKey] case final limit? when bytes > limit) {
      path = image ? await _shrunk(file, bytes, limit, onResized) : throw UploadTooLarge(file.name, bytes, limit);
    }
    try {
      return await _send(path, file.name);
    } on FlarumApiException catch (e) {
      final limit = e.uploadLimit;
      if (limit == null) rethrow;
      _limits[_forumKey] = limit;
      // Not a photo, or one shrunk already to a limit the forum has since lowered.
      if (!image || path != file.path) throw UploadTooLarge(file.name, bytes, limit);
      return _send(await _shrunk(file, bytes, limit, onResized), file.name);
    }
  }

  Future<FlarumUpload> _send(String path, String name) async =>
      (await forum.api.upload([await FlarumApi.fileAt(path, name: name)])).single;

  /// The path of [file] shrunk under [limit], with room for the rest of the request.
  Future<String> _shrunk(XFile file, int bytes, int limit, void Function(ResizedUpload)? onResized) async {
    final shrunk = await shrink(File(file.path), (limit * 0.98).floor());
    if (shrunk == null) throw UploadTooLarge(file.name, bytes, limit, couldNotResize: true);
    final (from, to) = (shrunk.originalSize, shrunk.newSize);
    onResized?.call((
      name: file.name,
      bytes: shrunk.newBytes,
      limit: limit,
      dimensions: from == null || to == null ? '' : ' (${from.width}×${from.height} → ${to.width}×${to.height})',
    ));
    return shrunk.file.path;
  }
}
