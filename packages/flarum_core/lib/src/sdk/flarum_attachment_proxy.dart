import 'dart:typed_data';

import 'package:dio/dio.dart' show MultipartFile;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_attachment_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_attachment_result.dart';

import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;

/// [IFCAttachmentProxy] on fof/upload. An attachment's id is its upload's uuid; a reply or a new
/// discussion given ids puts their BBCode at the end of its text ([withAttachments]).
class FlarumAttachmentProxy implements IFCAttachmentProxy {
  FlarumAttachmentProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  /// The BBCode of each upload this app made, by uuid.
  static final _bbcode = <String, String>{};

  /// [text] with the BBCode of each of [attachmentIds] it doesn't hold yet, a line each.
  static String withAttachments(String text, List<String>? attachmentIds) {
    final missing = [
      for (final id in attachmentIds ?? const <String>[])
        if (_bbcode[id] case final code? when !text.contains(id)) code,
    ];
    return missing.isEmpty ? text : '${text.trimRight()}\n\n${missing.join('\n')}';
  }

  @override
  Future<FCAttachmentUploadResult> uploadAttachmentAsync(
      String type, String id, String groupId, String attachmentName, Uint8List attachmentBytes) async {
    try {
      final upload =
          (await _forum.api.upload([MultipartFile.fromBytes(attachmentBytes, filename: attachmentName)])).single;
      _bbcode[upload.uuid] = upload.bbcode;
      return FCAttachmentUploadResult(
        result: true,
        resultText: '',
        attachmentId: upload.uuid,
        fileName: upload.baseName,
        fileSize: upload.size,
        url: upload.url,
      );
    } catch (e) {
      return FCAttachmentUploadResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// Flarum's avatar upload belongs with editing a profile, not yet in the app.
  @override
  Future<FCAttachmentUploadResult> uploadAvatarAsync(String imageExtension, Uint8List attachmentBytes) async =>
      FCAttachmentUploadResult(result: false, resultText: 'Not available yet');

  /// Deletes the upload, where the reader may (fof/upload lets only moderators by default).
  @override
  Future<FCAttachmentRemoveResult> removeAttachmentAsync(
      String attachmentId, String forumId, String groupId, String postId) async {
    try {
      await _forum.api.deleteUpload(attachmentId);
      _bbcode.remove(attachmentId);
      return FCAttachmentRemoveResult(result: true, resultText: '');
    } catch (e) {
      return FCAttachmentRemoveResult(result: false, resultText: describeFlarumError(e));
    }
  }
}
