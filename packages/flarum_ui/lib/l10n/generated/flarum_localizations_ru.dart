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
  String get edited => 'изменено';

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
  String get loadMore => 'Загрузить ещё';

  @override
  String viewProfileOfUser(String username) {
    return 'Открыть профиль $username';
  }

  @override
  String get loadEarlierPosts => 'Загрузить предыдущие сообщения';

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
  String get someone => 'Кто-то';

  @override
  String get latest => 'Последние';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get search => 'Поиск';

  @override
  String get signIn => 'Войти';

  @override
  String get profile => 'Профиль';

  @override
  String get following => 'Подписки';

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
  String get noDiscussions => 'Здесь пока нет обсуждений.';

  @override
  String get discussionsLoadFailed => 'Не удалось загрузить обсуждения.';

  @override
  String get tagsLoadFailed => 'Не удалось загрузить теги.';

  @override
  String get signOut => 'Выйти';

  @override
  String get account => 'Аккаунт';

  @override
  String get createAccount => 'Создать аккаунт';

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
  String get noNotificationsYet => 'Пока нет уведомлений';

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
    return '$user переименовал(а) обсуждение в $title';
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
    return '$user перенес(ла) обсуждение $title в тег, на который вы подписаны';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user начал(а) с вами личное обсуждение: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user ответил(а) в личном обсуждении $title';
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
    return '$user выбрал(а) ваше сообщение лучшим ответом в обсуждении $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user выбрал(а) лучший ответ в обсуждении $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Выберите лучший ответ в обсуждении $title';
  }

  @override
  String notifMessage(String user) {
    return '$user отправил(а) вам сообщение';
  }

  @override
  String get notifSuspended => 'Ваш аккаунт заблокирован';

  @override
  String get notifUnsuspended => 'Блокировка вашего аккаунта снята';

  @override
  String get notifExport => 'Экспорт ваших данных готов';

  @override
  String get notifOther => 'Новое уведомление';

  @override
  String get aDiscussion => 'обсуждение';

  @override
  String get notificationsLoadFailed => 'Не удалось загрузить уведомления.';

  @override
  String get notificationsSignIn => 'Войдите, чтобы видеть уведомления.';

  @override
  String get markAllRead => 'Отметить все как прочитанные';

  @override
  String get posts => 'Сообщения';

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
  String get noPostsYet => 'Сообщений пока нет.';

  @override
  String searchFailedWithError(String error) {
    return 'Поиск не удался: $error';
  }

  @override
  String get searchHint => 'Поиск по обсуждениям и сообщениям';

  @override
  String noResultsFor(String query) {
    return 'По запросу «$query» ничего не найдено.';
  }

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get appearance => 'Оформление';

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
  String get repliesTitle => 'Ответы';

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
  String get goToBestAnswer => 'К лучшему ответу';

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
  String get mentionUser => 'Упомянуть пользователя';

  @override
  String get title => 'Заголовок';

  @override
  String get content => 'Содержание';

  @override
  String get send => 'Отправить';

  @override
  String get save => 'Сохранить';

  @override
  String get formatting => 'Форматирование';

  @override
  String get pleaseEnterTitle => 'Пожалуйста, введите заголовок';

  @override
  String get pleaseEnterContent => 'Пожалуйста, введите содержимое';

  @override
  String get composerTitleHint => 'Напишите заголовок...';

  @override
  String get composerContentHint => 'Напишите текст...';

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
      'Вы публикуете слишком часто. Подождите несколько секунд и попробуйте снова.';

  @override
  String get postAwaitingApproval =>
      'Отправлено. Сообщение появится после одобрения модератором.';

  @override
  String get chooseTags => 'Выбрать теги';

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
  String get done => 'Готово';

  @override
  String get noMembersFound => 'Участники не найдены.';

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
  String get react => 'Реакция';

  @override
  String get reactions => 'Реакции';

  @override
  String get bookmark => 'В закладки';

  @override
  String get removeBookmark => 'Убрать из закладок';

  @override
  String get bookmarks => 'Закладки';

  @override
  String get noBookmarks => 'Закладок пока нет.';

  @override
  String get chooseBestAnswer => 'Выбрать лучшим ответом';

  @override
  String get removeBestAnswer => 'Отменить лучший ответ';

  @override
  String get notificationSettings => 'Уведомления об этом обсуждении';

  @override
  String get notFollowing => 'Не отслеживается';

  @override
  String get notFollowingHint => 'Уведомлять, только когда вас @упомянут.';

  @override
  String get followingHint => 'Уведомлять обо всех ответах.';

  @override
  String get ignoring => 'Игнорируется';

  @override
  String get ignoringHint => 'Никогда не уведомлять и скрыть из списков.';

  @override
  String get tagFollowingHint => 'Уведомлять о новых обсуждениях.';

  @override
  String get lurking => 'Наблюдение';

  @override
  String get lurkingHint => 'Уведомлять о новых обсуждениях и каждом ответе.';

  @override
  String get tagIgnoringHint => 'Никогда не уведомлять об обсуждениях здесь.';

  @override
  String get hidden => 'Скрыт';

  @override
  String get hiddenHint => 'Скрыть обсуждения с этим тегом из списков.';

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
    return 'Размер $fileName: $fileBytes. Форум допускает до $maxBytes.';
  }

  @override
  String get flagAction => 'Пожаловаться';

  @override
  String get ignoredUsers => 'Игнорируемые пользователи';

  @override
  String get ignoredUsersEmpty => 'Вы никого не игнорируете.';

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
      'Это сообщение оскорбительное, грубое или нарушает правила сообщества.';

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
    return 'Игнорировать $name? Сообщения этого пользователя будут свёрнуты. Отменить можно в вашей учётной записи.';
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
      'Примите обновлённые условия форума, чтобы снова публиковать сообщения.';

  @override
  String get termsReview => 'Просмотреть';

  @override
  String get termsTitle => 'Обновлённые условия';

  @override
  String get termsIntro =>
      'Прежде чем снова публиковать, примите обновлённые правила форума.';

  @override
  String get readPolicy => 'Читать';

  @override
  String get acceptTerms => 'Принять';

  @override
  String get termsAccepted => 'Спасибо. Теперь вы снова можете публиковать.';

  @override
  String get privateDiscussions => 'Личные обсуждения';

  @override
  String get startPrivateDiscussion => 'Начать личное обсуждение';

  @override
  String privateWith(String names) {
    return 'С $names';
  }

  @override
  String get addPerson => 'Добавить участника';

  @override
  String get choosePerson => 'Выберите, кому написать.';

  @override
  String get noPrivateDiscussions => 'Личных обсуждений пока нет.';

  @override
  String get privateOnlyOne =>
      'На этом форуме можно писать лично только одному человеку за раз.';
}
