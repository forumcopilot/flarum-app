import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'attachment_file_card.dart';
import 'package:forum_kit/views/widgets/brand_image.dart';
import 'package:forum_kit/views/widgets/broken_image_widget.dart';
import 'package:forum_kit/views/widgets/code_block.dart';
import 'embed_cards.dart';
import 'forum_image.dart';
import 'link_pills.dart';
import 'post_body_extensions.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart' show PostContentCallbacks;
import 'post_table.dart';
import 'package:forum_kit/core/cache/lru_cache.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/embed_links.dart';
import 'package:forum_kit/utils/emoji_shortcodes.dart';
import 'package:forum_kit/utils/html_colors.dart';
import 'forum_media.dart';
import 'links.dart';

/// Renders a Flarum post: its `contentHtml`, prepared by [FlarumHtml].
///
/// Adapted from discourse_ui's RichTextContent (the same flutter_html setup,
/// block rhythm, quotes, tables, code, pictures and embeds), with Flarum's
/// own markup: user and post mentions as pills (a post mention with a reply
/// glyph), task-list boxes, fof/upload previews and file downloads, inline
/// spoilers blurred until tapped, and a "Spoiler" label on block spoilers.
///
/// Taps go to [callbacks]: a user mention to `onMentionTap` with the
/// user's slug from its link (`/u/{slug}`), a picture to `onImageTap`, and any other link (a post mention,
/// a link to a discussion on this forum) to `onUrlTap`, so the host can open
/// the forum's own pages in the app. Without a callback a link opens outside
/// the app.
class FlarumContent extends StatelessWidget {
  final SiteContext siteContext;
  final String content;
  final PostContentCallbacks? callbacks;

  /// Body text size: 16 for posts. A preview's excerpt passes its smaller
  /// card size.
  final double? baseFontSize;

  /// Body text colour, for text on a coloured surface; the theme's
  /// onSurface otherwise.
  final Color? textColor;

  const FlarumContent({
    super.key,
    required this.siteContext,
    required this.content,
    this.callbacks,
    this.baseFontSize,
    this.textColor,
  });

  /// The username in a profile link (`/u/{username}`), otherwise null.
  static String? _usernameFromHref(String url) {
    try {
      final path = Uri.parse(url.trim()).path;
      return RegExp(r'^/u(?:sers)?/([^/?#]+)/?$').firstMatch(path)?.group(1);
    } catch (_) {
      return null;
    }
  }

