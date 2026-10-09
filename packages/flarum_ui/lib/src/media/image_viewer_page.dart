import 'package:flutter/material.dart';

import '../render/links.dart';

/// A post's pictures, full screen: swipe between them, pinch to zoom.
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({super.key, required this.urls, this.initial = 0});

  final List<String> urls;
  final int initial;

  /// Opens the viewer on [url] among [urls] (just [url] if it isn't one of them).
  static Future<void> open(BuildContext context, String url, List<String> urls) {
    final gallery = urls.contains(url) ? urls : [url];
    return Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ImageViewerPage(urls: gallery, initial: gallery.indexOf(url)),
    ));
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.urls.length > 1 ? Text('${_index + 1} / ${widget.urls.length}') : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: () => openExternally(widget.urls[_index]),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
