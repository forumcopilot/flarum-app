// Scroll benchmark: the home list and a thread, on a phone in profile mode. Ported from
// discourse-app's (docs/perf-benchmarking.md there), with the same gestures and labels, so the
// numbers line up with its audit. How to run it: docs/device-testing.md.
import 'dart:async';

import 'package:flarum_app/main.dart' as app;
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('home list and thread scrolling', (tester) async {
    // The build's forum (AppForumConfig.current): discuss.flarum.org unless --dart-define says
    // otherwise. main() can't be awaited past runApp, so pump until the list shows.
    unawaited(app.main());
    await _pumpUntil(tester, find.byType(DiscussionTile), timeout: const Duration(seconds: 90));
    await tester.pump(const Duration(seconds: 2));

    await _measure('topic_list', () => _flings(tester, 8));

    // Back to the top, then open the second discussion.
    for (var i = 0; i < 2; i++) {
      await tester.fling(find.byType(DiscussionTile).first, const Offset(0, 4000), 8000);
      await _settle(tester, frames: 60);
    }
    await tester.tap(find.byType(DiscussionTile).at(1));
    await _pumpUntil(tester, find.byType(PostTile), timeout: const Duration(seconds: 60));
    await tester.pump(const Duration(seconds: 4));
    await _settle(tester, frames: 30);

    // Prove the tap opened a thread, and which.
    final onScreen = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .take(12)
        .toList();
    // ignore: avoid_print
    print('PERF thread-screen posts=${find.byType(PostTile).evaluate().length} texts=$onScreen');
    await _measure('thread', () => _flings(tester, 8));
  });
}

/// Collects [FrameTiming] for every frame produced while [action] runs and prints one summary
/// line, which `flutter drive` echoes to the console.
Future<void> _measure(String label, Future<void> Function() action) async {
  final frames = <FrameTiming>[];
  void collect(List<FrameTiming> timings) => frames.addAll(timings);
  SchedulerBinding.instance.addTimingsCallback(collect);
  await action();
  await Future<void>.delayed(const Duration(milliseconds: 500));
  SchedulerBinding.instance.removeTimingsCallback(collect);

  List<double> ms(Duration Function(FrameTiming) of) =>
      frames.map((t) => of(t).inMicroseconds / 1000).toList()..sort();
  double pct(List<double> v, double q) => v.isEmpty ? 0 : v[((v.length - 1) * q).round()];
  String max(List<double> v) => v.isEmpty ? '0' : v.last.toStringAsFixed(0);
  int over(List<double> v, double budget) => v.where((x) => x > budget).length;
  final build = ms((t) => t.buildDuration);
  final raster = ms((t) => t.rasterDuration);
  final total = ms((t) => t.totalSpan);
  // ignore: avoid_print
  print('PERF $label frames=${frames.length} '
      'build p50=${pct(build, .5).toStringAsFixed(1)} p90=${pct(build, .9).toStringAsFixed(1)} '
      'p99=${pct(build, .99).toStringAsFixed(1)} max=${max(build)} '
      '| raster p50=${pct(raster, .5).toStringAsFixed(1)} p90=${pct(raster, .9).toStringAsFixed(1)} '
      'p99=${pct(raster, .99).toStringAsFixed(1)} max=${max(raster)} '
      '| total>16.7ms=${over(total, 16.7)} total>33ms=${over(total, 33)} '
      'build>16.7ms=${over(build, 16.7)} raster>16.7ms=${over(raster, 16.7)}');
}

/// Eight flings up, as discourse-app's benchmark does: logical pixels, so any phone-sized screen.
Future<void> _flings(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.flingFrom(const Offset(200, 760), const Offset(0, -520), 3000);
    await _settle(tester, frames: 75);
  }
}

/// pumpAndSettle never settles while a spinner animates; pump a fixed number of frames.
Future<void> _settle(WidgetTester tester, {required int frames}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .take(30)
      .toList();
  throw TestFailure('Timed out waiting for $finder; on screen: $texts');
}