  /// The direction a post reads in, from its letters (markup and entities
  /// aside): right-to-left when most are in a right-to-left script (Arabic,
  /// Hebrew…), as the web lays such posts out. Null when it has no letters.
  ///
  /// It runs on every post's first build, so it scans the text once by hand:
  /// a regex over each letter cost as much as all of flutter_html's styling.
  static TextDirection? directionOf(String html) {
    var rtl = 0;
    var letters = 0;
    var i = 0;
    while (i < html.length && letters < 2000) {
      final unit = html.codeUnitAt(i);
      if (unit == 0x3C) {
        // <…>: markup.
        final close = html.indexOf('>', i + 1);
        i = close < 0 ? i + 1 : close + 1;
        continue;
      }
      if (unit == 0x26) {
        // &name; or &#123;: an entity.
        var j = i + 1;
        if (j < html.length && html.codeUnitAt(j) == 0x23) j++;
        final word = j;
        while (j < html.length && _isWordUnit(html.codeUnitAt(j))) {
          j++;
        }
        if (j > word && j < html.length && html.codeUnitAt(j) == 0x3B) {
          i = j + 1;
          continue;
        }
        i++;
        continue;
      }
      var rune = unit;
      var width = 1;
      if (unit >= 0xD800 && unit <= 0xDBFF && i + 1 < html.length) {
        final low = html.codeUnitAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) {
          rune = 0x10000 + ((unit - 0xD800) << 10) + (low - 0xDC00);
          width = 2;
        }
      }
      i += width;
      if (!_isLetter(rune)) continue;
      letters++;
      if ((rune >= 0x0590 && rune <= 0x08FF) || (rune >= 0xFB1D && rune <= 0xFDFF) || (rune >= 0xFE70 && rune <= 0xFEFF)) {
        rtl++;
      }
    }
    if (letters == 0) return null;
    return rtl * 2 > letters ? TextDirection.rtl : TextDirection.ltr;
  }

  static bool _isWordUnit(int unit) =>
      (unit >= 0x30 && unit <= 0x39) || (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A) || unit == 0x5F;

  /// Unicode's letters (`\p{L}`): ASCII by hand, the rest asked of the regex
  /// once per character.
  static bool _isLetter(int rune) {
    if (rune < 0x80) return (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
    return _letters[rune] ??= _letter.hasMatch(String.fromCharCode(rune));
  }

  static final _letters = <int, bool>{};
  static final _letter = RegExp(r'\p{L}', unicode: true);

  /// Laid out in the post's own direction ([directionOf]), which can differ
  /// from the app's: list markers, alignment and punctuation follow it.
  @override
  Widget build(BuildContext context) {
    final direction = directionOf(content);
    final post = _post(context);
    return direction == null || direction == Directionality.of(context)
        ? post
        : Directionality(textDirection: direction, child: post);
  }

  Widget _post(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 16 with 1.5 line spacing: Material's 14/1.4 makes long posts read
    // noticeably denser.
    final body = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(fontSize: baseFontSize ?? 16);
    final bodyColor = textColor ?? body.color ?? colorScheme.onSurface;
    // One monospace size for code blocks and inline code, on every surface.
    final codeStyle = body.copyWith(
      fontFamily: 'monospace',
      fontSize: _codeFontSize,
      height: 1.4,
      color: bodyColor,
    );
    final mutedColor = colorScheme.onSurfaceVariant;
    final accent = colorScheme.primary;

    final html = _readableAuthorColours(content, colorScheme.surface);
    // The reader's token for the forum's file downloads; never for other sites.
    final media = ForumMediaAuth.of(siteContext);

    // Embed previews open the video itself (YouTube and the like, in their
    // app) through the same path as a link tap.
    void openEmbed(String url) {
      final resolved = _resolveUrl(url);
      if (callbacks?.onUrlTap != null) {
        callbacks!.onUrlTap!(resolved);
        return;
      }
      // ignore: discarded_futures
      openExternally(resolved);
    }

    return PostBodyFallback(
      html: html,
      style: body.copyWith(color: bodyColor, height: 1.5),
      child: Html(
      data: html,
      onLinkTap: (url, attributes, _) {
        if (url == null || url.isEmpty) return;
        // An in-page anchor; resolved against the forum it would read as a
        // link to the forum's home.
        if (url.startsWith('#')) return;
        final resolved = _resolveUrl(url);
        final classes =
            (attributes['class'] ?? '').split(RegExp(r'\s+'));
        // A user mention: <a class="UserMention" href="/u/{username}">@user</a>
        if (classes.contains('UserMention') &&
            callbacks?.onMentionTap != null) {
          final username = _usernameFromHref(url);
          if (username != null && username.isNotEmpty) {
            callbacks!.onMentionTap!(username);
            return;
          }
        }
        // A picture whose anchor is its full size (fof/upload's preview,
        // marked a.lightbox by FlarumHtml): open it in the in-app viewer.
        if (classes.contains('lightbox') && callbacks?.onImageTap != null) {
          callbacks!.onImageTap!(resolved, context, resolved);
          return;
        }
        // Everything else goes to the host, which opens the forum's own
        // pages in the app, or else outside the app.
        openEmbed(resolved);
      },
      // Relative URLs (img src, a href) resolve against the forum. An emoji
      // picture (`img.emoji`, from an extension) whose alt names a Unicode
      // emoji is drawn as the system glyph; Flarum itself stores emoji as
      // text.
      extensions: [
        const PostBlockRhythmExtension(),
        const QuoteExtension(),
        PostTableExtension(colorScheme: colorScheme),
        // Discussion and GitHub links, as the pills Flarum draws them.
        LinkPillExtension(onTap: openEmbed),
        MentionExtension(onTap: (href, isPost) {
          if (!isPost && callbacks?.onMentionTap != null) {
            final username = _usernameFromHref(href);
            if (username != null && username.isNotEmpty) {
              callbacks!.onMentionTap!(username);
              return;
            }
          }
          openEmbed(href);
        }),
        const DetailsExtension(),
        const SpoilerExtension(),
        ImageGridExtension(
          resolve: _resolveUrl,
          auth: media,
          onImageTap: callbacks?.onImageTap == null
              ? null
              : (full, imageContext) => callbacks!.onImageTap!(full, imageContext, full),
        ),
        _EmbedExtension(resolve: _resolveUrl, onOpen: openEmbed, auth: media),
        // fof/upload's file buttons, as FlarumHtml rewrites them
        // (`a.attachment` on the download endpoint): the file card, which
        // downloads the file signed in (see AttachmentFileCard).
        _AttachmentLinkExtension(resolve: _resolveUrl, auth: media),
        // Code blocks scroll sideways and never wrap, as on the web: wrapped,
        // indentation-sensitive code reads as a different program.
        TagExtension(
          tagsToExtend: {'pre'},
          builder: (extensionContext) {
            final code = extensionContext.element?.text ?? '';
            if (code.isEmpty) return const SizedBox.shrink();
            // Flarum marks the language as `language-php`.
            final language = RegExp(r'(?:^|\s)(?:language|lang)-([\w+#-]+)')
                .firstMatch(extensionContext.element?.querySelector('code')?.className ?? '')
                ?.group(1);
            return withBlockGap(
              extensionContext,
              // Code reads left to right, in a right-to-left post too.
              Directionality(
                textDirection: TextDirection.ltr,
                child: CodeBlock(
                  // A trailing newline would leave a blank band inside the block.
                  code: code.replaceAll(RegExp(r'\n+$'), ''),
                  language: language,
                  textStyle: codeStyle,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: {'img'},
          builder: (extensionContext) {
            final src = extensionContext.attributes['src'];
            final alt = extensionContext.attributes['alt'] ?? '';
            final classes = (extensionContext.attributes['class'] ?? '');
            final isEmoji = classes.contains('emoji');
            final onlyEmoji = classes.split(RegExp(r'\s+')).contains('only-emoji');

            if (isEmoji) {
              // alt is `:name:` or `:name:tN:` for a skin-toned emoji.
              final unicode = discourseEmojiForAlt(alt);
              if (unicode != null) {
                return Text(
                  unicode,
                  style: body.copyWith(
                    // Bump emoji slightly so they sit nicely with text; a
                    // post of nothing but emoji shows them large, as the
                    // web does (`img.emoji.only-emoji`, 32px) — the same
                    // size as an image emoji there.
                    fontSize: onlyEmoji ? _onlyEmojiSize : (body.fontSize ?? 14) * kEmojiGlyphScale,
                    height: 1.0,
                  ),
                );
              }
              // Fall through to the image renderer (forum-custom emoji,
              // shortcodes our table doesn't know).
            }

            if (src == null || src.isEmpty) return const SizedBox.shrink();
            final resolved = _resolveUrl(src);
            final w = onlyEmoji
                ? _onlyEmojiSize
                : double.tryParse(extensionContext.attributes['width'] ?? '') ??
                    (isEmoji ? 20 : null);
            final h = onlyEmoji
                ? _onlyEmojiSize
                : double.tryParse(extensionContext.attributes['height'] ?? '') ??
                    (isEmoji ? 20 : null);
            // Image.network cannot decode SVG (uploads, badges, GitHub's
            // favicon) and showed the alt text instead. BrandImage draws it
            // with flutter_svg from the disk cache, falling back the same way
            // when the file is missing or not SVG.
            final isSvg = BrandImage.isSvg(resolved);
            // An emoji that fails reads as its `:name:`; a picture gets the
            // same broken-image box as everywhere else.
            Widget fallback(BuildContext _) => isEmoji
                ? Text(alt, style: TextStyle(color: mutedColor))
                : BrokenImagePlaceholder(alt: alt);
            Widget picture({double? width, double? height}) => isSvg
                    ? BrandImage(
                        resolved,
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                        fallback: fallback,
                      )
                    : Image(
                                    image: forumImage(resolved, media),
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                        errorBuilder: (context, _, __) => fallback(context),
                      );
            // An upload wider than the column keeps its proportions. Given
            // both attributes, RenderImage clamps the width to the column
            // but keeps the height, and the picture ends up centred in a
            // box that is too tall — a blank band above and below every
            // large image. AspectRatio sizes the box from the width it
            // actually gets.
            final Widget image = (!isEmoji && w != null && h != null && w > 0 && h > 0)
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: w),
                    child: AspectRatio(aspectRatio: w / h, child: picture()),
                  )
                : picture(width: w, height: h);
            // A person's avatar (a quote's author) is round, as everywhere
            // else in the app, and is not a picture to open.
            if (classes.split(RegExp(r'\s+')).contains('avatar')) {
              return _NoBaseline(
                child: Padding(
                  padding: const EdgeInsets.only(right: DesignTokens.spacingXS),
                  child: ClipOval(child: image),
                ),
              );
            }
            if (isEmoji) return _NoBaseline(child: image);
            // A picture's corners are rounded as in an image grid and on a
            // video (they were square); an icon-sized image keeps its own.
            final icon = w != null && h != null && w < 48 && h < 48;
            final framed = icon
                ? image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(ImageGrid.radius),
                    child: image,
                  );
            // Route content-image taps to the in-app viewer (emoji stay
            // plain inline glyphs/images).
            final onImageTap = callbacks?.onImageTap;
            if (onImageTap == null) return _NoBaseline(child: framed);
            // A preview opens as its original, the address the viewer's
            // gallery lists it under (the anchor's href, see FlarumHtml). This
            // detector sits over the anchor, whose own tap never fires.
            final lightbox = _lightboxHref(extensionContext.node);
            final target = lightbox == null ? resolved : _resolveUrl(lightbox);
            return _NoBaseline(
              child: Builder(
                builder: (imageContext) => GestureDetector(
                  onTap: () => onImageTap(target, imageContext, target),
                  child: framed,
                ),
              ),
            );
          },
        ),
        // Web draws <hr> as a thin rule in the border colour. flutter_html's
        // default is a black Border.all box with auto margins, which in a
        // post left a heavy rule and ~280dp of blank space under it. Like any
        // block it has the block gap below it (the one above is the previous
        // block's), and it is centred in its line, which is taller than both.
        TagExtension.inline(
          tagsToExtend: {'hr'},
          builder: (extensionContext) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: withBlockGap(
              extensionContext,
              SizedBox(
                width: double.infinity,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
        // Inline code as text of the one code size on a tint, so it wraps with the sentence as on
        // the web. It was a chip (a WidgetSpan), which can't break: one that didn't fit jumped to
        // its own line, a long one became a block, and a "." after it could start a line alone.
        // Thin spaces inside the tint stand in for the chip's padding. Code in a link keeps the
        // link's own text (see the `code` style), so the link still taps.
        MatcherExtension.inline(
          matcher: (c) =>
              c.elementName == 'code' && !_hasAncestor(c.node, const {'pre', 'a'}),
          builder: (c) {
            final style = c.styledElement?.style.generateTextStyle() ?? codeStyle;
            return TextSpan(
              text: '\u2009${c.element?.text ?? ''}\u2009',
              style: style.copyWith(backgroundColor: colorScheme.surfaceContainerHighest),
            );
          },
        ),
        // A task list's box (FlarumHtml turns the checkbox into an empty
        // span.chcklst-box); checked and unchecked would otherwise read the same.
        MatcherExtension.inline(
          matcher: (c) => c.classes.contains('chcklst-box'),
          builder: (c) {
            final checked = c.classes.contains('checked');
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  checked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: (body.fontSize ?? 14) * 1.25,
                  color: checked ? accent : mutedColor,
                ),
              ),
            );
          },
        ),
        // Last, so nothing restyles an element after it.
        _SelectorStyles(_stylesFor(colorScheme, body, bodyColor, mutedColor, accent)),
      ],
      ),
    );
  }

  String _resolveUrl(String url) => resolveForumUrl(siteContext, url);
}

/// An emoji glyph in text is drawn this much larger than the text around
/// it, so it sits as the web's 20px emoji image does beside 16px text.
const double kEmojiGlyphScale = 1.15;

/// [url] from a post (an `img src`, an `a href`) as an absolute
/// address on [siteContext]'s forum.
String resolveForumUrl(SiteContext siteContext, String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  // Protocol-relative (`//host/…`): the forum's scheme, as a browser takes
  // the page's, so a forum served over http (a local one, an intranet)
  // still shows its pictures.
  if (url.startsWith('//')) {
    final scheme = Uri.tryParse(siteContext.site.url)?.scheme;
    return '${scheme == 'http' ? 'http' : 'https'}:$url';
  }
  // Join safely: a trailing-slash base must not produce double slashes.
  var base = siteContext.site.url;
  while (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  if (url.startsWith('/')) {
    // A forum in a subfolder may write its own paths with the subfolder
    // in them (`/forum/d/…`, `/forum/assets/…`); joined to the base they
    // would come out as /forum/forum/….
    final forum = Uri.tryParse(base);
    final basePath = forum?.path ?? '';
    if (forum != null &&
        forum.hasAuthority &&
        basePath.isNotEmpty &&
        (url == basePath || url.startsWith('$basePath/'))) {
      return '${forum.origin}$url';
    }
    return '$base$url';
  }
  return '$base/$url';
}

/// Code's one size, block and inline, in posts, messages and chat.
const double _codeFontSize = 14;

/// A post of nothing but emoji: glyph and image emoji alike, as the web's
/// `img.emoji.only-emoji`.
const double _onlyEmojiSize = 32;

/// Whether [node] sits inside any of [tags].
bool _hasAncestor(dom.Node node, Set<String> tags) {
  for (var p = node.parent; p != null; p = p.parent) {
    if (tags.contains(p.localName)) return true;
  }
  return false;
}

/// The href of the `a.lightbox` around [node] — a lightboxed upload's
/// original — or null.
String? _lightboxHref(dom.Node node) {
  for (var p = node.parent; p != null; p = p.parent) {
    if (p.localName == 'a' && p.classes.contains('lightbox')) {
      final href = p.attributes['href']?.trim();
      return href == null || href.isEmpty ? null : href;
    }
  }
  return null;
}

/// Author colours (`<font color>`, normalised to `#rrggbb` by FlarumHtml)
/// adjusted to stay readable on [surface]: black text turns light grey in
/// the dark theme, a pale cyan darkens on the light one. Hue is kept, and
/// colours that already contrast are left alone. Keyed by theme so a
/// light/dark switch re-renders with the other set.
final LRUCache<String, String> _themedHtmlCache = LRUCache(maxSize: 200);
final RegExp _authorColour = RegExp(r'(?<=\s)color="(#[0-9a-f]{6})"');

String _readableAuthorColours(String html, Color surface) {
  if (!html.contains('color="#')) return html;
  final key = '${surface.toARGB32()}\u0000$html';
  final hit = _themedHtmlCache.get(key);
  if (hit != null) return hit;
  final themed = html.replaceAllMapped(_authorColour, (m) {
    final adjusted = readableOn(colorFromHex(m.group(1)!), surface);
    return 'color="${colorToHex(adjusted)}"';
  });
  _themedHtmlCache.put(key, themed);
  return themed;
}

/// A post body's text, kept at hand in case flutter_html cannot build it.
///
/// When flutter_html throws while building a post (it did on an invalid
/// `<font color>`), Flutter puts an error box in its place — grey in
/// release and, inside a scrolling thread, unbounded: 100,000dp tall. With
/// this above the Html widget, the error box is replaced by the post's
/// plain text instead, so an unexpected construct degrades to something
/// readable.
class PostBodyFallback extends InheritedWidget {
  const PostBodyFallback({super.key, required this.html, this.style, required super.child});

  final String html;

  /// The body text's style, so the fallback reads at the post's size;
  /// bodyLarge when not given.
  final TextStyle? style;

  static PostBodyFallback? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PostBodyFallback>();

  String get plainText => _plainTextOf(html);

  @override
  bool updateShouldNotify(PostBodyFallback oldWidget) => oldWidget.html != html;
}

/// Wraps whatever ErrorWidget.builder is installed (Flutter's default unless
/// the host set its own). Only errors that took down a whole post body — no
/// flutter_html box between the failure and [PostBodyFallback] — become the
/// post's plain text; a failure deeper inside keeps the previous error
/// widget, bounded in height so it can never swallow a thread.
///
/// Called once from the app's error-handling setup; returns a callback that
/// restores the previous builder (tests use it).
VoidCallback installPostBodyErrorFallback() {
  final previous = ErrorWidget.builder;
  ErrorWidget.builder =
      (details) => _PostBodyErrorView(details: details, previous: previous);
  return () => ErrorWidget.builder = previous;
}

class _PostBodyErrorView extends StatelessWidget {
  const _PostBodyErrorView({required this.details, required this.previous});

  final FlutterErrorDetails details;
  final ErrorWidgetBuilder previous;

  @override
  Widget build(BuildContext context) {
    final fallback = PostBodyFallback.maybeOf(context);
    final insideRenderedHtml =
        context.findAncestorWidgetOfExactType<CssBoxWidget>() != null;
    if (fallback != null && !insideRenderedHtml) {
      return Text(fallback.plainText,
          style: fallback.style ?? Theme.of(context).textTheme.bodyLarge);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: previous(details),
    );
  }
}

const _plainTextBlocks = {
  'p', 'div', 'li', 'ul', 'ol', 'table', 'tr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'pre', 'blockquote', 'aside', 'header', 'article', 'section', 'details',
  'summary', 'figure', 'figcaption', 'hr', 'dl', 'dt', 'dd',
};

String _plainTextOf(String html) {
  final sb = StringBuffer();
  void walk(dom.Node node) {
    if (node is dom.Text) {
      sb.write(node.text);
      return;
    }
    if (node is dom.Element) {
      final tag = node.localName;
      if (tag == 'br') {
        sb.write('\n');
        return;
      }
      if (tag == 'script' || tag == 'style') return;
      final block = _plainTextBlocks.contains(tag);
      if (block) sb.write('\n');
      node.nodes.forEach(walk);
      if (block) sb.write('\n');
      return;
    }
    node.nodes.forEach(walk);
  }

  walk(html_parser.parseFragment(html));
  return sb
      .toString()
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r' *\n[\s]*\n+ *'), '\n\n')
      .trim();
}

