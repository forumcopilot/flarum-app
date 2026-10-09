// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlarumLocalizationsEs extends FlarumLocalizations {
  FlarumLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get attachmentDefaultName => 'Archivo adjunto';

  @override
  String get share => 'Compartir';

  @override
  String get cancel => 'Cancelar';

  @override
  String downloading(String filename) {
    return 'Descargando $filename...';
  }

  @override
  String get download => 'Descargar';

  @override
  String errorDownloading(String filename, String error) {
    return 'Error al descargar $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Ver en la Web';

  @override
  String get mediaPause => 'Pausar';

  @override
  String get mediaPlay => 'Reproducir';

  @override
  String get failedToLoadVideo => 'No se pudo cargar el video';

  @override
  String get close => 'Cerrar';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Imagen';

  @override
  String get fileTypeArchive => 'Archivo comprimido';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Archivo';

  @override
  String get fileTypeText => 'Texto';
}
