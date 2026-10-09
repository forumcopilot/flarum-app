// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class FlarumLocalizationsZh extends FlarumLocalizations {
  FlarumLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get attachmentDefaultName => '附件';

  @override
  String get share => '分享';

  @override
  String get cancel => '取消';

  @override
  String downloading(String filename) {
    return '正在下载$filename...';
  }

  @override
  String get download => '下载';

  @override
  String errorDownloading(String filename, String error) {
    return '下载$filename时出错: $error';
  }

  @override
  String get video => '视频';

  @override
  String get viewOnWeb => '在网页中查看';

  @override
  String get mediaPause => '暂停';

  @override
  String get mediaPlay => '播放';

  @override
  String get failedToLoadVideo => '无法加载视频';

  @override
  String get close => '关闭';

  @override
  String get spoiler => '剧透';

  @override
  String get image => '图片';

  @override
  String get fileTypeArchive => '压缩包';

  @override
  String get fileTypeAudio => '音频';

  @override
  String get fileTypeFile => '文件';

  @override
  String get fileTypeText => '文本';
}