/// Embeds, drawn as native previews where the web shows the player (see
/// [EmbedLink]):
///
///  * `<iframe>` — s9e's media embeds (YouTube, Vimeo and the rest): a video
///    preview for video sites, a row naming the site for the rest;
///  * `<video>` — played in the app's video viewer — and `<audio>`, played
///    in place.
///
/// flutter_html renders none of these by itself.
class _EmbedExtension extends HtmlExtension {
  const _EmbedExtension({required this.resolve, required this.onOpen, this.auth});

  final String Function(String url) resolve;
  final void Function(String url) onOpen;
  final ForumMediaAuth? auth;

  @override
  Set<String> get supportedTags => const {'iframe', 'video', 'audio'};

  @override
  bool matches(ExtensionContext context) {
    switch (context.elementName) {
      case 'iframe':
        return (context.attributes['src'] ?? '').trim().isNotEmpty;
      case 'video':
      case 'audio':
        return _mediaSrc(context.element) != null;
    }
    return false;
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final card = _card(context);
    // Markup that did not yield a card renders as it would have otherwise.
    if (card == null) return TextSpan(children: context.inlineSpanChildren);
    return WidgetSpan(
      child: SizedBox(width: double.infinity, child: withBlockGap(context, card)),
    );
  }

  Widget? _card(ExtensionContext context) {
    final element = context.element;
    if (element == null) return null;
    final a = element.attributes;
    switch (context.elementName) {
      case 'iframe':
        // An iframe's content is its fallback markup, kept as raw text.
        final fallback = element.text;
        final innerHref = RegExp(r'href="([^"]+)"').firstMatch(fallback)?.group(1);
        final innerText = fallback.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
        final link = EmbedLink.fromIframe(
          resolve(a['src']!.trim()),
          title: a['title'],
          innerHref: innerHref,
          innerText: innerText.isEmpty ? null : innerText,
        );
        return link == null ? null : EmbedPreviewCard(link: link, onOpen: onOpen);
      case 'video':
        final src = _mediaSrc(element)!;
        final poster = a['poster'];
        final w = double.tryParse(a['width'] ?? '');
        final h = double.tryParse(a['height'] ?? '');
        return PostVideoCard(
          src: resolve(src),
          poster: poster == null || poster.isEmpty ? null : resolve(poster),
          aspectRatio: (w != null && h != null && h > 0) ? w / h : null,
          title: a['title'],
          auth: auth,
        );
      case 'audio':
        return PostAudioPlayer(src: resolve(_mediaSrc(element)!), auth: auth);
    }
    return null;
  }

