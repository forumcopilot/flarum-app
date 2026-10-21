// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class FlarumLocalizationsRu extends FlarumLocalizations {
  FlarumLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get attachmentDefaultName => 'Вложение';

  @override
  String get share => 'Поделиться';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get linkCopied => 'Ссылка скопирована.';

  @override
  String get cancel => 'Отмена';

  @override
  String downloading(String filename) {
    return 'Загрузка $filename...';
  }

  @override
  String get download => 'Скачать';

  @override
  String errorDownloading(String filename, String error) {
    return 'Ошибка при загрузке $filename: $error';
  }

  @override
  String get video => 'Видео';

  @override
  String get viewOnWeb => 'Открыть в браузере';

  @override
  String get saveImage => 'Сохранить изображение';

  @override
  String get imageSaved => 'Изображение сохранено.';

  @override
  String get imageSaveFailed => 'Не удалось сохранить изображение.';

  @override
  String get imageSaveNotAllowed =>
      'Приложению не разрешено сохранять в фото. Это можно разрешить в настройках телефона.';

  @override
  String get mediaPause => 'Пауза';

  @override
  String get mediaPlay => 'Воспроизвести';

  @override
  String get failedToLoadVideo => 'Не удалось загрузить видео';

  @override
  String get close => 'Закрыть';

  @override
  String get spoiler => 'Спойлер';

  @override
  String get image => 'Изображение';

  @override
  String get fileTypeArchive => 'Архив';

  @override
  String get fileTypeAudio => 'Аудио';

  @override
  String get fileTypeFile => 'Файл';

  @override
  String get fileTypeText => 'Текст';

  @override
  String get retry => 'Повторить';

  @override
  String get edited => 'Изменено';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      few: '$count ответа',
      one: '1 ответ',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лайка',
      many: '$count лайков',
      few: '$count лайка',
      one: '$count лайк',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Показать ещё';

  @override
  String viewProfileOfUser(String username) {
    return 'Открыть профиль $username';
  }

  @override
  String get loadEarlierPosts => 'Показать ещё';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index из $count сообщения',
      many: '$index из $count сообщений',
      few: '$index из $count сообщений',
      one: '$index из $count сообщения',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => 'Начало';

  @override
  String get scrubberNow => 'Сейчас';

  @override
  String get postHidden => 'Это сообщение удалено.';

  @override
  String get threadLoadFailed => 'Не удалось загрузить обсуждение.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user изменил(а) заголовок с «$from» на «$to».';
  }

  @override
  String eventLocked(String user) {
    return '$user закрыл(а) обсуждение.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user открыл(а) обсуждение.';
  }

  @override
  String eventStickied(String user) {
    return '$user закрепил(а) обсуждение.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user открепил(а) обсуждение.';
  }

  @override
  String eventTagged(String user) {
    return '$user изменил(а) теги.';
  }

  @override
  String eventOther(String user) {
    return '$user изменил(а) обсуждение.';
  }

  @override
  String get someone => '[удалено]';

  @override
  String get latest => 'Последние';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get search => 'Поиск';

  @override
  String get signIn => 'Войти';

  @override
  String get logInToReply => 'Войти для ответа';

  @override
  String get cannotReply => 'Нельзя ответить';

  @override
  String get profile => 'Профиль';

  @override
  String get following => 'Подписки';

  @override
  String get follow => 'Подписаться';

  @override
  String get home => 'Главная';

  @override
  String get notifications => 'Уведомления';

  @override
  String get settings => 'Настройки';

  @override
  String get tags => 'Теги';

  @override
  String get filterTop => 'Обсуждаемые';

  @override
  String get viewNewest => 'Новые';

  @override
  String discussionReplied(String user, String time) {
    return '$user ответил(а) $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user начал(а) $time';
  }

  @override
  String get noDiscussions => 'Кажется, здесь нет обсуждений.';

  @override
  String get discussionsLoadFailed => 'Не удалось загрузить обсуждения.';

  @override
  String get tagsLoadFailed => 'Не удалось загрузить теги.';

  @override
  String get signOut => 'Выйти';

  @override
  String logOutQuestion(String forum) {
    return 'Вы уверены, что хотите выйти из $forum?';
  }

  @override
  String get account => 'Аккаунт';

  @override
  String get createAccount => 'Регистрация';

  @override
  String signInFailedReason(String reason) {
    return 'Не удалось войти: $reason';
  }

  @override
  String get signInHint =>
      'Войдите на странице самого форума. Приложение сохранит вход, пока вы не выйдете.';

  @override
  String signedInAs(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Все уведомления отмечены как прочитанные';

  @override
  String get failedToMarkNotificationsRead =>
      'Не удалось отметить уведомления как прочитанные';

  @override
  String get noNotificationsYet => 'Уведомления отсутствуют';

  @override
  String notifNewPost(String user, String title) {
    return '$user ответил(а) в обсуждении $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user оценил(а) ваше сообщение в обсуждении $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user отреагировал(а) на ваше сообщение в обсуждении $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user ответил(а) на ваше сообщение в обсуждении $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user упомянул(а) вас в обсуждении $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user упомянул(а) вашу группу в обсуждении $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user изменил(а) название на $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user закрыл(а) обсуждение $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user начал(а) обсуждение $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user изменил(а) тег обсуждения $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user начал(а) с вами новое личное обсуждение: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user ответил(а) в личном обсуждении, в котором вы участвуете: $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user добавил(а) вас в личное обсуждение $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user удалил(а) вас из личного обсуждения $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user сделал(а) обсуждение $title публичным';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return 'Ваше сообщение в обсуждении $title было выбрано в качестве лучшего ответа пользователем $user';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user выбрал(а) лучший ответ в обсуждении $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Пожалуйста, выберите в обсуждении $title сообщение с лучшим ответом на свой вопрос';
  }

  @override
  String notifMessage(String user) {
    return '$user отправил(а) вам сообщение';
  }

  @override
  String get notifSuspended => 'Ваш аккаунт заблокирован';

  @override
  String get notifUnsuspended => 'Вас разблокировали';

  @override
  String get notifExport => 'Экспорт ваших данных готов к скачиванию.';

  @override
  String get notifOther => 'Новое уведомление';

  @override
  String notifLineNewPost(String user) {
    return '$user ответил(а)';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user оценил(а) ваше сообщение';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user отреагировал(а) на ваше сообщение';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user ответил(а) на ваше сообщение';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user упомянул(а) вас';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user упомянул(а) группу, в которой вы состоите';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user изменил(а) название';
  }

  @override
  String notifLineLocked(String user) {
    return '$user закрыл(а) обсуждение';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user начал(а) обсуждение';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user изменил(а) тег';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user начал(а) с вами новое личное обсуждение';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user ответил(а) в личном обсуждении, в котором вы участвуете';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user добавил(а) вас в личное обсуждение';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user удалил(а) вас из личного обсуждения';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user удалил(а) всех участников и сделал(а) обсуждение публичным';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Ваше сообщение выбрано лучшим ответом пользователем $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user выбрал(а) лучший ответ в этом обсуждении';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Пожалуйста, выберите лучший ответ, если на ваш вопрос ответили';

  @override
  String get aDiscussion => 'обсуждение';

  @override
  String get notificationsLoadFailed => 'Не удалось загрузить уведомления.';

  @override
  String get notificationsSignIn => 'Войдите, чтобы видеть уведомления.';

  @override
  String get markAllRead => 'Отметить всё как прочитанное';

  @override
  String get markAllDiscussionsReadQuestion =>
      'Отметить все обсуждения прочитанными?';

  @override
  String get hideWelcomeMessage => 'Скрыть сообщение приветствия';

  @override
  String get posts => 'Сообщения';

  @override
  String get usersTab => 'Пользователи';

  @override
  String get likesTab => 'Симпатии';

  @override
  String get mentionsTab => 'Упоминания';

  @override
  String profileJoined(String date) {
    return 'С нами с $date';
  }

  @override
  String get discussionsTab => 'Обсуждения';

  @override
  String lastSeen(String time) {
    return 'Был(а) в сети $time';
  }

  @override
  String get online => 'В сети';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лучших ответа',
      many: '$count лучших ответов',
      few: '$count лучших ответа',
      one: '$count лучший ответ',
    );
    return '$_temp0';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions обсуждения',
      many: '$discussions обсуждений',
      few: '$discussions обсуждения',
      one: '$discussions обсуждение',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments сообщения',
      many: '$comments сообщений',
      few: '$comments сообщения',
      one: '$comments сообщение',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Не удалось загрузить профиль.';

  @override
  String get noPostsYet => 'Кажется, здесь нет сообщений.';

  @override
  String searchFailedWithError(String error) {
    return 'Поиск не удался: $error';
  }

  @override
  String get searchHint => 'Поиск';

  @override
  String get recentSearches => 'Недавние поиски';

  @override
  String get clearRecentSearches => 'Очистить';

  @override
  String noResultsFor(String query) {
    return 'Похоже, по запросу «$query» ничего не найдено.';
  }

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get appearance => 'Цветовая схема';

  @override
  String get appearanceSystem => 'Как в системе';

  @override
  String repliedByOne(String a) {
    return '$a ответил(а) на это.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a и $b ответили на это.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others',
    );
    return '$a, $b и ещё $_temp0 ответили на это.';
  }

  @override
  String get repliesTitle => 'Ответы на сообщение';

  @override
  String postNumber(int number) {
    return 'Сообщение №$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others',
    );
    return '$a и ещё $_temp0 ответили на это.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user добавил(а) $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user убрал(а) $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user добавил(а) $added и убрал(а) $removed.';
  }

  @override
  String get privateDiscussion => 'Личное обсуждение';

  @override
  String get bestAnswer => 'Лучший ответ';

  @override
  String get goToBestAnswer => 'Лучший ответ';

  @override
  String get answered => 'Есть ответ';

  @override
  String eventRecipientsChanged(String user) {
    return '$user изменил(а) участников этого личного обсуждения.';
  }

  @override
  String get noTagsOnForum => 'На этом форуме нет тегов.';

  @override
  String get permissionRequired => 'Нужно разрешение';

  @override
  String get bold => 'Жирный';

  @override
  String get underline => 'Подчеркнутый';

  @override
  String get strikethrough => 'Зачеркнутый';

  @override
  String get bulletList => 'Маркированный Список';

  @override
  String get numberedList => 'Нумерованный Список';

  @override
  String get listItem => 'Элемент Списка';

  @override
  String get mentionUser => 'Упоминание';

  @override
  String get title => 'Заголовок';

  @override
  String get content => 'Содержание';

  @override
  String get send => 'Отправить сообщение';

  @override
  String get postReply => 'Отправить';

  @override
  String get postDiscussion => 'Создать';

  @override
  String get postPrivateDiscussion => 'Отправить';

  @override
  String get save => 'Сохранить';

  @override
  String get formatting => 'Форматирование';

  @override
  String get pleaseEnterTitle => 'Пожалуйста, введите заголовок';

  @override
  String get pleaseEnterContent => 'Пожалуйста, введите содержимое';

  @override
  String get composerTitleHint => 'Название обсуждения';

  @override
  String get privateDiscussionTitleHint => 'Название личного обсуждения';

  @override
  String get composerContentHint => 'Введите сообщение...';

  @override
  String get composerReplyHint => 'Написать ответ...';

  @override
  String get composerFormattingHint => 'Открыть параметры форматирования';

  @override
  String get searchUsers => 'Поиск пользователей...';

  @override
  String get startDiscussion => 'Начать обсуждение';

  @override
  String get editPost => 'Редактировать сообщение';

  @override
  String get postingThrottled =>
      'Вы размещаете сообщения слишком часто. Пожалуйста, попробуйте ещё раз через несколько секунд.';

  @override
  String get postAwaitingApproval =>
      'Отправлено. Сообщение появится после одобрения модератором.';

  @override
  String get chooseTags => 'Выбрать теги';

  @override
  String get ok => 'ОК';

  @override
  String get primaryTags => 'Основные теги';

  @override
  String get secondaryTags => 'Другие теги';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выберите $count основных тега.',
      many: 'Выберите $count основных тегов.',
      few: 'Выберите $count основных тега.',
      one: 'Выберите $count основной тег.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выберите не больше $count основных тегов.',
      one: 'Выберите не больше $count основного тега.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выберите ещё $count тега.',
      many: 'Выберите ещё $count тегов.',
      few: 'Выберите ещё $count тега.',
      one: 'Выберите ещё $count тег.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выберите не больше $count дополнительных тегов.',
      one: 'Выберите не больше $count дополнительного тега.',
    );
    return '$_temp0';
  }

  @override
  String get noMembersFound => 'Пользователи не найдены.';

  @override
  String get memberSearchNotAllowed =>
      'На этом форуме нельзя искать участников.';

  @override
  String get editLoadFailed =>
      'Не удалось загрузить сообщение для редактирования.';

  @override
  String get like => 'Нравится';

  @override
  String get unlike => 'Больше не нравится';

  @override
  String likedByOne(String a) {
    return '$a оценил(а) это.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a и $b оценили это.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others человека',
      many: '$others человек',
      few: '$others человека',
      one: '$others человек',
    );
    return '$a и ещё $_temp0 оценили это.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others человека',
      many: '$others человек',
      few: '$others человека',
      one: '$others человек',
    );
    return '$a, $b и ещё $_temp0 оценили это.';
  }

  @override
  String get likedByYou => 'Вы оценили это.';

  @override
  String likedByYouAndOne(String a) {
    return 'Вы и $a оценили это.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others человека',
      many: '$others человек',
      few: '$others человека',
      one: '$others человек',
    );
    return 'Вы, $a и ещё $_temp0 оценили это.';
  }

  @override
  String get react => 'Реакция';

  @override
  String get reactions => 'Реакции';

  @override
  String get bookmark => 'В закладки';

  @override
  String get removeBookmark => 'Удалить из закладок';

  @override
  String get bookmarks => 'Закладки';

  @override
  String get noBookmarks => 'В закладках пока ничего нет.';

  @override
  String get chooseBestAnswer => 'Это лучший ответ';

  @override
  String get removeBestAnswer => 'Отменить лучший ответ';

  @override
  String get notFollowing => 'Не отслеживается';

  @override
  String get notFollowingHint => 'Уведомлять, только когда вас @упомянут.';

  @override
  String get followingHint => 'Уведомлять обо всех ответах.';

  @override
  String get ignoring => 'Игнорируется';

  @override
  String get ignoringHint =>
      'Отключить уведомления обсуждения и скрыть его из общего списка.';

  @override
  String get tagFollowingHint =>
      'Получать уведомления обо всех новых обсуждениях.';

  @override
  String get lurking => 'Наблюдение';

  @override
  String get lurkingHint =>
      'Получать уведомления обо всех новых обсуждениях и сообщениях.';

  @override
  String get tagIgnoringHint => 'Никогда не уведомлять.';

  @override
  String get hidden => 'Скрыт';

  @override
  String get hiddenHint => 'Скрыть обсуждения со страницы всех обсуждений.';

  @override
  String get attachFile => 'Прикрепить файл';

  @override
  String get uploadImage => 'Загрузить изображение';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String uploadingFilename(String filename) {
    return 'Загрузка: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Не удалось загрузить файл: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Дождитесь окончания загрузки вложений';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName уменьшен до $size$dimensions, чтобы уложиться в ограничение $limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: слишком большой файл ($size), уменьшить не удалось. Ограничение — $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return 'Размер $fileName: $fileBytes. Файлы размером более $maxBytes запрещены.';
  }

  @override
  String get flagAction => 'Пожаловаться';

  @override
  String get ignoredUsers => 'Игнорируемые пользователи';

  @override
  String get ignoredUsersEmpty => 'У вас нет игнорируемых пользователей.';

  @override
  String get flagPostTitle => 'Пожаловаться на сообщение';

  @override
  String get flagReasonOffTopic => 'Не по теме';

  @override
  String get flagReasonOffTopicText =>
      'Это сообщение не относится к обсуждению, его стоит перенести.';

  @override
  String get flagReasonInappropriate => 'Неприемлемо';

  @override
  String get flagReasonInappropriateText =>
      'Сообщение носит оскорбительный характер или нарушает правила сообщества.';

  @override
  String get flagReasonSpam => 'Спам';

  @override
  String get flagReasonSpamText => 'Это сообщение — реклама.';

  @override
  String get flagReasonOther => 'Другое (уточните)';

  @override
  String get flagDetails => 'Подробности (необязательно)';

  @override
  String get flagDetailsNeeded => 'Опишите проблему для модераторов.';

  @override
  String get communityGuidelines => 'Правила сообщества';

  @override
  String get flagSent => 'Спасибо за жалобу. Модераторы её рассмотрят.';

  @override
  String ignoreUser(String name) {
    return 'Игнорировать $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Не игнорировать $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Вы уверены, что хотите игнорировать пользователя $name?';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Сообщение от $name, которого вы игнорируете.';
  }

  @override
  String get showPost => 'Показать сообщение';

  @override
  String get ignoredOnThisPhone =>
      'Этот форум не хранит список игнорируемых, поэтому приложение хранит ваш на этом телефоне.';

  @override
  String get stopIgnoring => 'Не игнорировать';

  @override
  String get termsBanner =>
      'Доступ к вашей учётной записи временно ограничен до ознакомления и принятия новых условий.';

  @override
  String get termsReview => 'Просмотреть';

  @override
  String get termsTitle => 'Обновление условий';

  @override
  String get termsIntro =>
      'Условия были обновлены с последней даты вашего посещения';

  @override
  String get readPolicy => 'Читать';

  @override
  String get acceptTerms => 'Подтвердить';

  @override
  String get termsAccepted => 'Спасибо, теперь можно вернуться на форум';

  @override
  String get privateDiscussions => 'Личные обсуждения';

  @override
  String get startPrivateDiscussion => 'Написать';

  @override
  String privateWith(String names) {
    return 'С $names';
  }

  @override
  String get addPerson => 'Участники';

  @override
  String get choosePerson =>
      'Это обсуждение будет видно только выбранным вами участникам. Требуется как минимум 1 участник, кроме вас.';

  @override
  String get noPrivateDiscussions => 'Кажется, здесь нет обсуждений.';

  @override
  String get privateOnlyOne =>
      'На этом форуме можно писать лично только одному человеку за раз.';

  @override
  String get messages => 'Сообщения';

  @override
  String get newMessage => 'Написать сообщение';

  @override
  String get noMessages => 'Нет новых сообщений';

  @override
  String get sendMessage => 'Отправить сообщение';

  @override
  String get messageHint => 'Напишите сообщение…';

  @override
  String get messagesLoadFailed => 'Не удалось загрузить сообщения.';

  @override
  String get moderate => 'Модерация';

  @override
  String get renameDiscussion => 'Переименовать';

  @override
  String get renameDiscussionTitle => 'Изменение названия';

  @override
  String get lockDiscussion => 'Закрыть';

  @override
  String get unlockDiscussion => 'Открыть';

  @override
  String get stickDiscussion => 'Закрепить';

  @override
  String get unstickDiscussion => 'Открепить';

  @override
  String get restore => 'Восстановить';

  @override
  String get deleteForever => 'Удалить навсегда';

  @override
  String get deleteForeverConfirm =>
      'Вы уверены, что хотите удалить это навсегда? Это действие невозможно отменить.';

  @override
  String get approve => 'Одобрить';

  @override
  String get unsuspend => 'Снять блокировку';

  @override
  String suspendedUntil(String date) {
    return 'Заблокирован до $date';
  }

  @override
  String get suspendedIndefinitely => 'Заблокирован бессрочно';

  @override
  String youAreSuspended(String date) {
    return 'Блокировка истекает $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Аккаунт заблокирован';

  @override
  String get awaitingApproval => 'Ожидает одобрения';

  @override
  String get badgeSticky => 'Закреплено';

  @override
  String get badgeLocked => 'Закрыто';

  @override
  String get badgeHidden => 'Скрыто';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$user объединил(а) $_temp0 из $titles с этим обсуждением.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$user перенёс(ла) $_temp0 в $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$user отделил(а) $_temp0 из $title.';
  }

  @override
  String get errorNoConnection =>
      'Похоже, возникли проблемы с сетью. Проверьте соединение и попробуйте снова.';

  @override
  String get errorTimedOut =>
      'Форум слишком долго не отвечает. Повторите попытку.';

  @override
  String get errorBlocked =>
      'Брандмауэр форума заблокировал приложение. Повторите попытку позже или откройте форум в браузере.';

  @override
  String get errorNotFound => 'Запрашиваемый ресурс не найден.';

  @override
  String get errorRateLimited =>
      'Вы делаете это слишком часто. Подождите немного и повторите попытку.';

  @override
  String get errorForumDown =>
      'Форум сейчас не отвечает. Повторите попытку позже.';

  @override
  String get errorNotAllowed =>
      'У вас нет прав доступа для выполнения этого действия.';

  @override
  String get errorUnknown =>
      'Упс! Что-то пошло не так. Пожалуйста, попробуйте ещё раз.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count голоса получено',
      many: '$count голосов получено',
      few: '$count голоса получено',
      one: '$count голос получен',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count варианта',
      many: '$count вариантов',
      few: '$count варианта',
      one: '$count вариант',
    );
    return 'Опрос позволяет голосовать за $_temp0.';
  }

  @override
  String get pollEnded => 'Опрос завершён.';

  @override
  String pollEndsOn(String date) {
    return 'Опрос завершится: $date.';
  }

  @override
  String get pollResultsAfterVoting =>
      'Результаты будут видны после того, как вы проголосуете.';

  @override
  String get pollResultsWhenClosed =>
      'Результаты будут видны, когда голосование завершится.';

  @override
  String get pollVote => 'Проголосовать';

  @override
  String get pollRemoveVote => 'Отозвать мой голос';

  @override
  String get pollSeeVoters => 'Посмотреть голоса';

  @override
  String get pollNoVotes => 'Голоса отсутствуют';

  @override
  String get poll => 'Опрос';

  @override
  String get pollNeedsQuestion => 'Вы должны указать вопрос';

  @override
  String get pollNeedsAnswers => 'Вы должны добавить минимум 2 варианта';

  @override
  String get pollEndInPast => 'Выберите время завершения в будущем.';

  @override
  String get pollQuestion => 'Вопрос';

  @override
  String pollAnswer(int number) {
    return 'Ответ $number';
  }

  @override
  String get pollRemoveAnswer => 'Удалить ответ';

  @override
  String get pollAddAnswer => 'Добавить ответ';

  @override
  String get pollMultipleChoice => 'Разрешить выбор нескольких вариантов';

  @override
  String get pollChoicesAllowed => 'Максимум голосов на участника';

  @override
  String get pollAnyNumber => 'Сколько угодно';

  @override
  String get pollPublic => 'Публичный опрос';

  @override
  String get pollAllowChangeVote => 'Разрешить участникам изменять свой голос';

  @override
  String get pollCloses => 'Дата завершения опроса (опционально)';

  @override
  String get pollNeverCloses => 'Никогда';

  @override
  String get pollHideVotes => 'Скрыть голоса до завершения опроса';

  @override
  String get pollHideVotesNeedsEnd =>
      'Сначала выберите, когда голосование завершится.';

  @override
  String get addPoll => 'Добавить опрос';

  @override
  String get submit => 'Сохранить';

  @override
  String get editPoll => 'Изменить опрос';

  @override
  String get removePoll => 'Удалить опрос';

  @override
  String get draftSaved => 'Сохранено!';

  @override
  String get draftSavedWithoutPoll =>
      'Черновик сохранён без опроса: черновики не хранят опросы.';

  @override
  String get draftNeedsText => 'Напишите что-нибудь, чтобы сохранить черновик.';

  @override
  String get drafts => 'Черновики';

  @override
  String get draftsLoadFailed => 'Не удалось загрузить ваши черновики';

  @override
  String get noDrafts =>
      'У вас нет сохранённых черновиков. Закройте сообщение, которое пишете, и выберите «Сохранить черновик», чтобы сохранить его здесь.';

  @override
  String draftReplyTo(String title) {
    return 'Ответ в «$title»';
  }

  @override
  String get draftUntitled => 'Обсуждение без названия';

  @override
  String get deleteDraftQuestion => 'Вы уверены, что хотите удалить черновик?';

  @override
  String get deleteDraft => 'Удалить черновик';
}
