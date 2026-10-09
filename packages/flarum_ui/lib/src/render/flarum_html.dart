import 'package:flutter/foundation.dart' show compute;
import 'package:forum_kit/core/cache/lru_cache.dart';
import 'package:forum_kit/utils/html_colors.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// A post's `contentHtml` prepared for [FlarumContent], and the images and
/// links in it.
///
/// Flarum renders posts on the server with s9e/TextFormatter and its
/// extensions. Most of it is plain HTML the renderer draws as it is; the
/// rest is rewritten here into markup it already knows (adapted from
/// discourse_ui's CookedContent, which does the same for Discourse):
///
///  * `script` elements go: every code block carries the highlighter's
///    loader, whose source would print inside the block;
///  * a task list's `input[type=checkbox]` becomes a `span.chcklst-box`,
///    checked or not; a list of nothing but tasks becomes `div.task-list` of
///    `div.task-item`s, so no bullet or number is drawn (flutter_html
///    ignores `list-style-type: none`);
///  * an s9e media embed (`[data-s9e-mediaembed]`: YouTube and the rest)
///    becomes its bare `iframe`: the wrappers size it with a percentage
///    padding flutter_html can't do, and it collapsed to nothing;
///  * fof/upload's file buttons (`div.ButtonGroup[data-fof-upload-download-uuid]`)
///    become an `a.attachment` on `/api/fof/download/{uuid}`, with the
///    name, and the size in `data-size`;
///  * fof/upload's 2.0 image preview (`a.FoFUpload--Upl-Image-Preview-Link`,
///    the full size, around the thumbnail) becomes an `a.lightbox`, so the
///    viewer opens the full size;
///  * a post mention's Font Awesome icon (2.0: `i.fa-reply`) goes; the
///    renderer draws its own reply glyph on both versions;
///  * author colours are normalised to `#rrggbb`, and inline `display: none`
///    removed, as for Discourse.
class FlarumHtml {
  /// The prepared HTML.
  final String html;

  /// External links worth a preview: not mentions, attachments, pictures or
  /// links inside quotes, and not the forum's own.
  final List<String> linkUrls;

  /// Content images in document order, absolute, full size where a preview
  /// links to it. Feeds the full-screen image viewer.
  final List<String> imageUrls;

  const FlarumHtml({required this.html, required this.linkUrls, required this.imageUrls});

  static const FlarumHtml empty = FlarumHtml(html: '', linkUrls: <String>[], imageUrls: <String>[]);

  /// Parsed results by post HTML, bounded: a post's row is rebuilt each time
  /// it scrolls back into view, and an edited post simply misses.
  static final LRUCache<String, FlarumHtml> _cache = LRUCache(maxSize: 400);

  /// Parses a page of posts on a worker isolate and files the results, so the
  /// frame that first shows each post finds its parse ready.
  static Future<void> warm(List<String> contentHtml, {required String forumBaseUrl}) async {
    final pending = contentHtml.where((c) => !_cache.containsKey('$forumBaseUrl\u0000$c')).toList();
    if (pending.isEmpty) return;
    try {
      final parsed = await compute(_parseBatch, (pending, forumBaseUrl));
      for (var i = 0; i < pending.length; i++) {
        _cache.put('$forumBaseUrl\u0000${pending[i]}', parsed[i]);
      }
    } catch (_) {
      // Best effort: the on-demand path still works.
    }
  }

  static List<FlarumHtml> _parseBatch((List<String>, String) args) {
    final (html, base) = args;
    return [for (final h in html) _parse(h, forumBaseUrl: base)];
  }

  /// [contentHtml] prepared, from the cache when it has been seen.
  /// [forumBaseUrl] is the forum's address, which relative URLs and the
  /// download endpoint are taken against.
  static FlarumHtml parse(String contentHtml, {required String forumBaseUrl}) {
    final key = '$forumBaseUrl\u0000$contentHtml';
    final hit = _cache.get(key);
    if (hit != null) return hit;
    final parsed = _parse(contentHtml, forumBaseUrl: forumBaseUrl);
    _cache.put(key, parsed);
    return parsed;
  }