  /// A `<video>`/`<audio>` source: its `src`, or its first `<source src>`.
  static String? _mediaSrc(dom.Element? element) {
    if (element == null) return null;
    final own = element.attributes['src']?.trim();
    if (own != null && own.isNotEmpty) return own;
    final source = element.querySelector('source[src]')?.attributes['src']?.trim();
    return (source == null || source.isEmpty) ? null : source;
  }
}

/// Renders `a.attachment` (fof/upload's file buttons, as FlarumHtml rewrites
/// them) as the same file row the composer shows: a file-type tile, the
/// name, and its size. Matches only that class, so other links keep the
/// default handling.
class _AttachmentLinkExtension extends HtmlExtension {
  const _AttachmentLinkExtension({required this.resolve, this.auth});

  final String Function(String url) resolve;
  final ForumMediaAuth? auth;

  @override
  Set<String> get supportedTags => {'a'};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'a' && context.classes.contains('attachment');

  @override
  InlineSpan build(ExtensionContext context) {
    final href = (context.attributes['href'] ?? '').trim();

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      // minWidth infinity makes the card fill the line box, so it reads as
      // a row in a list rather than a chip floating in a paragraph —
      // matching the composer's attachment list.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
          child: AttachmentFileCard(
            name: context.element?.text.trim() ?? '',
            url: href.isEmpty ? '' : resolve(href),
            size: context.attributes['data-size'],
            auth: auth,
          ),
        ),
      ),
    );
  }
}

