// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlarumLocalizationsIt extends FlarumLocalizations {
  FlarumLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get attachmentDefaultName => 'Allegato';

  @override
  String get share => 'Condividi';

  @override
  String get cancel => 'Annulla';

  @override
  String downloading(String filename) {
    return 'Download di $filename...';
  }

  @override
  String get download => 'Scarica';

  @override
  String errorDownloading(String filename, String error) {
    return 'Errore nel download di $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Visualizza sul Web';

  @override
  String get mediaPause => 'Pausa';

  @override
  String get mediaPlay => 'Riproduci';

  @override
  String get failedToLoadVideo => 'Impossibile caricare il video';

  @override
  String get close => 'Chiudi';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Immagine';

  @override
  String get fileTypeArchive => 'Archivio';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'File';

  @override
  String get fileTypeText => 'Testo';
}
