import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/cached_redirect_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../render/links.dart';
import '../../l10n/flarum_l10n.dart';

/// A post's pictures, full screen, as a phone's photo viewer has them: swipe between them, pinch
/// or double-tap to zoom, drag down to close; Save Image, Share and View on Web.
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({super.key, required this.urls, this.initial = 0});

  final List<String> urls;
  final int initial;

  /// Opens the viewer on [url] among [urls] (just [url] if it isn't one of them), over the page:
  /// dragged down, the page shows through as the picture goes.
  static Future<void> open(BuildContext context, String url, List<String> urls) {
    final gallery = urls.contains(url) ? urls : [url];
    return Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => ImageViewerPage(urls: gallery, initial: gallery.indexOf(url)),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> with SingleTickerProviderStateMixin {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  final _zooms = <int, TransformationController>{};
  bool _zoomed = false;

  /// How far the picture has been dragged towards closing.
  double _drag = 0;
  late final AnimationController _animation;
  VoidCallback? _animating;
  Offset _doubleTapAt = Offset.zero;
  bool _saving = false;

  static const _zoomOnDoubleTap = 2.5;

  /// A drag this far, or this fast, closes the viewer; less springs back.
  static const _closeDistance = 120.0;
  static const _closeVelocity = 800.0;

  TransformationController _zoom(int i) => _zooms.putIfAbsent(i, TransformationController.new);

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _pages.dispose();
    _animation.dispose();
    for (final zoom in _zooms.values) {
      zoom.dispose();
    }
    super.dispose();
  }

  void _zoomChanged() {
    final zoomed = _zoom(_index).value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  /// Runs [frame] (0 to 1) over the animation, replacing whatever it was running.
  void _animate(void Function(double t) frame) {
    if (_animating case final previous?) _animation.removeListener(previous);
    void listener() => frame(Curves.easeOut.transform(_animation.value));
    _animating = listener;
    _animation
      ..addListener(listener)
      ..forward(from: 0);
  }

  /// Double-tap: in at the tapped point, or back out.
  void _toggleZoom() {
    final zoom = _zoom(_index);
    final from = zoom.value.clone();
    final Matrix4 to;
    if (_zoomed) {
      to = Matrix4.identity();
    } else {
      final point = _doubleTapAt;
      to = Matrix4.identity()
        ..translateByDouble(-point.dx * (_zoomOnDoubleTap - 1), -point.dy * (_zoomOnDoubleTap - 1), 0, 1)
        ..scaleByDouble(_zoomOnDoubleTap, _zoomOnDoubleTap, 1, 1);
    }
    final tween = Matrix4Tween(begin: from, end: to);
    _animate((t) {
      zoom.value = tween.transform(t);
      _zoomChanged();
    });
  }

  void _dragEnd(DragEndDetails details) {
    if (_drag.abs() > _closeDistance || (details.primaryVelocity ?? 0).abs() > _closeVelocity) {
      Navigator.of(context).maybePop();
      return;
    }
    final from = _drag;
    _animate((t) => setState(() => _drag = from * (1 - t)));
  }

  Future<void> _save() async {
    final l10n = flarumL10n(context);
    setState(() => _saving = true);
    try {
      // Android before 10 saves into shared storage, which needs the permission; later Androids
      // and iOS need none asked here (iOS asks to add to Photos itself, the first time).
      if (Platform.isAndroid && (await DeviceInfoPlugin().androidInfo).version.sdkInt < 29) {
        if (!await Permission.storage.request().isGranted) {
          if (mounted) SnackbarHelper.showError(context, l10n.imageSaveNotAllowed);
          return;
        }
      }
      final image = await ImageLoader.fetchImageFile(widget.urls[_index]);
      final result = await SaverGallery.saveImage(
        await image.file.readAsBytes(),
        fileName: _fileName(widget.urls[_index]),
        androidRelativePath: 'Pictures',
        skipIfExists: false,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        SnackbarHelper.showSuccess(context, l10n.imageSaved);
      } else {
        SnackbarHelper.showError(context, l10n.imageSaveFailed);
      }
    } catch (e) {
      debugPrint('ImageViewerPage: save failed: $e');
      if (mounted) SnackbarHelper.showError(context, l10n.imageSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share(BuildContext button) async {
    final box = button.findRenderObject();
    final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
    final url = widget.urls[_index];
    try {
      final image = await ImageLoader.fetchImageFile(url);
      await SharePlus.instance.share(ShareParams(files: [XFile(image.file.path)], sharePositionOrigin: origin));
    } catch (e) {
      // Not downloaded: the link instead.
      debugPrint('ImageViewerPage: sharing the picture failed: $e');
      await shareLink(url, origin: origin);
    }
  }

  /// The picture's own name, for the saved copy (the forum's names are random, but its own).
  static String _fileName(String url) {
    final name = Uri.tryParse(url)?.pathSegments.lastOrNull ?? '';
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    return base.isEmpty ? 'image_${DateTime.now().millisecondsSinceEpoch}' : base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    // The page behind shows through as the picture is dragged away.
    final fade = (1 - _drag.abs() / 400).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: fade),
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: fade),
        foregroundColor: Colors.white.withValues(alpha: fade),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: widget.urls.length > 1 ? Text('${_index + 1} / ${widget.urls.length}') : null,
        actions: [
          IconButton(
            icon: Icon(_saving ? Icons.downloading : Icons.download),
            tooltip: l10n.saveImage,
            onPressed: _saving ? null : _save,
          ),
          Builder(
            builder: (button) => IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.share,
              onPressed: () => _share(button),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.viewOnWeb,
            onPressed: () => openExternally(widget.urls[_index]),
          ),
        ],
      ),
      body: GestureDetector(
        // Zoomed in, a drag moves around the picture instead.
        onVerticalDragUpdate: _zoomed ? null : (d) => setState(() => _drag += d.delta.dy),
        onVerticalDragEnd: _zoomed ? null : _dragEnd,
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: PageView.builder(
            controller: _pages,
            physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: widget.urls.length,
            onPageChanged: (i) {
              // The picture left behind goes back to its whole size.
              _zooms[_index]?.value = Matrix4.identity();
              setState(() {
                _index = i;
                _zoomed = false;
              });
            },
            itemBuilder: (context, i) => GestureDetector(
              onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
              onDoubleTap: _toggleZoom,
              child: InteractiveViewer(
                transformationController: _zoom(i),
                maxScale: 5,
                panEnabled: _zoomed,
                onInteractionEnd: (_) => _zoomChanged(),
                child: SizedBox.expand(
                  child: Image(
                    image: CachedRedirectNetworkImageProvider(widget.urls[i]),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Colors.white54)),
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