/// flutter_html style tables, one per theme.
///
/// The map is ~20 `Style` objects with their margins, paddings and
/// borders; building it inside `build()` meant every post allocated all
/// of it on every rebuild. It depends only on the theme, so it is built
/// once per distinct colour/size combination and shared.
final Map<(int, int, int, int, double), Map<String, Style>> _styleCache = {};

Map<String, Style> _stylesFor(ColorScheme colorScheme, TextStyle body,
    Color bodyColor, Color mutedColor, Color accent) {
  final key = (
    bodyColor.toARGB32(),
    mutedColor.toARGB32(),
    accent.toARGB32(),
    colorScheme.surfaceContainerHighest.toARGB32(),
    body.fontSize ?? 14,
  );
  final base = body.fontSize ?? 16;

  // Headings on the type scale — h1 headlineSmall 24/32 down to h5/h6
  // bodyLarge 16/24 — never smaller than the body text, medium weight,
  // with more room above (16, none as a first block) than below (8).
  Style heading(double size, double lineHeight, {Color? color}) => Style(
        fontSize: FontSize(math.max(size, base)),
        lineHeight: LineHeight(lineHeight / size),
        fontWeight: FontWeight.w500,
        color: color,
        margin: Margins.only(top: DesignTokens.spacingL, bottom: DesignTokens.spacingS),
      );

  // A quote is a filled block with the accent bar, padded evenly; the
  // corners are rounded by QuoteExtension.
  Style quote() => Style(
        display: Display.block,
        margin: Margins.only(bottom: kPostBlockGap),
        padding: HtmlPaddings.all(DesignTokens.spacingM),
        backgroundColor: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
      );

  return _styleCache.putIfAbsent(key, () => {
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(base),
      color: bodyColor,
      lineHeight: const LineHeight(1.5),
    ),
    // Every block takes the one block gap below itself and none above;
    // PostBlockRhythmExtension drops it after the last block of a post,
    // quote or details.
    'p': Style(
      margin: Margins.only(bottom: kPostBlockGap),
      padding: HtmlPaddings.zero,
    ),
    // Blocks drawn natively (code, embeds, tables, details, rules) take the
    // same gap; withBlockGap draws what is left of it once margins have
    // collapsed.
    'pre, hr, table, details, iframe, video, audio': Style(
      margin: Margins(bottom: Margin(kPostBlockGap)),
    ),
    // The web marks links by colour alone.
    'a': Style(
      color: accent,
      textDecoration: TextDecoration.none,
    ),
    'a.UserMention, a.PostMention': Style(
      color: accent,
      fontWeight: FontWeight.w500,
      textDecoration: TextDecoration.none,
    ),
    'blockquote': quote(),
    // Inline code is drawn as a rounded chip (see the `code` extension);
    // the fill here is for code inside a link, which stays text. Blocks
    // (`pre`) are CodeBlock, in the same size.
    'code': Style(
      backgroundColor: colorScheme.surfaceContainerHighest,
      fontSize: FontSize(_codeFontSize),
      fontFamily: 'monospace',
    ),
    // The indent is on the marker's side: the right in a right-to-left post.
    'ul, ol': Style(
      margin: Margins.only(bottom: kPostBlockGap),
      padding: HtmlPaddings.only(inlineStart: 24),
    ),
    // Nested bullets as the web draws them: hollow, then square.
    'ul ul': Style(listStyleType: ListStyleType.circle),
    'ul ul ul': Style(listStyleType: ListStyleType.square),
    'li': Style(margin: Margins.only(bottom: DesignTokens.spacingXS)),
    // The list's own gap follows its last item; a list inside an item sits
    // tight in it.
    'li:last-child': Style(margin: Margins(bottom: Margin.zero())),
    'li > ul, li > ol': Style(margin: Margins.zero),
    // A task list (see FlarumHtml): a box per item, no bullets.
    'div.task-list': Style(margin: Margins.only(bottom: kPostBlockGap)),
    'div.task-item': Style(margin: Margins.only(bottom: DesignTokens.spacingXS)),
    'h1': heading(24, 32),
    'h2': heading(22, 28),
    'h3': heading(20, 28),
    'h4': heading(18, 26),
    'h5': heading(16, 24),
    'h6': heading(16, 24, color: mutedColor),
    'img.emoji': Style(
      width: Width(20),
      height: Height(20),
      display: Display.inlineBlock,
      verticalAlign: VerticalAlign.middle,
    ),
  });
}

