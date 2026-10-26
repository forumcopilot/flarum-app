import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import 'package:forum_kit/utils/html_colors.dart';
import 'package:forum_kit/views/widgets/brand_image.dart';
import 'package:forum_kit/views/widgets/forum_icon_tile.dart';

import '../../l10n/flarum_l10n.dart';

/// The top of a forum's Home, as the Discourse app's masthead: the forum's logo (or its icon and
/// name), a line about the forum and a search field, on the forum's header colour, with its accent
/// along the bottom.
///
/// It collapses into the bar as the page scrolls: ☰, the forum's icon and name, and a search
/// button, the accent line still under it, so the screen always says whose it is.
class ForumMasthead extends StatelessWidget {
  const ForumMasthead({
    super.key,
    required this.name,
    required this.onSearch,
    this.description,
    this.logoUrl,
    this.iconUrl,
    this.leading,
    this.actions = const [],
  });

  final String name;

  /// One line about the forum (its description).
  final String? description;

  /// The forum's logo for this appearance (its dark-mode logo in dark mode), shown while open.
  final String? logoUrl;

  /// Its favicon, beside the name once collapsed.
  final String? iconUrl;
  final VoidCallback onSearch;

  /// ☰, in a forum's tabs.
  final Widget? leading;

  /// Always in the bar, after search (Mark All as Read).
  final List<Widget> actions;

  static const toolbarHeight = 64.0;
  static const lineHeight = 3.0;
  static const searchHeight = 48.0;

  double _introHeight(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? s) => (scaler.scale(s?.fontSize ?? 14) * (s?.height ?? 1.4) - 1e-6).ceilToDouble();
    var h = 0.0;
    if (logoUrl != null) {
      h += line(text.titleLarge);
      if (description != null) h += 2;
    }
    if (description != null) h += line(text.bodyMedium);
    if (h > 0) h += 12;
    return h + searchHeight + 16;
  }

  /// The bar's height once the header has collapsed, for a refresh spinner to show under it.
  static double collapsedHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).top + toolbarHeight + lineHeight;

  @override
  Widget build(BuildContext context) {
    final colors = ForumColors.of(context);
    final background = colors.headerBackground;
    var foreground = colors.headerPrimary;
    if (contrastRatio(foreground, background) < 4.5) {
      foreground = contrastRatio(Colors.white, background) >= contrastRatio(Colors.black, background)
          ? Colors.white
          : Colors.black;
    }
    final darkBackground = background.computeLuminance() < 0.2;
    final overlay = darkBackground ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    final style = _MastheadStyle(background: background, foreground: foreground, dark: darkBackground);
    return SliverAppBar(
      pinned: true,
      expandedHeight: toolbarHeight + _introHeight(context) + lineHeight,
      toolbarHeight: toolbarHeight,
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      titleSpacing: leading == null ? null : 4,
      leading: leading,
      automaticallyImplyLeading: leading == null,
      title: _MastheadTitle(name: name, logoUrl: logoUrl, iconUrl: iconUrl, style: style),
      actions: [
        _CollapsedOnly(
          child: IconButton(tooltip: flarumL10n(context).search, icon: const Icon(Icons.search), onPressed: onSearch),
        ),
        ...actions,
        const SizedBox(width: 4),
      ],
      flexibleSpace: _MastheadIntro(
        name: name,
        description: description,
        showName: logoUrl != null,
        onSearch: onSearch,
        style: style,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(lineHeight),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.primary,
          child: const SizedBox(height: lineHeight, width: double.infinity),
        ),
      ),
    );
  }
}

class _MastheadStyle {
  const _MastheadStyle({required this.background, required this.foreground, required this.dark});

  final Color background;
  final Color foreground;
  final bool dark;
}

/// How far the masthead has collapsed: 1 fully open, 0 down to its bar.
double mastheadOpenness(BuildContext context) {
  final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
  if (settings == null) return 1;
  final range = settings.maxExtent - settings.minExtent;
  if (range <= 0) return 0;
  return ((settings.currentExtent - settings.minExtent) / range).clamp(0.0, 1.0);
}

