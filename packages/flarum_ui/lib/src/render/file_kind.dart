import 'package:flutter/material.dart';

import '../../l10n/flarum_l10n.dart';

// Copied from discourse_ui's utils/file_utils.dart: a file's kind, icon and colour.


/// Returns a human-readable file type for a given filename or extension, in
/// the app's language — a label to show, not to match on ([getFileIcon] and
/// [getFileTypeColor] take the filename).
String getFileType(String filename, FlarumLocalizations l10n) {
  final extension = filename.split('.').last.toLowerCase();
  switch (extension) {
    // Images
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'svg':
    case 'heic':
    case 'heif':
      return l10n.image;

    // Media
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'wmv':
    case 'flv':
    case 'mkv':
    case 'webm':
      return l10n.video;
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'm4a':
    case 'flac':
      return l10n.fileTypeAudio;

    // Documents
    case 'pdf':
      return 'PDF';
    case 'doc':
    case 'docx':
      return 'Word';
    case 'xls':
    case 'xlsx':
      return 'Excel';
    case 'ppt':
    case 'pptx':
      return 'PowerPoint';
    case 'txt':
      return l10n.fileTypeText;

    // Archives
    case 'zip':
    case 'rar':
    case '7z':
    case 'tar':
    case 'gz':
      return l10n.fileTypeArchive;

    default:
      // For unknown, return the extension in uppercase or "File"
      if (extension.length <= 5) {
        return extension.toUpperCase();
      }
      return l10n.fileTypeFile;
  }
}


/// Returns an appropriate icon for a given filename or file type string.
IconData getFileIcon(String filenameOrType) {
  final value = filenameOrType.toLowerCase();
  // Try to match by extension first
  final ext = value.contains('.') ? value.split('.').last : value;
  switch (ext) {
    // Images
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'svg':
    case 'heic':
    case 'heif':
    case 'image':
      return Icons.image;
    // Video
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'wmv':
    case 'flv':
    case 'mkv':
    case 'webm':
    case 'video':
      return Icons.videocam;
    // Audio
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'm4a':
    case 'flac':
    case 'audio':
      return Icons.audio_file;
    // Documents
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
    case 'word':
      return Icons.description;
    case 'xls':
    case 'xlsx':
    case 'excel':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
    case 'powerpoint':
      return Icons.slideshow;
    case 'txt':
    case 'text':
      return Icons.text_snippet;
    // Archives
    case 'zip':
    case 'rar':
    case '7z':
    case 'tar':
    case 'gz':
    case 'archive':
      return Icons.archive;
    default:
      return Icons.insert_drive_file;
  }
}

/// Returns an appropriate background color for a file type icon container.
/// Uses Material Design 3 color palette for consistent theming.
Color getFileTypeColor(String filenameOrType) {
  final value = filenameOrType.toLowerCase();
  // Try to match by extension first
  final ext = value.contains('.') ? value.split('.').last : value;
  switch (ext) {
    // Images - Material 3 Blue (primary)
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'svg':
    case 'image':
      return const Color(0xFF1976D2); // Material 3 blue-700
    // Video - Material 3 Purple
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'wmv':
    case 'flv':
    case 'mkv':
    case 'webm':
    case 'video':
      return const Color(0xFF7B1FA2); // Material 3 purple-700
    // Audio - Material 3 Teal (less bright than green)
    case 'mp3':
    case 'wav':
    case 'ogg':
    case 'm4a':
    case 'flac':
    case 'audio':
      return const Color(0xFF00897B); // Material 3 teal-600 (muted green)
    // Documents
    case 'pdf':
      return const Color(0xFFD32F2F); // Material 3 red-700
    case 'doc':
    case 'docx':
    case 'word':
      return const Color(0xFF1976D2); // Material 3 blue-700 (Word blue)
    case 'xls':
    case 'xlsx':
    case 'excel':
      return const Color(0xFF388E3C); // Material 3 green-700 (Excel green)
    case 'ppt':
    case 'pptx':
    case 'powerpoint':
      return const Color(0xFFFF5722); // Material 3 deep-orange-600 (PowerPoint)
    case 'txt':
    case 'text':
      return const Color(0xFF546E7A); // Material 3 blue-grey-600
    // Archives - Material 3 Orange
    case 'zip':
    case 'rar':
    case '7z':
    case 'tar':
    case 'gz':
    case 'archive':
      return const Color(0xFFF57C00); // Material 3 orange-700
    default:
      return const Color(0xFF616161); // Material 3 grey-700 (default)
  }
}
