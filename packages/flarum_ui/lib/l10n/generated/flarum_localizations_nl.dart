// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class FlarumLocalizationsNl extends FlarumLocalizations {
  FlarumLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get attachmentDefaultName => 'Bijlage';

  @override
  String get share => 'Delen';

  @override
  String get cancel => 'Annuleren';

  @override
  String downloading(String filename) {
    return 'Downloaden $filename...';
  }

  @override
  String get download => 'Downloaden';

  @override
  String errorDownloading(String filename, String error) {
    return 'Fout bij downloaden $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Bekijken op web';

  @override
  String get mediaPause => 'Pauzeren';

  @override
  String get mediaPlay => 'Afspelen';

  @override
  String get failedToLoadVideo => 'Video laden mislukt';

  @override
  String get close => 'Sluiten';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Afbeelding';

  @override
  String get fileTypeArchive => 'Archief';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Bestand';

  @override
  String get fileTypeText => 'Tekst';
}