  static FlarumHtml _parse(String contentHtml, {required String forumBaseUrl}) {
    if (contentHtml.trim().isEmpty) return empty;
    final body = html_parser.parse(contentHtml).body;
    if (body == null) return FlarumHtml(html: contentHtml, linkUrls: const [], imageUrls: const []);

    final origin = _origin(forumBaseUrl);
    var base = forumBaseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    // ---- 1. What the web never shows ----------------------------------
    for (final node in body.querySelectorAll('script, style').toList()) {
      node.remove();
    }
    for (final node in body.querySelectorAll('[style]').toList()) {
      if (_hiddenInline.hasMatch(node.attributes['style'] ?? '')) node.remove();
    }

    // ---- 2. Author colours --------------------------------------------
    for (final el in body.querySelectorAll('[color]')) {
      final normalized = normalizeHtmlColor(el.attributes['color']);
      if (normalized == null) {
        el.attributes.remove('color');
      } else {
        el.attributes['color'] = normalized;
      }
    }

    // ---- 3. Task lists ------------------------------------------------
    for (final item in body.querySelectorAll('li[data-task-state]')) {
      final box = item.querySelector('input[type=checkbox]');
      if (box == null) continue;
      final checked = item.attributes['data-task-state'] == 'checked' || box.attributes.containsKey('checked');
      final mark = dom.Element.tag('span')..className = checked ? 'chcklst-box checked' : 'chcklst-box';
      box.replaceWith(mark);
      // The box draws its own gap; the space after the checkbox would double it.
      final siblings = mark.parentNode!.nodes;
      final next = siblings.indexOf(mark) + 1;
      if (next < siblings.length && siblings[next] is dom.Text) {
        final text = siblings[next] as dom.Text;
        text.text = text.text.trimLeft();
      }
    }
    for (final list in body.querySelectorAll('ul, ol').toList()) {
      final items = list.children;
      if (items.isEmpty || !items.every((i) => i.localName == 'li' && i.attributes.containsKey('data-task-state'))) {
        continue;
      }
      final replacement = dom.Element.tag('div')..className = 'task-list';
      for (final item in items.toList()) {
        replacement.append(_retag(item, 'div')..className = 'task-item');
      }
      list.replaceWith(replacement);
    }

    // ---- 3b. Media embeds ---------------------------------------------
    for (final embed in body.querySelectorAll('[data-s9e-mediaembed]').toList()) {
      final frame = embed.querySelector('iframe');
      if (frame == null) continue;
      frame.attributes.remove('style');
      embed.replaceWith(frame..remove());
    }

    // ---- 4. fof/upload ------------------------------------------------
    for (final group in body.querySelectorAll('div.ButtonGroup[data-fof-upload-download-uuid]').toList()) {
      final uuid = group.attributes['data-fof-upload-download-uuid']!.trim();
      final buttons = group.querySelectorAll('.Button').where((b) => !b.classes.contains('hasIcon')).toList();
      final name = group.querySelector('.fof-upload-download-label')?.text.trim() ??
          (buttons.isNotEmpty ? buttons.first.text.trim() : '');
      final size = buttons.length > 1 ? buttons.last.text.trim() : '';
      final link = dom.Element.tag('a')
        ..className = 'attachment'
        ..attributes['href'] = '$base/api/fof/download/${Uri.encodeComponent(uuid)}'
        ..text = name;
      if (size.isNotEmpty) link.attributes['data-size'] = size;
      group.replaceWith(link);
    }
    for (final preview in body.querySelectorAll('a.FoFUpload--Upl-Image-Preview-Link')) {
      preview.classes.add('lightbox');
    }

    // ---- 5. Mentions --------------------------------------------------
    for (final icon in body.querySelectorAll('a.PostMention i').toList()) {
      icon.remove();
    }

    // ---- 6. Images ----------------------------------------------------
    // A preview's link is the original; prefer it over the <img src>.
    final images = <String>{};
    for (final el in body.querySelectorAll('a.lightbox[href], img[src]')) {
      if (el.localName == 'a') {
        final href = el.attributes['href'] ?? '';
        if (href.isNotEmpty) images.add(_absolute(href, origin));
        continue;
      }
      if (_classes(el).contains('emoji')) continue;
      if (_hasAncestorMatching(el, (e) => _classes(e).contains('lightbox'))) continue;
      final src = el.attributes['src'] ?? '';
      if (src.isNotEmpty) images.add(_absolute(src, origin));
    }

    // ---- 7. Links -----------------------------------------------------
    final links = <String>{};
    for (final anchor in body.querySelectorAll('a[href]')) {
      final href = (anchor.attributes['href'] ?? '').trim();
      if (href.isEmpty || href.startsWith('#')) continue;
      final classes = _classes(anchor);
      if (classes.contains('UserMention') ||
          classes.contains('PostMention') ||
          classes.contains('attachment') ||
          classes.contains('lightbox')) {
        continue;
      }
      if (anchor.querySelector('img') != null) continue;
      if (_hasAncestorMatching(anchor, (e) => e.localName == 'blockquote')) continue;
      if (!_isExternalHttpUrl(href, origin)) continue;
      links.add(href);
    }

    return FlarumHtml(html: body.innerHtml, linkUrls: links.toList(), imageUrls: images.toList());
  }

  /// [element]'s children and attributes under another tag.
  static dom.Element _retag(dom.Element element, String tag) {
    final copy = dom.Element.tag(tag)..attributes.addAll(element.attributes);
    for (final child in element.nodes.toList()) {
      copy.append(child);
    }
    return copy;
  }

  static final RegExp _hiddenInline = RegExp(r'(^|;)\s*display\s*:\s*none\b', caseSensitive: false);

  static Set<String> _classes(dom.Element element) =>
      (element.attributes['class'] ?? '').split(RegExp(r'\s+')).where((c) => c.isNotEmpty).toSet();

  static bool _hasAncestorMatching(dom.Element element, bool Function(dom.Element) test) {
    for (var parent = element.parent; parent != null; parent = parent.parent) {
      if (test(parent)) return true;
    }
    return false;
  }

  /// Scheme, host and port of [baseUrl], or empty when it can't be parsed.
  static String _origin(String baseUrl) {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return '';
    return uri.hasPort ? '${uri.scheme}://${uri.host}:${uri.port}' : '${uri.scheme}://${uri.host}';
  }

  static String _absolute(String url, String origin) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return '${origin.startsWith('http://') ? 'http' : 'https'}:$url';
    if (origin.isEmpty) return url;
    return url.startsWith('/') ? '$origin$url' : '$origin/$url';
  }

  /// An absolute http(s) link to somewhere other than this forum.
  static bool _isExternalHttpUrl(String url, String origin) {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) return false;
    if (origin.isEmpty) return true;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return false;
    return uri.host.toLowerCase() != Uri.parse(origin).host.toLowerCase();
  }
}
