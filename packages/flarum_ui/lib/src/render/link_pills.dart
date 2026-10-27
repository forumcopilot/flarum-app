import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/discourse_icons.dart';
import 'package:html/dom.dart' as dom;

/// Links Flarum draws as a pill of parts, drawn as one here too:
///
///  * a link to a discussion or post on the forum (Flarum 2.0's `a.UrlLink--discussion`): its
///    favicon, `#40083`, and for a post a comment icon and the post's number;
///  * a GitHub link (`a.Github-embed`, from the forum's GitHub links extension): the GitHub mark,
///    the repository in bold, then what it points to: a path, a pull request's or issue's number,
///    a release's tag, a commit, or a comparison (`1.0.4 → 1.0.5`), each after its icon.
///
/// flutter_html drew their parts as they came: the favicon as a full-size picture, and the parts
/// run together ("anti-spam4"), since their spacing and icons are the web's CSS and Font Awesome.
class LinkPillExtension extends HtmlExtension {
  const LinkPillExtension({required this.onTap});

  /// Called with the link's address.
  final void Function(String href) onTap;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'a' &&
      (context.classes.contains('Github-embed') ||
          context.classes.contains('UrlLink--discussion') ||
          (context.element?.querySelector('img.UrlLink-favicon') != null));

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.element;
    if (element == null) return TextSpan(children: context.inlineSpanChildren);
    final href = context.attributes['href'] ?? '';
    final parts = <_Part>[];
    _collect(element, parts);
    if (parts.isEmpty) return TextSpan(children: context.inlineSpanChildren);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _LinkPill(
        parts: parts,
        style: context.styledElement?.style.generateTextStyle(),
        label: element.text.trim(),
        onTap: href.isEmpty ? null : () => onTap(href),
      ),
    );
  }

  /// [element]'s parts in order: pictures, icons and pieces of text.
  static void _collect(dom.Element element, List<_Part> parts) {
    for (final node in element.nodes) {
      if (node is dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) parts.add(_Part.text(text));
        continue;
      }
      if (node is! dom.Element) continue;
      switch (node.localName) {
        case 'img':
          final src = node.attributes['src'];
          if (src != null && src.isNotEmpty) parts.add(_Part.picture(src));
        case 'i':
          final name = node.classes.where((c) => c.startsWith('fa-')).lastOrNull;
          if (name == 'fa-github') {
            parts.add(const _Part.github());
          } else if (_icons[name] ?? materialIconForDiscourseIcon(name) case final icon?) {
            parts.add(_Part.icon(icon));
          }
        case 'code':
          final text = node.text.trim();
          if (text.isNotEmpty) parts.add(_Part.text(text, code: true));
        case 'span' when node.classes.contains('github-repo-name'):
          final text = node.text.trim();
          if (text.isNotEmpty) parts.add(_Part.text(text, strong: true));
        default:
          _collect(node, parts);
      }
    }
  }

  /// Font Awesome icons these links use that forum_kit's map (made for Discourse's category icons)
  /// doesn't have.
  static const _icons = <String, IconData>{
    'fa-code-branch': Icons.call_split,
    'fa-exclamation-circle': Icons.error_outline,
    'fa-arrow-right': Icons.arrow_forward,
    'fa-hashtag': Icons.tag,
  };
}

/// A piece of a pill: text (in bold, or as code), an icon, a picture, or the GitHub mark.
class _Part {
  const _Part.text(this.text, {this.strong = false, this.code = false})
      : icon = null,
        picture = null,
        github = false;
  const _Part.icon(this.icon)
      : text = null,
        picture = null,
        strong = false,
        code = false,
        github = false;
  const _Part.picture(this.picture)
      : text = null,
        icon = null,
        strong = false,
        code = false,
        github = false;
  const _Part.github()
      : text = null,
        icon = null,
        picture = null,
        strong = false,
        code = false,
        github = true;

  final String? text;
  final bool strong;
  final bool code;
  final IconData? icon;
  final String? picture;
  final bool github;
}

class _LinkPill extends StatelessWidget {
  const _LinkPill({required this.parts, required this.label, this.style, this.onTap});

  final List<_Part> parts;

  /// What a screen reader says: the link's text.
  final String label;
  final TextStyle? style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = style?.fontSize ?? 16;
    final iconSize = size * 0.9;
    final text = (style ?? const TextStyle()).copyWith(
      fontSize: size * 0.93,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurface,
      decoration: TextDecoration.none,
      backgroundColor: Colors.transparent,
      height: 1.0,
    );
    final muted = colorScheme.onSurfaceVariant;
    final children = <Widget>[];
    for (final part in parts) {
      if (children.isNotEmpty) children.add(SizedBox(width: size * 0.3));
      if (part.github) {
        children.add(SvgPicture.string(
          _githubMark,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
        ));
      } else if (part.icon case final icon?) {
        children.add(Icon(icon, size: iconSize, color: muted));
      } else if (part.picture case final src?) {
        children.add(ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            src,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => SizedBox(width: iconSize, height: iconSize),
          ),
        ));
      } else if (part.text case final value?) {
        children.add(Text(
          value,
          maxLines: 1,
          softWrap: false,
          style: part.code
              ? text.copyWith(fontFamily: 'monospace', fontSize: size * 0.85, color: muted)
              : part.strong
                  ? text.copyWith(fontWeight: FontWeight.w600)
                  : text,
        ));
      }
    }
    return Semantics(
      link: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size * 0.2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
          ),
          // Its whole width, so a pill that doesn't fit the rest of a line moves to the next, as on
          // the web; only one wider than a whole line is scaled down to it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}

/// GitHub's mark (github.com/logos), for links to GitHub.
const _githubMark = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 98 96"><path fill-rule="evenodd" '
    'clip-rule="evenodd" d="M48.854 0C21.839 0 0 22 0 49.217c0 21.756 13.993 40.172 33.405 46.69 2.427.49 '
    '3.316-1.059 3.316-2.362 0-1.141-.08-5.052-.08-9.127-13.59 2.934-16.42-5.867-16.42-5.867-2.184-5.704-5.42-7.17'
    '-5.42-7.17-4.448-3.015.324-3.015.324-3.015 4.934.326 7.523 5.052 7.523 5.052 4.367 7.496 11.404 5.378 14.235 '
    '4.074.404-3.178 1.699-5.378 3.074-6.6-10.839-1.141-22.243-5.378-22.243-24.283 0-5.378 1.94-9.778 5.014-13.2'
    '-.485-1.222-2.184-6.275.486-13.038 0 0 4.125-1.304 13.426 5.052a46.97 46.97 0 0 1 12.214-1.63c4.125 0 8.33.571 '
    '12.213 1.63 9.302-6.356 13.427-5.052 13.427-5.052 2.67 6.763.97 11.816.485 13.038 3.155 3.422 5.015 7.822 5.015 '
    '13.2 0 18.905-11.404 23.06-22.324 24.283 1.78 1.548 3.316 4.481 3.316 9.126 0 6.6-.08 11.897-.08 13.526 0 1.304'
    '.89 2.853 3.316 2.364 19.412-6.52 33.405-24.935 33.405-46.691C97.707 22 75.788 0 48.854 0z" fill="#000"/></svg>';