/// The post's styles by CSS selector, applied as flutter_html's `style` map
/// would be, but with each selector read once. flutter_html matches every
/// element against every selector through `package:html`, which parses the
/// selector again each time: with our 22 selectors that was as much of a
/// post's first build as the rest of its styling. The selectors are the few
/// shapes [_Selector] reads; an element's own `style` attribute is applied
/// after these, where flutter_html applied the map last.
class _SelectorStyles extends HtmlExtension {
  _SelectorStyles(Map<String, Style> styles)
      : _rules = [for (final MapEntry(:key, :value) in styles.entries) (_Selector.parse(key), value)];

  final List<(_Selector, Style)> _rules;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) =>
      context.currentStep == CurrentStep.preStyling && context.node is dom.Element;

  @override
  void beforeStyle(ExtensionContext context) {
    final element = context.node as dom.Element;
    final styled = context.styledElement!;
    for (final (selector, style) in _rules) {
      if (selector.matches(element)) styled.style = styled.style.merge(style);
    }
  }
}

/// A CSS selector list in the shapes the post's styles use: `tag`,
/// `tag.class`, `tag:last-child`, joined by descendant (` `) or child (`>`)
/// combinators, several to a list (`a, b`). Read once, cached by its text.
class _Selector {
  _Selector._(this._alternatives);