/// The forum's logo while the header is open; its icon and name once it has become the bar.
class _MastheadTitle extends StatelessWidget {
  const _MastheadTitle({required this.name, required this.style, this.logoUrl, this.iconUrl});

  final String name;
  final String? logoUrl;
  final String? iconUrl;
  final _MastheadStyle style;

  @override
  Widget build(BuildContext context) {
    final open = mastheadOpenness(context) > 0.5;
    final logo = logoUrl;
    final Widget child;
    if (open && logo != null) {
      child = Semantics(
        key: const ValueKey('logo'),
        header: true,
        label: name,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 36, maxWidth: 240),
            child: BrandImage(
              logo,
              height: 36,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              background: style.background,
              fallback: (_) => _iconAndName(context),
            ),
          ),
        ),
      );
    } else {
      child = KeyedSubtree(key: const ValueKey('iconAndName'), child: _iconAndName(context));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, if (current != null) current],
      ),
      child: child,
    );
  }

  /// The name at title size, or a size down when that would cut it short.
  TextStyle? _nameStyle(BuildContext context, double width) {
    final text = Theme.of(context).textTheme;
    TextStyle? styled(TextStyle? s) => s?.copyWith(color: style.foreground, fontWeight: FontWeight.w500);
    final large = styled(text.titleLarge);
    final painter = TextPainter(
      text: TextSpan(text: name, style: large),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final fits = !painter.didExceedMaxLines && painter.width <= width;
    painter.dispose();
    return fits ? large : styled(text.titleMedium);
  }

  Widget _iconAndName(BuildContext context) => Semantics(
        header: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ForumIconTile(name: name, url: iconUrl, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) => Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _nameStyle(context, constraints.maxWidth),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Shown only once the header has collapsed (the search button, which the open header has as a
/// field).
class _CollapsedOnly extends StatelessWidget {
  const _CollapsedOnly({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shown = mastheadOpenness(context) < 0.3;
    return AnimatedOpacity(
      opacity: shown ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: ExcludeSemantics(excluding: !shown, child: IgnorePointer(ignoring: !shown, child: child)),
    );
  }
}

/// The open header's lower half: the forum's name when the bar shows its logo, the line about the
/// forum and the search field, clipped between the bar and the accent line so it slides under the
/// bar as the page scrolls.
class _MastheadIntro extends StatelessWidget {
  const _MastheadIntro({
    required this.name,
    required this.showName,
    required this.onSearch,
    required this.style,
    this.description,
  });

  final String name;
  final bool showName;
  final String? description;
  final VoidCallback onSearch;
  final _MastheadStyle style;

  @override
  Widget build(BuildContext context) {
    final t = mastheadOpenness(context);
    final opacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final hidden = opacity < 0.5;
    final text = Theme.of(context).textTheme;
    final fg = style.foreground;
    final description = this.description;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The bar's logo already names the forum to a screen reader.
          if (showName) ...[
            ExcludeSemantics(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w600)),
            ),
            if (description != null) const SizedBox(height: 2),
          ],
          if (description != null)
            Text(description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.8))),
          if (showName || description != null) const SizedBox(height: 12),
          SizedBox(
            height: ForumMasthead.searchHeight,
            child: Semantics(
              button: true,
              child: Material(
                color: Color.alphaBlend(fg.withValues(alpha: style.dark ? 0.12 : 0.06), style.background),
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSearch,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Icon(Icons.search, color: fg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          flarumL10n(context).searchForum(name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge?.copyWith(color: fg.withValues(alpha: 0.7)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Stack(children: [
      Positioned(
        top: MediaQuery.paddingOf(context).top + ForumMasthead.toolbarHeight,
        left: 0,
        right: 0,
        bottom: ForumMasthead.lineHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Opacity(
              opacity: opacity,
              child: IgnorePointer(ignoring: hidden, child: ExcludeSemantics(excluding: hidden, child: content)),
            ),
          ),
        ),
      ),
    ]);
  }
}
