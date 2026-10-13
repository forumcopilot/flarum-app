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
  String get loadEarlierPosts => 'Cargar publicaciones anteriores';

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
  String get someone => 'Alguien';

  @override
  String get latest => 'Recientes';

  @override
  String get unread => 'Sin leer';

  @override
  String get search => 'Buscar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get profile => 'Perfil';

  @override
  String get following => 'Siguiendo';

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
  String get noDiscussions => 'Todavía no hay discusiones aquí.';

  @override
  String get discussionsLoadFailed => 'No se pudieron cargar las discusiones.';

  @override
  String get tagsLoadFailed => 'No se pudieron cargar las etiquetas.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get account => 'Cuenta';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String signInFailedReason(String reason) {
    return 'No se pudo iniciar sesión: $reason';
  }

  @override
  String get signInHint =>
      'Inicia sesión en la página del propio foro. La app mantiene tu sesión hasta que la cierres.';

  @override
  String signedInAs(String name) {
    return 'Sesión iniciada como $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String get failedToMarkNotificationsRead =>
      'No se pudieron marcar las notificaciones como leídas';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String notifNewPost(String user, String title) {
    return '$user respondió en $title';
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
    return '$user mencionó a un grupo al que perteneces en $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user renombró una discusión a $title';
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
    return '$user movió $title a una etiqueta que sigues';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user inició una discusión privada contigo: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user respondió en la discusión privada $title';
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
    return '$user eligió tu publicación como la mejor respuesta en $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user eligió una mejor respuesta en $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Elige una mejor respuesta en $title';
  }

  @override
  String notifMessage(String user) {
    return '$user te envió un mensaje';
  }

  @override
  String get notifSuspended => 'Tu cuenta fue suspendida';

  @override
  String get notifUnsuspended => 'Se levantó la suspensión de tu cuenta';

  @override
  String get notifExport => 'Tu exportación de datos está lista';

  @override
  String get notifOther => 'Nueva notificación';

  @override
  String get aDiscussion => 'una discusión';

  @override
  String get notificationsLoadFailed =>
      'No se pudieron cargar tus notificaciones.';

  @override
  String get notificationsSignIn =>
      'Inicia sesión para ver tus notificaciones.';

  @override
  String get markAllRead => 'Marcar todo como leído';

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
  String get noPostsYet => 'Todavía no hay publicaciones.';

  @override
  String searchFailedWithError(String error) {
    return 'Búsqueda fallida: $error';
  }

  @override
  String get searchHint => 'Buscar discusiones y publicaciones';

  @override
  String noResultsFor(String query) {
    return 'No se encontró nada para «$query».';
  }

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSystem => 'Sistema';

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
  String get repliesTitle => 'Respuestas';

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
  String get goToBestAnswer => 'Ir a la mejor respuesta';

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
  String get mentionUser => 'Mencionar usuario';

  @override
  String get title => 'Título';

  @override
  String get content => 'Contenido';

  @override
  String get send => 'Enviar';

  @override
  String get save => 'Guardar';

  @override
  String get formatting => 'Formato';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get pleaseEnterContent => 'Por favor ingresa algún contenido';

  @override
  String get composerTitleHint => 'Escribe tu título...';

  @override
  String get composerContentHint => 'Escribe tu contenido...';

  @override
  String get composerFormattingHint => 'Abrir opciones de formato';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get startDiscussion => 'Iniciar una discusión';

  @override
  String get editPost => 'Editar publicación';

  @override
  String get postingThrottled =>
      'Estás publicando demasiado rápido. Espera unos segundos e inténtalo de nuevo.';

  @override
  String get postAwaitingApproval =>
      'Enviado. Aparecerá cuando un moderador lo apruebe.';

  @override
  String get chooseTags => 'Elegir etiquetas';

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
  String get done => 'Listo';

  @override
  String get noMembersFound => 'No se encontraron miembros.';

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
  String get chooseBestAnswer => 'Elegir como mejor respuesta';

  @override
  String get removeBestAnswer => 'Quitar mejor respuesta';

  @override
  String get notificationSettings => 'Notificaciones de esta discusión';

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
      'No recibir avisos nunca y ocultarla de las listas.';

  @override
  String get tagFollowingHint => 'Recibir avisos de discusiones nuevas.';

  @override
  String get lurking => 'Observando';

  @override
  String get lurkingHint =>
      'Recibir avisos de discusiones nuevas y de cada respuesta.';

  @override
  String get tagIgnoringHint =>
      'No recibir avisos nunca de las discusiones de aquí.';

  @override
  String get hidden => 'Oculta';

  @override
  String get hiddenHint =>
      'Ocultar las discusiones de esta etiqueta de las listas.';

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
    return '$fileName pesa $fileBytes. Este foro permite hasta $maxBytes.';
  }

  @override
  String get flagAction => 'Reportar';

  @override
  String get ignoredUsers => 'Usuarios ignorados';

  @override
  String get ignoredUsersEmpty => 'No estás ignorando a nadie.';

  @override
  String get flagPostTitle => 'Reportar publicación';

  @override
  String get flagReasonOffTopic => 'Fuera de tema';

  @override
  String get flagReasonOffTopicText =>
      'Esta publicación no tiene que ver con la discusión actual y debería moverse a otro lugar.';

  @override
  String get flagReasonInappropriate => 'Inapropiado';

  @override
  String get flagReasonInappropriateText =>
      'Esta publicación es ofensiva, abusiva o incumple las normas de la comunidad.';

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
    return '¿Ignorar a $name? Sus publicaciones se plegarán. Puedes dejar de ignorarle desde tu cuenta.';
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
      'Acepta los términos actualizados de este foro para volver a publicar.';

  @override
  String get termsReview => 'Revisar';

  @override
  String get termsTitle => 'Términos actualizados';

  @override
  String get termsIntro =>
      'Antes de volver a publicar, acepta las políticas actualizadas del foro.';

  @override
  String get readPolicy => 'Leer';

  @override
  String get acceptTerms => 'Aceptar';

  @override
  String get termsAccepted => 'Gracias. Ya puedes volver a publicar.';

  @override
  String get privateDiscussions => 'Discusiones privadas';

  @override
  String get startPrivateDiscussion => 'Iniciar una discusión privada';

  @override
  String privateWith(String names) {
    return 'Con $names';
  }

  @override
  String get addPerson => 'Añadir a alguien';

  @override
  String get choosePerson => 'Elige a quién escribir.';

  @override
  String get noPrivateDiscussions => 'Aún no hay discusiones privadas.';

  @override
  String get privateOnlyOne =>
      'Este foro te permite escribir en privado a una sola persona a la vez.';
}