  factory _Selector.parse(String text) => _parsed.putIfAbsent(text, () {
        final alternatives = <List<(_Compound, bool)>>[];
        for (final complex in text.split(',')) {
          final parts = <(_Compound, bool)>[];
          var child = false;
          for (final token in complex.trim().split(RegExp(r'\s+'))) {
            if (token == '>') {
              child = true;
              continue;
            }
            parts.add((_Compound.parse(token), child));
            child = false;
          }
          alternatives.add(parts);
        }
        return _Selector._(alternatives);
      });

  static final _parsed = <String, _Selector>{};

  /// Each alternative's compounds, left to right, each with whether it is
  /// its left neighbour's child (`>`) rather than any descendant.
  final List<List<(_Compound, bool)>> _alternatives;

  bool matches(dom.Element element) => _alternatives.any((parts) => _matchFrom(element, parts, parts.length - 1));

  static bool _matchFrom(dom.Element element, List<(_Compound, bool)> parts, int i) {
    final (compound, child) = parts[i];
    if (!compound.matches(element)) return false;
    if (i == 0) return true;
    if (child) {
      final parent = element.parent;
      return parent != null && _matchFrom(parent, parts, i - 1);
    }
    for (var ancestor = element.parent; ancestor != null; ancestor = ancestor.parent) {
      if (_matchFrom(ancestor, parts, i - 1)) return true;
    }
    return false;
  }
}

class _Compound {
  const _Compound(this.tag, this.className, this.lastChild);

  factory _Compound.parse(String token) {
    final match = RegExp(r'^([a-z][a-z0-9]*)(?:\.([\w-]+))?(:last-child)?$').firstMatch(token);
    if (match == null) throw ArgumentError.value(token, 'selector', 'not a shape _Selector reads');
    return _Compound(match[1]!, match[2], match[3] != null);
  }

  final String tag;
  final String? className;
  final bool lastChild;

  bool matches(dom.Element element) =>
      element.localName == tag &&
      (className == null || element.classes.contains(className)) &&
      (!lastChild || element.nextElementSibling == null);
}

/// An inline picture has no text baseline; this says so when asked "dry",
/// as it already does in real layout.
///
/// flutter_html places a linked image in a baseline-aligned placeholder.
/// A paragraph measuring its intrinsic width (a table sizing its columns)
/// asks such children for a dry baseline, which RenderImage cannot give:
/// it threw, and the table cell was never laid out.
class _NoBaseline extends SingleChildRenderObjectWidget {
  const _NoBaseline({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoBaseline();
}

class _RenderNoBaseline extends RenderProxyBox {
  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) => null;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => null;
}
