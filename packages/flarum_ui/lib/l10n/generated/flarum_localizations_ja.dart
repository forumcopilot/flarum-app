// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class FlarumLocalizationsJa extends FlarumLocalizations {
  FlarumLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get attachmentDefaultName => '添付ファイル';

  @override
  String get share => '共有';

  @override
  String get cancel => 'キャンセル';

  @override
  String downloading(String filename) {
    return '$filenameをダウンロード中...';
  }

  @override
  String get download => 'ダウンロード';

  @override
  String errorDownloading(String filename, String error) {
    return '$filenameのダウンロードエラー: $error';
  }

  @override
  String get video => '動画';

  @override
  String get viewOnWeb => 'Webで表示';

  @override
  String get mediaPause => '一時停止';

  @override
  String get mediaPlay => '再生';

  @override
  String get failedToLoadVideo => '動画を読み込めませんでした';

  @override
  String get close => '閉じる';

  @override
  String get spoiler => 'ネタバレ';

  @override
  String get image => '画像';

  @override
  String get fileTypeArchive => '圧縮ファイル';

  @override
  String get fileTypeAudio => '音声';

  @override
  String get fileTypeFile => 'ファイル';

  @override
  String get fileTypeText => 'テキスト';
}
