// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlarumLocalizationsEn extends FlarumLocalizations {
  FlarumLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get attachmentDefaultName => 'Attachment';

  @override
  String get share => 'Share';

  @override
  String get cancel => 'Cancel';

  @override
  String downloading(String filename) {
    return 'Downloading $filename...';
  }

  @override
  String get download => 'Download';

  @override
  String errorDownloading(String filename, String error) {
    return 'Error downloading $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'View on Web';

  @override
  String get mediaPause => 'Pause';

  @override
  String get mediaPlay => 'Play';

  @override
  String get failedToLoadVideo => 'Failed to load video';

  @override
  String get close => 'Close';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Image';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'File';

  @override
  String get fileTypeText => 'Text';
}
