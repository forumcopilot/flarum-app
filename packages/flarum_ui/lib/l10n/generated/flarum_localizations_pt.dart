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

  @override
  String get latest => 'Recentes';

  @override
  String get unread => 'Não lidos';

  @override
  String get search => 'Buscar';

  @override
  String get signIn => 'Entrar';

  @override
  String get profile => 'Perfil';

  @override
  String get following => 'Seguindo';

  @override
  String get home => 'Início';

  @override
  String get notifications => 'Notificações';

  @override
  String get settings => 'Configurações';

  @override
  String get tags => 'Tags';

  @override
  String get filterTop => 'Top';

  @override
  String get viewNewest => 'Newest';

  @override
  String discussionReplied(String user, String time) {
    return '$user replied $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user started $time';
  }

  @override
  String get noDiscussions => 'No discussions here yet.';

  @override
  String get discussionsLoadFailed => 'Couldn\'t load discussions.';

  @override
  String get tagsLoadFailed => 'Couldn\'t load the tags.';

  @override
  String get signOut => 'Sair';

  @override
  String get account => 'Conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String signInFailedReason(String reason) {
    return 'Couldn\'t sign in: $reason';
  }

  @override
  String get signInHint =>
      'Sign in on the forum\'s own page. The app keeps you signed in until you sign out.';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas as notificações marcadas como lidas';

  @override
  String get failedToMarkNotificationsRead =>
      'Não foi possível marcar as notificações como lidas';

  @override
  String get noNotificationsYet => 'Nenhuma notificação ainda';

  @override
  String notifNewPost(String user, String title) {
    return '$user replied to $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user liked your post in $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user reacted to your post in $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user replied to your post in $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user mentioned you in $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user mentioned a group you\'re in, in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user renamed a discussion to $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user locked $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user started $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user moved $title to a tag you follow';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user started a private discussion with you: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user replied to the private discussion $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user added you to the private discussion $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user removed you from the private discussion $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user made $title public';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user chose your post as the best answer in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user chose a best answer in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Choose a best answer in $title';
  }

  @override
  String notifMessage(String user) {
    return '$user sent you a message';
  }

  @override
  String get notifSuspended => 'You have been suspended';

  @override
  String get notifUnsuspended => 'Your suspension has been lifted';

  @override
  String get notifExport => 'Your data export is ready';

  @override
  String get notifOther => 'New notification';

  @override
  String get aDiscussion => 'a discussion';

  @override
  String get notificationsLoadFailed => 'Couldn\'t load your notifications.';

  @override
  String get notificationsSignIn => 'Sign in to see your notifications.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get posts => 'Publicações';

  @override
  String profileJoined(String date) {
    return 'Entrou em $date';
  }

  @override
  String get discussionsTab => 'Discussions';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discussions',
      one: '1 discussion',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments posts',
      one: '1 post',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Couldn\'t load this profile.';

  @override
  String get noPostsYet => 'No posts yet.';
}
