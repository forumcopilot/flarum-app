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
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Enlace copiado.';

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
  String get edited => 'Editado';

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
  String get loadEarlierPosts => 'Cargar más';

  @override
  String get postHidden => 'Esta publicación fue eliminada.';

  @override
  String get threadLoadFailed => 'No se pudo cargar esta discusión.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user cambió el título de «$from» a «$to».';
  }

  @override
  String eventLocked(String user) {
    return '$user cerró la discusión.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user reabrió la discusión.';
  }

  @override
  String eventStickied(String user) {
    return '$user fijó la discusión.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user desfijó la discusión.';
  }

  @override
  String eventTagged(String user) {
    return '$user cambió las etiquetas.';
  }

  @override
  String eventOther(String user) {
    return '$user modificó la discusión.';
  }

  @override
  String get someone => '[borrado]';

  @override
  String get latest => 'Recientes';

  @override
  String get unread => 'Sin leer';

  @override
  String get search => 'Buscar';

  @override
  String get signIn => 'Acceder';

  @override
  String get logInToReply => 'Accede para responder';

  @override
  String get cannotReply => 'No puedes responder';

  @override
  String get profile => 'Perfil';

  @override
  String get following => 'Siguiendo';

  @override
  String get follow => 'Seguir';

  @override
  String get home => 'Inicio';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get settings => 'Ajustes';

  @override
  String get tags => 'Etiquetas';

  @override
  String get filterTop => 'Destacados';

  @override
  String get viewNewest => 'Nuevas';

  @override
  String discussionReplied(String user, String time) {
    return '$user respondió $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user la inició $time';
  }

  @override
  String get noDiscussions => 'Parece que no hay discusiones aquí.';

  @override
  String get discussionsLoadFailed => 'No se pudieron cargar las discusiones.';

  @override
  String get tagsLoadFailed => 'No se pudieron cargar las etiquetas.';

  @override
  String get signOut => 'Desconectarse';

  @override
  String logOutQuestion(String forum) {
    return '¿Seguro que quieres desconectarte de $forum?';
  }

  @override
  String get account => 'Cuenta';

  @override
  String get createAccount => 'Regístrate';

  @override
  String signInFailedReason(String reason) {
    return 'No se pudo acceder: $reason';
  }

  @override
  String get signInHint =>
      'Accede en la página del propio foro. La app te mantiene conectado hasta que te desconectes.';

  @override
  String signedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String get failedToMarkNotificationsRead =>
      'No se pudieron marcar las notificaciones como leídas';

  @override
  String get noNotificationsYet => 'No hay notificaciones';

  @override
  String notifNewPost(String user, String title) {
    return '$user publicó en $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return 'A $user le gustó tu publicación en $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user reaccionó a tu publicación en $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user respondió a tu publicación en $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user te mencionó en $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user mencionó un grupo del que eres miembro en $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user cambió el título a $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user cerró $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user inició $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user cambió la etiqueta de $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user inició una nueva discusión privada contigo: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user publicó en una discusión privada de la que formas parte: $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user te añadió a la discusión privada $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user te quitó de la discusión privada $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user hizo pública $title';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return 'Tu mensaje fue seleccionado como la mejor respuesta por $user en $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user escogió la mejor respuesta en $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Por favor, selecciona la mejor respuesta en $title si tu duda fue resuelta';
  }

  @override
  String notifMessage(String user) {
    return '$user te envió un mensaje';
  }

  @override
  String get notifSuspended => 'Tu cuenta fue suspendida';

  @override
  String get notifUnsuspended => 'Te han quitado la suspensión';

  @override
  String get notifExport =>
      'Tus datos exportados ya están listos para descargar.';

  @override
  String get notifOther => 'Nueva notificación';

  @override
  String notifLineNewPost(String user) {
    return '$user publicó';
  }

  @override
  String notifLinePostLiked(String user) {
    return 'A $user le gustó tu publicación';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user reaccionó a tu publicación';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user respondió a tu publicación';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user te mencionó';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user mencionó un grupo del que eres miembro';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user cambió el título';
  }

  @override
  String notifLineLocked(String user) {
    return '$user la cerró';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user la inició';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user cambió la etiqueta';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user inició una nueva discusión privada contigo';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user publicó en una discusión privada de la que formas parte';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user te agregó a una discusión privada';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user te quitó de una discusión privada';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user eliminó a todos los destinatarios e hizo pública la discusión';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Tu mensaje fue seleccionado como la mejor respuesta por $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user escogió la mejor respuesta en esta discusión';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Por favor, selecciona la Mejor Respuesta si tu duda fue resuelta';

  @override
  String get aDiscussion => 'una discusión';

  @override
  String get notificationsLoadFailed =>
      'No se pudieron cargar tus notificaciones.';

  @override
  String get notificationsSignIn => 'Accede para ver tus notificaciones.';

  @override
  String get markAllRead => 'Marcar todas como leídas';

  @override
  String get markAllDiscussionsReadQuestion =>
      '¿Estás seguro de que deseas marcar todas las discusiones como leídas?';

  @override
  String get hideWelcomeMessage => 'Ocultar el mensaje de bienvenida';

  @override
  String get posts => 'Publicaciones';

  @override
  String profileJoined(String date) {
    return 'Se unió en $date';
  }

  @override
  String get discussionsTab => 'Discusiones';

  @override
  String lastSeen(String time) {
    return 'Última vez $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discusiones',
      one: '1 discusión',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments publicaciones',
      one: '1 publicación',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'No se pudo cargar este perfil.';

  @override
  String get noPostsYet => 'Parece que no hay publicaciones aquí.';

  @override
  String searchFailedWithError(String error) {
    return 'Búsqueda fallida: $error';
  }

  @override
  String get searchHint => 'Buscar en el foro';

  @override
  String noResultsFor(String query) {
    return 'Parece que no hay resultados para «$query».';
  }

  @override
  String get light => 'Modo claro';

  @override
  String get dark => 'Modo oscuro';

  @override
  String get appearance => 'Combinación de colores';

  @override
  String get appearanceSystem => 'Preferencias del sistema';

  @override
  String repliedByOne(String a) {
    return '$a respondió a esto.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a y $b respondieron a esto.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others más',
      one: '1 más',
    );
    return '$a, $b y $_temp0 respondieron a esto.';
  }

  @override
  String get repliesTitle => 'Respuestas a esta publicación';

  @override
  String postNumber(int number) {
    return 'Publicación #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others más',
      one: '1 más',
    );
    return '$a y $_temp0 respondieron a esto.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user añadió $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user quitó $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user añadió $added y quitó $removed.';
  }

  @override
  String get privateDiscussion => 'Discusión privada';

  @override
  String get bestAnswer => 'Mejor respuesta';

  @override
  String get goToBestAnswer => 'Ver mejor respuesta';

  @override
  String get answered => 'Respondida';

  @override
  String eventRecipientsChanged(String user) {
    return '$user cambió quién participa en esta discusión privada.';
  }

  @override
  String get noTagsOnForum => 'Este foro no usa etiquetas.';

  @override
  String get permissionRequired => 'Se requiere permiso';

  @override
  String get bold => 'Negrita';

  @override
  String get underline => 'Subrayado';

  @override
  String get strikethrough => 'Tachado';

  @override
  String get bulletList => 'Lista con Viñetas';

  @override
  String get numberedList => 'Lista Numerada';

  @override
  String get listItem => 'Elemento de Lista';

  @override
  String get mentionUser => 'Mencionar a un usuario, grupo o publicación';

  @override
  String get title => 'Título';

  @override
  String get content => 'Contenido';

  @override
  String get send => 'Enviar mensaje';

  @override
  String get postReply => 'Publicar respuesta';

  @override
  String get postDiscussion => 'Publicar discusión';

  @override
  String get postPrivateDiscussion => 'Publicar discusión privada';

  @override
  String get save => 'Guardar cambios';

  @override
  String get formatting => 'Formato';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get pleaseEnterContent => 'Por favor ingresa algún contenido';

  @override
  String get composerTitleHint => 'Título de la discusión';

  @override
  String get privateDiscussionTitleHint => 'Título de la discusión privada';

  @override
  String get composerContentHint => 'Escribe una publicación...';

  @override
  String get composerReplyHint => 'Escribe una respuesta...';

  @override
  String get composerFormattingHint => 'Abrir opciones de formato';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get startDiscussion => 'Crear discusión';

  @override
  String get editPost => 'Editar publicación';

  @override
  String get postingThrottled =>
      'Vas muy rápido. Por favor, vuelve a intentarlo en unos segundos.';

  @override
  String get postAwaitingApproval =>
      'Enviado. Aparecerá cuando un moderador lo apruebe.';

  @override
  String get chooseTags => 'Selecciona etiquetas';

  @override
  String get ok => 'Aceptar';

  @override
  String get primaryTags => 'Etiquetas principales';

  @override
  String get secondaryTags => 'Más etiquetas';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elige $count etiquetas principales.',
      one: 'Elige una etiqueta principal.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elige como máximo $count etiquetas principales.',
      one: 'Elige solo una etiqueta principal.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elige $count etiquetas más.',
      one: 'Elige 1 etiqueta más.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elige como máximo $count etiquetas más.',
      one: 'Elige como máximo 1 etiqueta más.',
    );
    return '$_temp0';
  }

  @override
  String get noMembersFound =>
      'No se encontraron usuarios que coincidieran con tu búsqueda.';

  @override
  String get memberSearchNotAllowed => 'Este foro no permite buscar miembros.';

  @override
  String get editLoadFailed =>
      'No se pudo cargar esta publicación para editarla.';

  @override
  String get like => 'Me gusta';

  @override
  String get unlike => 'Ya no me gusta';

  @override
  String likedByOne(String a) {
    return 'A $a le gusta esto.';
  }

  @override
  String likedByTwo(String a, String b) {
    return 'A $a y $b les gusta esto.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others personas más',
      one: '1 persona más',
    );
    return 'A $a y $_temp0 les gusta esto.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others personas más',
      one: '1 persona más',
    );
    return 'A $a, $b y $_temp0 les gusta esto.';
  }

  @override
  String get likedByYou => 'Te gusta esto.';

  @override
  String likedByYouAndOne(String a) {
    return 'A ti y a $a les gusta esto.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others personas más',
      one: '1 persona más',
    );
    return 'A ti, a $a y a $_temp0 les gusta esto.';
  }

  @override
  String get react => 'Reaccionar';

  @override
  String get reactions => 'Reacciones';

  @override
  String get bookmark => 'Guardar';

  @override
  String get removeBookmark => 'Quitar de guardados';

  @override
  String get bookmarks => 'Guardados';

  @override
  String get noBookmarks => 'Todavía no hay guardados.';

  @override
  String get chooseBestAnswer => 'Seleccionar mejor respuesta';

  @override
  String get removeBestAnswer => 'Desmarcar mejor respuesta';

  @override
  String get notFollowing => 'Sin seguir';

  @override
  String get notFollowingHint => 'Recibir avisos solo cuando te mencionen.';

  @override
  String get followingHint => 'Recibir avisos de todas las respuestas.';

  @override
  String get ignoring => 'Ignorando';

  @override
  String get ignoringHint =>
      'No ser notificado nunca. Ocultar de la lista de discusiones.';

  @override
  String get tagFollowingHint =>
      'Recibir notificaciones de todas las nuevas discusiones.';

  @override
  String get lurking => 'Observando';

  @override
  String get lurkingHint =>
      'Recibir notificaciones de todas las nuevas discusiones y respuestas.';

  @override
  String get tagIgnoringHint => 'Nunca recibir notificaciones.';

  @override
  String get hidden => 'Ocultando';

  @override
  String get hiddenHint =>
      'Ocultar discusiones de la página Todas las discusiones.';

  @override
  String get attachFile => 'Adjuntar archivo';

  @override
  String get uploadImage => 'Subir imagen';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String uploadingFilename(String filename) {
    return 'Subiendo: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'No se pudo subir el archivo: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Espera a que terminen de subirse los adjuntos';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName se redujo a $size$dimensions para ajustarse al límite de $limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: demasiado grande ($size) y no se pudo reducir. El límite es $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName pesa $fileBytes. No se aceptan subidas de más de $maxBytes.';
  }

  @override
  String get flagAction => 'Reportar';

  @override
  String get ignoredUsers => 'Usuarios ignorados';

  @override
  String get ignoredUsersEmpty => 'No estás ignorando a nadie.';

  @override
  String get flagPostTitle => 'Reportar mensaje';

  @override
  String get flagReasonOffTopic => 'Fuera de tema';

  @override
  String get flagReasonOffTopicText =>
      'Esta publicación no tiene que ver con la discusión actual y debería moverse a otro lugar.';

  @override
  String get flagReasonInappropriate => 'Inapropiado';

  @override
  String get flagReasonInappropriateText =>
      'Este mensaje es ofensivo, inapropiado o viola las normas del foro.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Esta publicación es publicidad.';

  @override
  String get flagReasonOther => 'Otro (especifica)';

  @override
  String get flagDetails => 'Detalles adicionales (opcional)';

  @override
  String get flagDetailsNeeded => 'Da algunos detalles a los moderadores.';

  @override
  String get communityGuidelines => 'Normas de la comunidad';

  @override
  String get flagSent =>
      'Gracias por reportar esta publicación. Nuestros moderadores la revisarán.';

  @override
  String ignoreUser(String name) {
    return 'Ignorar a $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Dejar de ignorar a $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '¿Seguro que quieres ignorar a $name?';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Una publicación de $name, a quien ignoras.';
  }

  @override
  String get showPost => 'Mostrar publicación';

  @override
  String get ignoredOnThisPhone =>
      'Este foro no guarda una lista de usuarios ignorados, así que la app guarda la tuya en este teléfono.';

  @override
  String get stopIgnoring => 'Dejar de ignorar';

  @override
  String get termsBanner =>
      'Hemos restringido temporalmente el acceso a tu cuenta mientras revisas los nuevos términos.';

  @override
  String get termsReview => 'Revisar';

  @override
  String get termsTitle => 'Actualización de términos de uso';

  @override
  String get termsIntro =>
      'Los términos se actualizaron desde tu última visita';

  @override
  String get readPolicy => 'Leer';

  @override
  String get acceptTerms => 'Confirmar';

  @override
  String get termsAccepted =>
      'Gracias por aceptarlo, ahora puedes volver al foro';

  @override
  String get privateDiscussions => 'Discusiones privadas';

  @override
  String get startPrivateDiscussion => 'Discutir en privado';

  @override
  String privateWith(String names) {
    return 'Con $names';
  }

  @override
  String get addPerson => 'Destinatarios';

  @override
  String get choosePerson =>
      'Esta discusión solo será visible para los usuarios que elijas aquí. Se requiere al menos 1 destinatario (además de ti).';

  @override
  String get noPrivateDiscussions => 'Parece que no hay discusiones aquí.';

  @override
  String get privateOnlyOne =>
      'Este foro te permite escribir en privado a una sola persona a la vez.';

  @override
  String get messages => 'Mensajes';

  @override
  String get newMessage => 'Enviar un mensaje';

  @override
  String get noMessages => 'Sin nuevos mensajes';

  @override
  String get sendMessage => 'Enviar un mensaje';

  @override
  String get messageHint => 'Escribe un mensaje…';

  @override
  String get messagesLoadFailed => 'No se pudieron cargar los mensajes.';

  @override
  String get moderate => 'Moderar';

  @override
  String get renameDiscussion => 'Renombrar';

  @override
  String get renameDiscussionTitle => 'Cambiar el título de esta discusión';

  @override
  String get lockDiscussion => 'Bloquear';

  @override
  String get unlockDiscussion => 'Desbloquear';

  @override
  String get stickDiscussion => 'Fijar';

  @override
  String get unstickDiscussion => 'Desfijar';

  @override
  String get restore => 'Restaurar';

  @override
  String get deleteForever => 'Eliminar para siempre';

  @override
  String get deleteForeverConfirm =>
      '¿Estás seguro de que deseas eliminar esto para siempre? Esta acción no se puede deshacer.';

  @override
  String get approve => 'Aprobar';

  @override
  String get unsuspend => 'Levantar suspensión';

  @override
  String suspendedUntil(String date) {
    return 'Suspendido hasta $date';
  }

  @override
  String get suspendedIndefinitely => 'Suspendido indefinidamente';

  @override
  String youAreSuspended(String date) {
    return 'Esta suspensión estará en vigor hasta el $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Esta cuenta está suspendida';

  @override
  String get awaitingApproval => 'Pendiente de aprobación';

  @override
  String get badgeSticky => 'Fijada';

  @override
  String get badgeLocked => 'Cerrada';

  @override
  String get badgeHidden => 'Oculto';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones',
      one: '1 publicación',
    );
    return '$user fusionó $_temp0 de $titles en esta discusión.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones',
      one: '1 publicación',
    );
    return '$user separó $_temp0 a $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones',
      one: '1 publicación',
    );
    return '$user separó $_temp0 de $title.';
  }

  @override
  String get errorNoConnection =>
      'Parece que hay algún problema con tu conexión. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get errorTimedOut =>
      'El foro tardó demasiado en responder. Inténtalo de nuevo.';

  @override
  String get errorBlocked =>
      'El cortafuegos del foro bloqueó la aplicación. Inténtalo más tarde o abre el foro en un navegador.';

  @override
  String get errorNotFound => 'El recurso solicitado no fue encontrado.';

  @override
  String get errorRateLimited =>
      'Vas muy rápido. Por favor, vuelve a intentarlo en unos segundos.';

  @override
  String get errorForumDown =>
      'El foro no responde en este momento. Inténtalo más tarde.';

  @override
  String get errorNotAllowed => 'No tienes permiso para hacer eso.';

  @override
  String get errorUnknown =>
      '¡Caramba! Algo salió mal. Por favor, vuelve a intentarlo.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opciones',
      one: '$count opción',
    );
    return 'La encuesta permite votar por $_temp0.';
  }

  @override
  String get pollEnded => 'Esta encuesta ha terminado.';

  @override
  String pollEndsOn(String date) {
    return 'La encuesta termina el $date.';
  }

  @override
  String get pollResultsAfterVoting => 'Verás los resultados cuando votes.';

  @override
  String get pollResultsWhenClosed =>
      'Verás los resultados cuando termine la votación.';

  @override
  String get pollVote => 'Votar';

  @override
  String get pollRemoveVote => 'Retirar mi voto';

  @override
  String get pollSeeVoters => 'Ver los votantes';

  @override
  String get pollNoVotes => 'Sin votos';

  @override
  String get poll => 'Encuesta';

  @override
  String get pollNeedsQuestion => 'Debes incluir una pregunta';

  @override
  String get pollNeedsAnswers => 'Debes incluir un mínimo de 2 respuestas';

  @override
  String get pollEndInPast => 'Elige un cierre en el futuro.';

  @override
  String get pollQuestion => 'Pregunta';

  @override
  String pollAnswer(int number) {
    return 'Respuesta $number';
  }

  @override
  String get pollRemoveAnswer => 'Eliminar respuesta';

  @override
  String get pollAddAnswer => 'Añadir respuesta';

  @override
  String get pollMultipleChoice => 'Permitir votar a varias opciones';

  @override
  String get pollChoicesAllowed => 'Número máximo de votos por usuario';

  @override
  String get pollAnyNumber => 'Sin límite';

  @override
  String get pollPublic => 'Permitir que la gente vea quién ha votado';

  @override
  String get pollAllowChangeVote => 'Permitir a los usuarios cambiar su voto';

  @override
  String get pollCloses => 'Fecha de finalización de la encuesta (opcional)';

  @override
  String get pollNeverCloses => 'Nunca';

  @override
  String get pollHideVotes =>
      'Ocultar los votos hasta que finalice la encuesta';

  @override
  String get pollHideVotesNeedsEnd =>
      'Primero elige cuándo termina la votación.';

  @override
  String get addPoll => 'Añadir encuesta';

  @override
  String get submit => 'Enviar';

  @override
  String get editPoll => 'Editar la encuesta';

  @override
  String get removePoll => 'Eliminar la encuesta';

  @override
  String get draftSaved => '¡Guardado!';

  @override
  String get draftSavedWithoutPoll =>
      'Borrador guardado, sin la encuesta: los borradores no guardan encuestas.';

  @override
  String get draftNeedsText => 'Escribe algo para guardarlo como borrador.';

  @override
  String get drafts => 'Borradores';

  @override
  String get draftsLoadFailed => 'No se pudieron cargar tus borradores';

  @override
  String get noDrafts =>
      'No has guardado ningún borrador. Cierra un mensaje que estés escribiendo y elige «Guardar borrador» para guardarlo aquí.';

  @override
  String draftReplyTo(String title) {
    return 'Respuesta a $title';
  }

  @override
  String get draftUntitled => 'Discusión sin título';

  @override
  String get deleteDraftQuestion => '¿Seguro que quieres eliminar tu borrador?';

  @override
  String get deleteDraft => 'Eliminar borrador';
}
