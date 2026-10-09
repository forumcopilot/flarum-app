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
