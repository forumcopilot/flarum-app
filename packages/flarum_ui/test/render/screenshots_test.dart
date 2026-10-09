// Renders every sample post to a PNG, with real fonts and the pictures the
// test forums serve, to set beside the web's rendering of the same posts
// (tool/render_compare). Skipped by default; it needs the forums running:
//
//   flutter test --run-skipped -t render test/render/screenshots_test.dart
//
// The PNGs go to build/render/app_<version>_<sample>.png at 2x, 412 logical
// pixels wide (a Pixel's width).
@Tags(['render'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/utils/embed_links.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

const _width = 412.0;
const _ratio = 2.0;
const _skip = 'writes screenshots; run with --run-skipped -t render';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    if (File(file).existsSync()) loader.addFont(Future.value(ByteData.sublistView(File(file).readAsBytesSync())));
  }
  await loader.load();
}

SiteContext _site(String baseUrl) => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: Site(
        id: null,
        name: 'Test forum',
        url: baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: baseUrl,
        siteType: FlarumProxyFactory.siteType,
        language: null,
      ),
    );

void main() {
  final samples = jsonDecode(File('test/fixtures/render_samples.json').readAsStringSync()) as Map<String, dynamic>;
  final out = Directory('build/render');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    out.createSync(recursive: true);
    final fonts =
        '${Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/flutter'}/bin/cache/artifacts/material_fonts';
    await _loadFont('Roboto', [
      for (final style in ['Regular', 'Italic', 'Medium', 'MediumItalic', 'Bold', 'BoldItalic'])
        '$fonts/Roboto-$style.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
    await _loadFont('monospace', ['/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf']);
    // Real requests, so pictures from the test forums load.
    HttpOverrides.global = null;
    // The image cache keeps files; widget tests have no path_provider plugin.
    final cache = Directory.systemTemp.createTempSync('flarum_render_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => cache.path,
    );
  });

  group('screenshots', () {
    for (final MapEntry(key: version, value: forum as Map<String, dynamic>) in samples.entries) {
      final baseUrl = forum['baseUrl'] as String;
      for (final MapEntry(key: name, value: html as String) in (forum['samples'] as Map<String, dynamic>).entries) {
        testWidgets('$version $name', (tester) async {
          tester.view.physicalSize = const Size(_width * _ratio, 3000 * _ratio);
          tester.view.devicePixelRatio = _ratio;
          addTearDown(tester.view.reset);
          final prepared = FlarumHtml.parse(html, forumBaseUrl: baseUrl);
          // Fetch the pictures in a real zone first: in the test's fake one an
          // HTTPS picture never arrives (its handshake waits on fake timers).
          await tester.pumpWidget(const SizedBox());
          final context = tester.element(find.byType(SizedBox));
          final pictures = [
            ...prepared.imageUrls,
            for (final m in RegExp(r'<iframe[^>]*src="([^"]+)"').allMatches(prepared.html))
              EmbedLink.fromIframe(m.group(1)!)?.thumbnailUrl,
          ].nonNulls;
          await tester.runAsync(() => Future.wait([
                for (final url in pictures) precacheImage(NetworkImage(url), context, onError: (_, __) {}),
              ]));
          final boundary = GlobalKey();
          await tester.pumpWidget(MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: RepaintBoundary(
                  key: boundary,
                  child: ColoredBox(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FlarumContent(
                        siteContext: _site(baseUrl),
                        content: prepared.html,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
          // Let pictures arrive, then lay out again.
          for (var i = 0; i < 6; i++) {
            await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 800)));
            await tester.pump();
          }
          tester.takeException();
          final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final png = await tester.runAsync(() async {
            final image = await render.toImage(pixelRatio: _ratio);
            return (await image.toByteData(format: ui.ImageByteFormat.png))!;
          });
          File('${out.path}/app_${version}_$name.png').writeAsBytesSync(png!.buffer.asUint8List());
          // Let retries and animations time out before the test ends.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(minutes: 1));
        });
      }
    }
  }, skip: _skip);

  // The thread page over the recorded fixtures: app_thread_<version>_<name>.png,
  // a phone screen's worth (412 × 915).
  group('thread screenshots', () {
    for (final version in FlarumVersion.values) {
      for (final (name, discussion, near) in [('welcome', 'welcome', null), ('long_near_21', 'long', 21)]) {
        testWidgets('${version.name} $name', (tester) async {
          tester.view.physicalSize = const Size(_width * _ratio, 915 * _ratio);
          tester.view.devicePixelRatio = _ratio;
          addTearDown(tester.view.reset);
          final fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures');
          FlarumForum.resetForTesting();
          fixtures.forum();
          final boundary = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: ThreadPage(site: _site(FixtureForum.baseUrl), discussionId: fixtures.discussionId(discussion), near: near),
            ),
          ));
          for (var i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          tester.takeException();
          final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final png = await tester.runAsync(() async {
            final image = await render.toImage(pixelRatio: _ratio);
            return (await image.toByteData(format: ui.ImageByteFormat.png))!;
          });
          File('${out.path}/app_thread_${version.name}_$name.png').writeAsBytesSync(png!.buffer.asUint8List());
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(minutes: 1));
        });
      }
    }
  }, skip: _skip);
}
