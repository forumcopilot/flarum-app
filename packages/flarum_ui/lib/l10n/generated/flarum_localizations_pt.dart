// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FlarumLocalizationsPt extends FlarumLocalizations {
  FlarumLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get attachmentDefaultName => 'Anexo';

  @override
  String get share => 'Compartilhar';

  @override
  String get cancel => 'Cancelar';

  @override
  String downloading(String filename) {
    return 'Baixando $filename...';
  }

  @override
  String get download => 'Transferir';

  @override
  String errorDownloading(String filename, String error) {
    return 'Erro ao baixar $filename: $error';
  }

  @override
  String get video => 'Vídeo';

  @override
  String get viewOnWeb => 'Ver na Web';

  @override
  String get mediaPause => 'Pausar';

  @override
  String get mediaPlay => 'Reproduzir';

  @override
  String get failedToLoadVideo => 'Não foi possível carregar o vídeo';

  @override
  String get close => 'Fechar';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Imagem';

  @override
  String get fileTypeArchive => 'Arquivo compactado';

  @override
  String get fileTypeAudio => 'Áudio';

  @override
  String get fileTypeFile => 'Arquivo';

  @override
  String get fileTypeText => 'Texto';
}
