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

  @override
  String get retry => 'Reintentar';

  @override
  String get edited => 'editado';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Cargar más';

  @override
  String viewProfileOfUser(String username) {
    return 'Ver el perfil de $username';
  }

  @override
  String get loadEarlierPosts => 'Load earlier posts';

  @override
  String get postHidden => 'This post was deleted.';

  @override
  String get threadLoadFailed => 'Couldn\'t load this discussion.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user changed the title from “$from” to “$to”.';
  }

  @override
  String eventLocked(String user) {
    return '$user locked the discussion.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user unlocked the discussion.';
  }

  @override
  String eventStickied(String user) {
    return '$user stickied the discussion.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user unstickied the discussion.';
  }

  @override
  String eventTagged(String user) {
    return '$user changed the tags.';
  }

  @override
  String eventOther(String user) {
    return '$user changed the discussion.';
  }

  @override
  String get someone => 'Someone';
}
