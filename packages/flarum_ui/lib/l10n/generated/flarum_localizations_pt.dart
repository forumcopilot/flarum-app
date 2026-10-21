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
  String get copyLink => 'Copiar link';

  @override
  String get linkCopied => 'Link copiado.';

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
  String get saveImage => 'Salvar imagem';

  @override
  String get imageSaved => 'Imagem salva.';

  @override
  String get imageSaveFailed => 'Não foi possível salvar a imagem.';

  @override
  String get imageSaveNotAllowed =>
      'O app não tem permissão para salvar nas suas fotos. Você pode permitir nos ajustes do telefone.';

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
  String get edited => 'Editado';

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
  String get loadMore => 'Carregar Mais';

  @override
  String viewProfileOfUser(String username) {
    return 'Ver o perfil de $username';
  }

  @override
  String get loadEarlierPosts => 'Carregar Mais';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index de $count posts',
      one: '$index de $count post',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => 'Post Original';

  @override
  String get scrubberNow => 'Agora';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias depois',
      one: 'um dia depois',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses depois',
      one: 'um mês depois',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos depois',
      one: 'um ano depois',
    );
    return '$_temp0';
  }

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
  String get someone => '[excluído]';

  @override
  String get latest => 'Recentes';

  @override
  String get unread => 'Não lidos';

  @override
  String get search => 'Buscar';

  @override
  String get signIn => 'Entrar';

  @override
  String get logInToReply => 'Entrar para Responder';

  @override
  String get cannotReply => 'Não Pode Responder';

  @override
  String get profile => 'Perfil';

  @override
  String get following => 'Seguindo';

  @override
  String get follow => 'Seguir';

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
  String get noDiscussions => 'Parece que não há discussões aqui.';

  @override
  String get discussionsLoadFailed =>
      'Não foi possível carregar as discussões.';

  @override
  String get tagsLoadFailed => 'Não foi possível carregar as tags.';

  @override
  String get signOut => 'Sair';

  @override
  String logOutQuestion(String forum) {
    return 'Tem certeza de que deseja sair de $forum?';
  }

  @override
  String get account => 'Conta';

  @override
  String get createAccount => 'Cadastrar-se';

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
  String get noNotificationsYet => 'Sem Notificações';

  @override
  String notifNewPost(String user, String title) {
    return '$user postou em $title';
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
    return '$user alterou o título para $title';
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
    return '$user mudou a tag de $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user iniciou uma nova discussão privada com você: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user postou em uma discussão privada da qual você faz parte: $title';
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
    return 'Seu post foi definido como a melhor resposta por $user em $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user definiu uma melhor resposta em $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Selecione uma melhor resposta em $title se sua pergunta foi respondida';
  }

  @override
  String notifMessage(String user) {
    return '$user enviou uma mensagem para você';
  }

  @override
  String get notifSuspended => 'Sua conta foi suspensa';

  @override
  String get notifUnsuspended => 'Sua suspensão foi removida';

  @override
  String get notifExport =>
      'Sua exportação de dados está pronta para download.';

  @override
  String get notifOther => 'Nova notificação';

  @override
  String notifLineNewPost(String user) {
    return '$user postou';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user curtiu seu post';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user reagiu ao seu post';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user respondeu ao seu post';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user mencionou você';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user mencionou um grupo do qual você faz parte';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user alterou o título';
  }

  @override
  String notifLineLocked(String user) {
    return '$user a trancou';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user a iniciou';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user mudou a tag';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user iniciou uma nova discussão privada com você';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user postou em uma discussão privada da qual você faz parte';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user adicionou você a uma discussão privada';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user removeu você de uma discussão privada';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user removeu todos os destinatários e tornou a discussão pública';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Seu post foi definido como a melhor resposta por $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user definiu uma melhor resposta nesta discussão';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Selecione uma melhor resposta se sua pergunta foi respondida';

  @override
  String get aDiscussion => 'uma discussão';

  @override
  String get notificationsLoadFailed =>
      'Não foi possível carregar suas notificações.';

  @override
  String get notificationsSignIn => 'Entre para ver suas notificações.';

  @override
  String get markAllRead => 'Marcar Tudo como Lido';

  @override
  String get markAllDiscussionsReadQuestion =>
      'Tem certeza de que deseja marcar todas as discussões como lidas?';

  @override
  String get hideWelcomeMessage => 'Ocultar mensagem de boas-vindas';

  @override
  String get posts => 'Publicações';

  @override
  String get usersTab => 'Usuários';

  @override
  String get likesTab => 'Curtidas';

  @override
  String get mentionsTab => 'Menções';

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
  String get online => 'Online';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count melhores respostas',
      one: '$count melhor resposta',
    );
    return '$_temp0';
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
  String get noPostsYet => 'Parece que não há posts aqui.';

  @override
  String searchFailedWithError(String error) {
    return 'Busca falhou: $error';
  }

  @override
  String get searchHint => 'Buscar no Fórum';

  @override
  String get recentSearches => 'Pesquisas Recentes';

  @override
  String get clearRecentSearches => 'Limpar';

  @override
  String noResultsFor(String query) {
    return 'Parece que não há resultados para “$query”.';
  }

  @override
  String get light => 'Modo Claro';

  @override
  String get dark => 'Modo Escuro';

  @override
  String get appearance => 'Esquema de Cores';

  @override
  String get appearanceSystem => 'Preferência do sistema';

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
  String get repliesTitle => 'Respostas a este post';

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
  String get bestAnswer => 'Melhor Resposta';

  @override
  String get goToBestAnswer => 'Ver Melhor Resposta';

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
  String get mentionUser => 'Mencionar um usuário, grupo ou post';

  @override
  String get title => 'Título';

  @override
  String get content => 'Conteúdo';

  @override
  String get send => 'Enviar mensagem';

  @override
  String get postReply => 'Responder';

  @override
  String get postDiscussion => 'Publicar Discussão';

  @override
  String get postPrivateDiscussion => 'Postar Discussão Privada';

  @override
  String get save => 'Salvar Alterações';

  @override
  String get formatting => 'Formatação';

  @override
  String get addBold => 'Adicionar texto em negrito';

  @override
  String get addItalic => 'Adicionar texto em itálico';

  @override
  String get insertQuote => 'Inserir uma citação';

  @override
  String get addLink => 'Adicionar um link';

  @override
  String get addBulletedList => 'Adicionar uma lista com marcadores';

  @override
  String get insertCode => 'Inserir código';

  @override
  String get pleaseEnterTitle => 'Por favor, insira um título';

  @override
  String get pleaseEnterContent => 'Por favor, insira algum conteúdo';

  @override
  String get composerTitleHint => 'Título da Discussão';

  @override
  String get privateDiscussionTitleHint => 'Título da Discussão Privada';

  @override
  String get composerContentHint => 'Escreva um Post...';

  @override
  String get composerReplyHint => 'Escreva uma Resposta...';

  @override
  String get composerFormattingHint => 'Abrir opções de formatação';

  @override
  String get searchUsers => 'Buscar usuários...';

  @override
  String get startDiscussion => 'Iniciar Discussão';

  @override
  String get editPost => 'Editar publicação';

  @override
  String get postingThrottled =>
      'Você está indo um pouco rápido demais. Tente novamente em alguns segundos.';

  @override
  String get postAwaitingApproval =>
      'Enviado. Vai aparecer assim que um moderador aprovar.';

  @override
  String get chooseTags => 'Escolher Tags';

  @override
  String get ok => 'OK';

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
  String get noMembersFound => 'Nenhum usuário encontrado para sua busca.';

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
  String likedByOne(String a) {
    return '$a curtiu isto.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a e $b curtiram isto.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'mais $others pessoas',
      one: 'mais 1 pessoa',
    );
    return '$a e $_temp0 curtiram isto.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'mais $others pessoas',
      one: 'mais 1 pessoa',
    );
    return '$a, $b e $_temp0 curtiram isto.';
  }

  @override
  String get likedByYou => 'Você curtiu isto.';

  @override
  String likedByYouAndOne(String a) {
    return 'Você e $a curtiram isto.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'mais $others pessoas',
      one: 'mais 1 pessoa',
    );
    return 'Você, $a e $_temp0 curtiram isto.';
  }

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
  String get chooseBestAnswer => 'Marcar Melhor Resposta';

  @override
  String get removeBestAnswer => 'Desmarcar Melhor Resposta';

  @override
  String get notFollowing => 'Não Seguindo';

  @override
  String get notFollowingHint => 'Ser notificado só quando for @mencionado.';

  @override
  String get followingHint => 'Ser notificado de todas as respostas.';

  @override
  String get ignoring => 'Ignorando';

  @override
  String get ignoringHint =>
      'Nunca seja notificado. Ocultar da lista de discussões.';

  @override
  String get tagFollowingHint =>
      'Seja notificado de todas as novas discussões.';

  @override
  String get lurking => 'Acompanhando';

  @override
  String get lurkingHint =>
      'Seja notificado de todas as novas discussões e respostas.';

  @override
  String get tagIgnoringHint => 'Nunca seja notificado.';

  @override
  String get hidden => 'Ocultando';

  @override
  String get hiddenHint => 'Ocultar discussões da página Todas as Discussões.';

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
    return '$fileName tem $fileBytes. Uploads acima de $maxBytes não são aceitos.';
  }

  @override
  String get flagAction => 'Denunciar';

  @override
  String get ignoredUsers => 'Usuários Ignorados';

  @override
  String get ignoredUsersEmpty => 'Parece que você não está ignorando ninguém.';

  @override
  String get flagPostTitle => 'Sinalizar Post';

  @override
  String get flagReasonOffTopic => 'Fora do assunto';

  @override
  String get flagReasonOffTopicText =>
      'Esta publicação não tem relação com a discussão atual e deveria ser movida.';

  @override
  String get flagReasonInappropriate => 'Inadequado';

  @override
  String get flagReasonInappropriateText =>
      'Este post é ofensivo, abusivo ou viola as regras da comunidade.';

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
    return 'Tem certeza de que deseja ignorar $name?';
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
      'Restringimos temporariamente o acesso à sua conta enquanto você verifica os novos termos.';

  @override
  String get termsReview => 'Revisar';

  @override
  String get termsTitle => 'Atualização de Termos';

  @override
  String get termsIntro =>
      'Os termos foram atualizados desde sua última visita';

  @override
  String get readPolicy => 'Ler';

  @override
  String get acceptTerms => 'Confirmar';

  @override
  String get termsAccepted =>
      'Obrigado por aceitar, agora você pode voltar ao fórum';

  @override
  String get privateDiscussions => 'Discussões Privadas';

  @override
  String get startPrivateDiscussion => 'Discutir em Particular';

  @override
  String privateWith(String names) {
    return 'Com $names';
  }

  @override
  String get addPerson => 'Destinatários';

  @override
  String get choosePerson =>
      'Esta discussão só será visível para os usuários que você escolher aqui. É necessário pelo menos 1 destinatário (além de você).';

  @override
  String get noPrivateDiscussions => 'Parece que não há discussões aqui.';

  @override
  String get privateOnlyOne =>
      'Este fórum permite escrever em privado para uma pessoa de cada vez.';

  @override
  String get messages => 'Mensagens';

  @override
  String get newMessage => 'Enviar uma Mensagem';

  @override
  String get noMessages => 'Sem novas mensagens';

  @override
  String get sendMessage => 'Enviar uma mensagem';

  @override
  String get messageHint => 'Escreva uma mensagem…';

  @override
  String get messagesLoadFailed => 'Não foi possível carregar as mensagens.';

  @override
  String get moderate => 'Moderar';

  @override
  String get renameDiscussion => 'Renomear';

  @override
  String get renameDiscussionTitle => 'Renomear Discussão';

  @override
  String get lockDiscussion => 'Bloquear';

  @override
  String get unlockDiscussion => 'Desbloquear';

  @override
  String get stickDiscussion => 'Fixar';

  @override
  String get unstickDiscussion => 'Desafixar';

  @override
  String get restore => 'Restaurar';

  @override
  String get deleteForever => 'Excluir para Sempre';

  @override
  String get deleteForeverConfirm =>
      'Tem certeza de que deseja excluir isto para sempre? Esta ação não pode ser desfeita.';

  @override
  String get approve => 'Aprovar';

  @override
  String get unsuspend => 'Remover suspensão';

  @override
  String suspendedUntil(String date) {
    return 'Suspenso até $date';
  }

  @override
  String get suspendedIndefinitely => 'Suspenso por tempo indeterminado';

  @override
  String youAreSuspended(String date) {
    return 'Esta suspensão estará em vigor até $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Esta conta está suspensa';

  @override
  String get awaitingApproval => 'Aguardando aprovação';

  @override
  String get badgeSticky => 'Fixada';

  @override
  String get badgeLocked => 'Trancada';

  @override
  String get badgeHidden => 'Oculto';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações',
      one: '1 publicação',
    );
    return '$user mesclou $_temp0 de $titles nesta discussão.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações',
      one: '1 publicação',
    );
    return '$user separou $_temp0 para $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações',
      one: '1 publicação',
    );
    return '$user separou $_temp0 de $title.';
  }

  @override
  String get errorNoConnection =>
      'Parece haver algo errado com sua conexão. Verifique sua rede e tente novamente.';

  @override
  String get errorTimedOut =>
      'O fórum demorou demais para responder. Tente novamente.';

  @override
  String get errorBlocked =>
      'O firewall do fórum bloqueou o aplicativo. Tente mais tarde ou abra o fórum em um navegador.';

  @override
  String get errorNotFound => 'O recurso solicitado não foi encontrado.';

  @override
  String get errorRateLimited =>
      'Você está indo um pouco rápido demais. Tente novamente em alguns segundos.';

  @override
  String get errorForumDown =>
      'O fórum não está respondendo no momento. Tente novamente mais tarde.';

  @override
  String get errorNotAllowed => 'Você não tem permissão para fazer isso.';

  @override
  String get errorUnknown => 'Opa! Algo deu errado. Tente novamente.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos registrados',
      one: '$count voto registrado',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opções',
      one: '$count opção',
    );
    return 'A enquete permite votar em $_temp0.';
  }

  @override
  String get pollEnded => 'Esta enquete terminou.';

  @override
  String pollEndsOn(String date) {
    return 'Enquete termina em $date.';
  }

  @override
  String get pollResultsAfterVoting =>
      'Você verá os resultados depois de votar.';

  @override
  String get pollResultsWhenClosed =>
      'Você verá os resultados quando a votação encerrar.';

  @override
  String get pollVote => 'Votar';

  @override
  String get pollRemoveVote => 'Retirar meu voto';

  @override
  String get pollSeeVoters => 'Ver quem votou';

  @override
  String get pollNoVotes => 'Sem Votos';

  @override
  String get poll => 'Enquete';

  @override
  String get pollNeedsQuestion => 'Você deve incluir uma pergunta';

  @override
  String get pollNeedsAnswers => 'Você deve incluir um mínimo de 2 respostas';

  @override
  String get pollEndInPast => 'Escolha um encerramento no futuro.';

  @override
  String get pollQuestion => 'Pergunta';

  @override
  String pollAnswer(int number) {
    return 'Resposta $number';
  }

  @override
  String get pollRemoveAnswer => 'Remover Resposta';

  @override
  String get pollAddAnswer => 'Adicionar Resposta';

  @override
  String get pollMultipleChoice => 'Permitir votar em várias opções';

  @override
  String get pollChoicesAllowed => 'Máximo de votos por usuário';

  @override
  String get pollAnyNumber => 'Sem limite';

  @override
  String get pollPublic => 'Permitir ver quem votou';

  @override
  String get pollAllowChangeVote => 'Permitir que os usuários alterem o voto';

  @override
  String get pollCloses => 'Data final da enquete (Opcional)';

  @override
  String get pollNeverCloses => 'Nunca';

  @override
  String get pollHideVotes => 'Ocultar votos até o fim da enquete';

  @override
  String get pollHideVotesNeedsEnd =>
      'Escolha primeiro quando a votação encerra.';

  @override
  String get addPoll => 'Adicionar Enquete';

  @override
  String get submit => 'Enviar';

  @override
  String get editPoll => 'Editar Enquete';

  @override
  String get removePoll => 'Remover Enquete';

  @override
  String get draftSaved => 'Salvo!';

  @override
  String get draftSavedWithoutPoll =>
      'Rascunho salvo, sem a enquete: rascunhos não guardam enquetes.';

  @override
  String get draftNeedsText => 'Escreva algo para salvar como rascunho.';

  @override
  String get drafts => 'Rascunhos';

  @override
  String get draftsLoadFailed => 'Não foi possível carregar seus rascunhos';

  @override
  String get noDrafts =>
      'Você não salvou nenhum rascunho. Feche uma publicação que você está escrevendo e escolha “Salvar rascunho” para guardá-la aqui.';

  @override
  String draftReplyTo(String title) {
    return 'Resposta a $title';
  }

  @override
  String get draftUntitled => 'Discussão sem título';

  @override
  String get deleteDraftQuestion =>
      'Tem certeza de que deseja excluir seu rascunho?';

  @override
  String get deleteDraft => 'Excluir rascunho';
}
