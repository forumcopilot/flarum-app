// Phase 0 spike: renders Flarum contentHtml with discourse-app's renderer
// (CookedContent + RichTextContent) and reports what comes out, per sample and
// version: Flutter errors, extracted images and links, the visible text, and
// the notable widgets built. It reports; it does not assert.
//
// It needs discourse_ui, so it runs inside a discourse-app checkout:
//
//   cp tool/spikes/render_flarum_html_test.dart tool/spikes/flarum_render_samples.json \
//      <discourse-app>/packages/discourse_ui/test/
//   cd <discourse-app>/packages/discourse_ui && flutter test test/render_flarum_html_test.dart
//
// The report is written to test/flarum_render_report.txt. The samples come from
// tool/test_forums/formatting_samples.php on the 1.8 and 2.0 test forums.

import 'dart:convert';
import 'dart:io';

import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  final samples = jsonDecode(File('test/flarum_render_samples.json').readAsStringSync()) as Map<String, dynamic>;
  final report = StringBuffer();

  tearDownAll(() => File('test/flarum_render_report.txt').writeAsStringSync(report.toString()));

  for (final MapEntry(key: version, value: forum as Map<String, dynamic>) in samples.entries) {
    final baseUrl = forum['baseUrl'] as String;
    for (final MapEntry(key: name, value: html as String) in (forum['samples'] as Map<String, dynamic>).entries) {
      testWidgets('$version $name', (tester) async {
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) {
          final message = d.exceptionAsString().split('\n').first;
          // Widget tests can't load network images; that isn't a rendering fault.
          if (!message.contains('HTTP request failed') && !message.contains('NetworkImageLoadException')) errors.add(message);
        };
        final cooked = CookedContent.parse(html, forumBaseUrl: baseUrl);
        try {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 361,
                  child: RichTextContent(siteContext: _siteContext(baseUrl), content: cooked.html),
                ),
              ),
            ),
          ));
          await tester.pump();
        } finally {
          FlutterError.onError = previous;
        }
        final exception = tester.takeException();

        final texts = [
          for (final widget in tester.allWidgets)
            if (widget is RichText) widget.text.toPlainText().trim(),
        ].where((t) => t.isNotEmpty).toList();
        final notable = <String, int>{};
        for (final widget in tester.allWidgets) {
          final type = widget.runtimeType.toString();
          if (RegExp(r'Embed|Video|Youtube|YouTube|Attachment|Spoiler|Quote|Image|Checkbox|Table|Iframe|Card|Details|Code', caseSensitive: false)
                  .hasMatch(type) &&
              !type.startsWith('_')) {
            notable[type] = (notable[type] ?? 0) + 1;
          }
        }

        report
          ..writeln('#### $version $name')
          ..writeln('errors: ${[...errors, if (exception != null) 'exception: $exception'].join(' | ')}')
          ..writeln('images: ${cooked.imageUrls}')
          ..writeln('links: ${cooked.linkUrls}')
          ..writeln('widgets: $notable')
          ..writeln('text:')
          ..writeln(texts.map((t) => '  | ${t.replaceAll('\n', '\n  | ')}').join('\n'))
          ..writeln();
      });
    }
  }
}

SiteContext _siteContext(String baseUrl) => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Flarum',
        url: baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: baseUrl,
        siteType: 'discourse',
        language: null,
      ),
    );
