import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';

/// The app for the forum in flarum_ui's AppForumConfig (or the one passed
/// with `--dart-define=FLARUM_URL=…`). Everything else is in flarum_ui.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final site = await FlarumApp.initialize(AppForumConfig.current);
  final appearance = await Appearance.load();
  runApp(FlarumApp(site: site, appearance: appearance));
}
