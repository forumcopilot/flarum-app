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
}
