import 'dart:io';

import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';

const _pictures = ['https://forum.test/assets/files/a.png', 'https://forum.test/assets/files/b.png'];

Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: FlarumLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(onPressed: () => ImageViewerPage.open(context, _pictures[0], _pictures), child: const Text('open')),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.byType(ImageViewerPage), findsOneWidget);
}

double _scale(WidgetTester tester) =>
    tester.widget<InteractiveViewer>(find.byType(InteractiveViewer).first).transformationController!.value.getMaxScaleOnAxis();

void main() {
  setUpAll(() {
    // The picture cache's folder; the pictures themselves fail to load here, which is fine.
    final cache = Directory.systemTemp.createTempSync('flarum_viewer_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => cache.path,
    );
  });

  testWidgets('Save Image, Share and View on Web, and where it is among the post\'s pictures', (tester) async {
    await _open(tester);
    expect(find.byTooltip('Save Image'), findsOneWidget);
    expect(find.byTooltip('Share'), findsOneWidget);
    expect(find.byTooltip('View on Web'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('dragged down far, the viewer closes; a little, the picture springs back', (tester) async {
    await _open(tester);
    await tester.drag(find.byType(PageView), const Offset(0, 60));
    await tester.pumpAndSettle();
    expect(find.byType(ImageViewerPage), findsOneWidget);
    expect(tester.widget<Transform>(find.ancestor(of: find.byType(PageView), matching: find.byType(Transform)).first).transform.getTranslation().y,
        0, reason: 'back in place');

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byType(ImageViewerPage), findsNothing);
    expect(find.text('open'), findsOneWidget, reason: 'the page it was opened from');
  });

  testWidgets('a double-tap zooms in, another back out; zoomed in, a drag moves the picture', (tester) async {
    await _open(tester);
    final centre = tester.getCenter(find.byType(PageView));
    Future<void> doubleTap() async {
      await tester.tapAt(centre);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(centre);
      await tester.pumpAndSettle();
    }

    await doubleTap();
    expect(_scale(tester), closeTo(2.5, 0.01));
    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byType(ImageViewerPage), findsOneWidget, reason: 'a drag pans the zoomed picture');
    expect(find.text('1 / 2'), findsOneWidget);

    await doubleTap();
    expect(_scale(tester), closeTo(1, 0.01));
  });
}
