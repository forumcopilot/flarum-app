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
  String get loadEarlierPosts => 'Carregar publicações anteriores';

  @override
  String get postHidden => 'Esta publicação foi excluída.';

  @override
  String get threadLoadFailed => 'Não foi possível carregar esta discussão.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user alterou o título de “$from” para “$to”.';
  }

  @override
  String eventLocked(String user) {
    return '$user bloqueou a discussão.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user desbloqueou a discussão.';
  }

  @override
  String eventStickied(String user) {
    return '$user fixou a discussão.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user desafixou a discussão.';
  }

  @override
  String eventTagged(String user) {
    return '$user alterou as tags.';
  }

  @override
  String eventOther(String user) {
    return '$user alterou a discussão.';
  }

  @override
  String get someone => 'Alguém';

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
  String get viewNewest => 'Novas';

  @override
  String discussionReplied(String user, String time) {
    return '$user respondeu $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user iniciou $time';
  }

  @override
  String get noDiscussions => 'Ainda não há discussões aqui.';

  @override
  String get discussionsLoadFailed =>
      'Não foi possível carregar as discussões.';

  @override
  String get tagsLoadFailed => 'Não foi possível carregar as tags.';

  @override
  String get signOut => 'Sair';

  @override
  String get account => 'Conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String signInFailedReason(String reason) {
    return 'Não foi possível entrar: $reason';
  }

  @override
  String get signInHint =>
      'Entre pela própria página do fórum. O app mantém você conectado até você sair.';

  @override
  String signedInAs(String name) {
    return 'Conectado como $name';
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
    return '$user respondeu em $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user curtiu sua publicação em $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user reagiu à sua publicação em $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user respondeu à sua publicação em $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user mencionou você em $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user mencionou um grupo do qual você faz parte em $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user renomeou uma discussão para $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user bloqueou $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user iniciou $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user moveu $title para uma tag que você segue';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user iniciou uma discussão privada com você: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user respondeu na discussão privada $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user adicionou você à discussão privada $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user removeu você da discussão privada $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user tornou $title pública';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user escolheu sua publicação como a melhor resposta em $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user escolheu uma melhor resposta em $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Escolha uma melhor resposta em $title';
  }

  @override
  String notifMessage(String user) {
    return '$user enviou uma mensagem para você';
  }

  @override
  String get notifSuspended => 'Sua conta foi suspensa';

  @override
  String get notifUnsuspended => 'A suspensão da sua conta foi encerrada';

  @override
  String get notifExport => 'Sua exportação de dados está pronta';

  @override
  String get notifOther => 'Nova notificação';

  @override
  String get aDiscussion => 'uma discussão';

  @override
  String get notificationsLoadFailed =>
      'Não foi possível carregar suas notificações.';

  @override
  String get notificationsSignIn => 'Entre para ver suas notificações.';

  @override
  String get markAllRead => 'Marcar tudo como lido';

  @override
  String get posts => 'Publicações';

  @override
  String profileJoined(String date) {
    return 'Entrou em $date';
  }

  @override
  String get discussionsTab => 'Discussões';

  @override
  String lastSeen(String time) {
    return 'Última visita $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discussões',
      one: '1 discussão',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments publicações',
      one: '1 publicação',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Não foi possível carregar este perfil.';

  @override
  String get noPostsYet => 'Nenhuma publicação ainda.';

  @override
  String searchFailedWithError(String error) {
    return 'Busca falhou: $error';
  }

  @override
  String get searchHint => 'Pesquisar discussões e publicações';

  @override
  String noResultsFor(String query) {
    return 'Nada encontrado para “$query”.';
  }

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get appearance => 'Aparência';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String repliedByOne(String a) {
    return '$a respondeu a isto.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a e $b responderam a isto.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'mais $others',
      one: 'mais 1',
    );
    return '$a, $b e $_temp0 responderam a isto.';
  }

  @override
  String get repliesTitle => 'Respostas';

  @override
  String postNumber(int number) {
    return 'Publicação #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'mais $others',
      one: 'mais 1',
    );
    return '$a e $_temp0 responderam a isto.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user adicionou $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user removeu $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user adicionou $added e removeu $removed.';
  }

  @override
  String get privateDiscussion => 'Discussão privada';

  @override
  String get bestAnswer => 'Melhor resposta';

  @override
  String get goToBestAnswer => 'Ir para a melhor resposta';

  @override
  String get answered => 'Respondida';

  @override
  String eventRecipientsChanged(String user) {
    return '$user alterou os participantes desta discussão privada.';
  }

  @override
  String get noTagsOnForum => 'Este fórum não usa tags.';

  @override
  String get permissionRequired => 'Permissão necessária';

  @override
  String get bold => 'Negrito';

  @override
  String get underline => 'Sublinhado';

  @override
  String get strikethrough => 'Tachado';

  @override
  String get bulletList => 'Lista com Marcadores';

  @override
  String get numberedList => 'Lista Numerada';

  @override
  String get listItem => 'Item da Lista';

  @override
  String get mentionUser => 'Mencionar usuário';

  @override
  String get title => 'Título';

  @override
  String get content => 'Conteúdo';

  @override
  String get send => 'Enviar';

  @override
  String get save => 'Salvar';

  @override
  String get formatting => 'Formatação';

  @override
  String get pleaseEnterTitle => 'Por favor, insira um título';

  @override
  String get pleaseEnterContent => 'Por favor, insira algum conteúdo';

  @override
  String get composerTitleHint => 'Escreva seu título...';

  @override
  String get composerContentHint => 'Escreva seu conteúdo...';

  @override
  String get composerFormattingHint => 'Abrir opções de formatação';

  @override
  String get searchUsers => 'Buscar usuários...';

  @override
  String get startDiscussion => 'Iniciar uma discussão';

  @override
  String get editPost => 'Editar publicação';

  @override
  String get postingThrottled =>
      'Você está publicando rápido demais. Aguarde alguns segundos e tente de novo.';

  @override
  String get postAwaitingApproval =>
      'Enviado. Vai aparecer assim que um moderador aprovar.';

  @override
  String get chooseTags => 'Escolher tags';

  @override
  String get primaryTags => 'Tags principais';

  @override
  String get secondaryTags => 'Mais tags';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Escolha $count tags principais.',
      one: 'Escolha uma tag principal.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Escolha no máximo $count tags principais.',
      one: 'Escolha só uma tag principal.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Escolha mais $count tags.',
      one: 'Escolha mais 1 tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Escolha no máximo mais $count tags.',
      one: 'Escolha no máximo mais 1 tag.',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Concluído';

  @override
  String get noMembersFound => 'Nenhum membro encontrado.';

  @override
  String get memberSearchNotAllowed => 'Este fórum não permite buscar membros.';

  @override
  String get editLoadFailed =>
      'Não foi possível carregar esta publicação para editar.';

  @override
  String get like => 'Curtir';

  @override
  String get unlike => 'Descurtir';

  @override
  String get react => 'Reagir';

  @override
  String get reactions => 'Reações';

  @override
  String get bookmark => 'Salvar';

  @override
  String get removeBookmark => 'Remover dos salvos';

  @override
  String get bookmarks => 'Salvos';

  @override
  String get noBookmarks => 'Nenhum item salvo ainda.';

  @override
  String get chooseBestAnswer => 'Escolher como melhor resposta';

  @override
  String get removeBestAnswer => 'Remover melhor resposta';

  @override
  String get notificationSettings => 'Notificações desta discussão';

  @override
  String get notFollowing => 'Sem seguir';

  @override
  String get notFollowingHint => 'Ser notificado só quando for @mencionado.';

  @override
  String get followingHint => 'Ser notificado de todas as respostas.';

  @override
  String get ignoring => 'Ignorando';

  @override
  String get ignoringHint => 'Nunca ser notificado e ocultá-la das listas.';

  @override
  String get tagFollowingHint => 'Ser notificado de novas discussões.';

  @override
  String get lurking => 'Acompanhando';

  @override
  String get lurkingHint =>
      'Ser notificado de novas discussões e de cada resposta.';

  @override
  String get tagIgnoringHint => 'Nunca ser notificado das discussões daqui.';

  @override
  String get hidden => 'Oculta';

  @override
  String get hiddenHint => 'Ocultar as discussões desta tag das listas.';

  @override
  String get attachFile => 'Anexar arquivo';

  @override
  String get uploadImage => 'Enviar imagem';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String uploadingFilename(String filename) {
    return 'A enviar: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Falha ao enviar o arquivo: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Aguarde o término do envio dos anexos';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName redimensionado para $size$dimensions para caber no limite de $limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: grande demais ($size) e não pôde ser redimensionado. O limite é $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName tem $fileBytes. Este fórum permite até $maxBytes.';
  }

  @override
  String get flagAction => 'Denunciar';

  @override
  String get ignoredUsers => 'Usuários ignorados';

  @override
  String get ignoredUsersEmpty => 'Você não está ignorando ninguém.';

  @override
  String get flagPostTitle => 'Denunciar publicação';

  @override
  String get flagReasonOffTopic => 'Fora do assunto';

  @override
  String get flagReasonOffTopicText =>
      'Esta publicação não tem relação com a discussão atual e deveria ser movida.';

  @override
  String get flagReasonInappropriate => 'Inadequado';

  @override
  String get flagReasonInappropriateText =>
      'Esta publicação é ofensiva, abusiva ou viola as diretrizes da comunidade.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Esta publicação é propaganda.';

  @override
  String get flagReasonOther => 'Outro (especifique)';

  @override
  String get flagDetails => 'Detalhes adicionais (opcional)';

  @override
  String get flagDetailsNeeded => 'Dê alguns detalhes aos moderadores.';

  @override
  String get communityGuidelines => 'Diretrizes da comunidade';

  @override
  String get flagSent =>
      'Obrigado por denunciar esta publicação. Nossos moderadores vão analisá-la.';

  @override
  String ignoreUser(String name) {
    return 'Ignorar $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Deixar de ignorar $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Ignorar $name? As publicações dessa pessoa ficarão recolhidas. Você pode desfazer isso na sua conta.';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Uma publicação de $name, que você ignora.';
  }

  @override
  String get showPost => 'Mostrar publicação';

  @override
  String get ignoredOnThisPhone =>
      'Este fórum não mantém uma lista de usuários ignorados, então o app guarda a sua neste telefone.';

  @override
  String get stopIgnoring => 'Deixar de ignorar';

  @override
  String get termsBanner =>
      'Aceite os termos atualizados deste fórum para voltar a publicar.';

  @override
  String get termsReview => 'Revisar';

  @override
  String get termsTitle => 'Termos atualizados';

  @override
  String get termsIntro =>
      'Antes de publicar de novo, aceite as políticas atualizadas do fórum.';

  @override
  String get readPolicy => 'Ler';

  @override
  String get acceptTerms => 'Aceitar';

  @override
  String get termsAccepted => 'Obrigado. Você já pode publicar de novo.';
}
