// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlarumLocalizationsFr extends FlarumLocalizations {
  FlarumLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get attachmentDefaultName => 'Pièce jointe';

  @override
  String get share => 'Partager';

  @override
  String get cancel => 'Annuler';

  @override
  String downloading(String filename) {
    return 'Téléchargement de $filename...';
  }

  @override
  String get download => 'Télécharger';

  @override
  String errorDownloading(String filename, String error) {
    return 'Erreur lors du téléchargement de $filename : $error';
  }

  @override
  String get video => 'Vidéo';

  @override
  String get viewOnWeb => 'Voir sur le Web';

  @override
  String get mediaPause => 'Mettre en pause';

  @override
  String get mediaPlay => 'Lire';

  @override
  String get failedToLoadVideo => 'Impossible de charger la vidéo';

  @override
  String get close => 'Fermer';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Image';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Fichier';

  @override
  String get fileTypeText => 'Texte';
}
