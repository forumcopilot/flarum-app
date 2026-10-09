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

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get edited => 'editado';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas',
      one: '1 resposta',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Carregar mais';

  @override
  String viewProfileOfUser(String username) {
    return 'Ver o perfil de $username';
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
