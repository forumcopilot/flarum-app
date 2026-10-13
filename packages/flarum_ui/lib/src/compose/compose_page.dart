import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/emoji_shortcodes.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/discard_changes_scope.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';
import 'flarum_markup.dart';
import 'mention_picker_page.dart';

/// A full-screen composer: an optional title, the post's text with a formatting toolbar and
/// @-mentions, and Send (Save for an edit).
///
/// Copied from discourse_ui's MessageComposePage and adapted, as decided on 9 October 2026:
/// Flarum's markup ([FlarumMarkup]), its mention format, and its refusals (the posting throttle,
/// a 2.0 forum's reason per field). Uploads come with fof/upload in a later milestone.
class ComposePage extends StatefulWidget {
  const ComposePage({
    super.key,
    required this.site,
    required this.title,
    required this.onSubmit,
    this.showTitleField = false,
    this.initialTitle,
    this.initialContent,
    this.topicTitle,
    this.header,
    this.isEdit = false,
  });

  final SiteContext site;

  /// The page's title: Reply, Start a discussion, Edit post.
  final String title;

  /// Sends what was written. Its value closes the page and goes back to whoever opened it; a
  /// throw keeps the page open, with the reason shown.
  final Future<Object?> Function(String title, String content) onSubmit;

  final bool showTitleField;
  final String? initialTitle;
  final String? initialContent;

  /// The discussion a reply goes to, shown above the text.
  final String? topicTitle;

  /// Above the title: a new discussion's tags.
  final Widget? header;

  /// An edit of a post that exists: Save, and closing asks about losing the changes.
  final bool isEdit;

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  late final _titleController = TextEditingController(text: widget.initialTitle ?? '');
  late final _contentController = TextEditingController(text: widget.initialContent ?? '');
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _scrollController = _HoldWhilePressedScrollController();
  bool _isSubmitting = false;
  bool _isContentFieldFocused = false;

  /// Members matching the `@name` being typed, offered above the toolbar.
  List<FlarumUser> _suggestions = const [];
  Timer? _suggestTimer;
  int _suggestSearches = 0;

  /// What the composer opened with, for [_hasChanges].
  late final String _openedTitle = _titleController.text;
  late final String _openedContent = _contentController.text;

  bool _hasChanges() => _titleController.text != _openedTitle || _contentController.text != _openedContent;

  /// Whether the toolbar offers @-mentions: they need the forum's search-users permission.
  bool get _canMention => FlarumForum.of(widget.site).info?.can('canSearchUsers') ?? false;

  @override
  void initState() {
    super.initState();
    _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      (widget.showTitleField && _titleController.text.isEmpty ? _titleFocusNode : _contentFocusNode).requestFocus();
    });
    _contentFocusNode.addListener(() => setState(() => _isContentFieldFocused = _contentFocusNode.hasFocus));
    _contentController.addListener(_contentChanged);
  }

  @override
  void dispose() {
    _suggestTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Applies a formatting action at the cursor, wrapping the selection when there is one.
  void _insertMarkup(String tag) {
    _contentController.value = FlarumMarkup.apply(_contentController.value, tag);
    _contentFocusNode.requestFocus();
  }

  /// Puts [text] at the cursor (in place of the selection), the cursor after it.
  void _insertAtCursor(String text) {
    final value = _contentController.value;
    final selection = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    final newText = value.text.replaceRange(selection.start, selection.end, text);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    );
  }

  /// The `@name` typed just before the cursor, as the web's mention autocomplete reads it.
  ({int start, String query})? _mentionAtCursor() {
    final value = _contentController.value;
    final cursor = value.selection.baseOffset;
    if (!value.selection.isCollapsed || cursor < 0 || cursor > value.text.length) return null;
    final typed = RegExp(r'(?:^|[\s(])@([^\s@"#]{2,30})$').firstMatch(value.text.substring(0, cursor));
    if (typed == null) return null;
    final query = typed.group(1)!;
    return (start: cursor - query.length - 1, query: query);
  }

  void _contentChanged() {
    if (!_canMention) return;
    _suggestTimer?.cancel();
    final typing = _mentionAtCursor();
    if (typing == null) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _suggestTimer = Timer(const Duration(milliseconds: 250), () => _suggest(typing.query));
  }

  Future<void> _suggest(String query) async {
    final search = ++_suggestSearches;
    try {
      final page = await FlarumForum.of(widget.site).api.searchUsers(query);
      if (!mounted || search != _suggestSearches || _mentionAtCursor()?.query != query) return;
      setState(() => _suggestions = page.items.take(5).toList());
    } catch (_) {
      // Suggestions are a convenience; the mention button still searches.
    }
  }

  /// Puts [user]'s mention in place of the `@name` being typed.
  void _pickSuggestion(FlarumUser user) {
    final typing = _mentionAtCursor();
    if (typing == null) return;
    final value = _contentController.value;
    final mention = '${FlarumMarkup.userMention(user.displayName, user.id)} ';
    _contentController.value = TextEditingValue(
      text: value.text.replaceRange(typing.start, value.selection.baseOffset, mention),
      selection: TextSelection.collapsed(offset: typing.start + mention.length),
    );
    setState(() => _suggestions = const []);
  }

  Future<void> _mention() async {
    final user = await MentionPickerPage.open(context, widget.site);
    if (user == null || !mounted) return;
    _insertAtCursor('${FlarumMarkup.userMention(user.displayName, user.id)} ');
    _contentFocusNode.requestFocus();
  }

  void _showNotice(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit() async {
    final l10n = flarumL10n(context);
    if (widget.showTitleField && _titleController.text.trim().isEmpty) {
      _showNotice(l10n.pleaseEnterTitle);
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      _showNotice(l10n.pleaseEnterContent);
      return;
    }
    // The fields lock while sending; focus would hop to the next field still open.
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final result = await widget.onSubmit(_titleController.text.trim(), _contentController.text.trim());
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      SnackbarHelper.showError(context, switch (e) {
        ComposeProblem(:final message) => message,
        FlarumApiException(isThrottled: true) => l10n.postingThrottled,
        // A 2.0 forum names each field it refused, 1.x the first rule.
        FlarumApiException() => e.reasons,
        _ => '$e',
      });
    }
  }

  void _close() {
    FocusScope.of(context).unfocus();
    // maybePop, so closing asks first when there is writing to lose.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DiscardChangesScope(
      listenable: Listenable.merge([_titleController, _contentController]),
      hasChanges: _hasChanges,
      isEdit: widget.isEdit,
      busy: _isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          // A composer is a full-screen dialog: ✕ closes it, where ← would mean a step back.
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: _close,
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.isEdit ? l10n.save : l10n.send),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: DesignTokens.paddingL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!widget.showTitleField && (widget.topicTitle ?? '').isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.reply_rounded, size: DesignTokens.iconSizeM, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: DesignTokens.spacingS),
                              Expanded(
                                child: Text(
                                  withEmojiShortcodes(widget.topicTitle!),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DesignTokens.spacingL),
                        ],
                        if (widget.header != null) ...[
                          widget.header!,
                          const SizedBox(height: DesignTokens.spacingL),
                        ],
                        if (widget.showTitleField) ...[
                          TextField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            decoration: InputDecoration(labelText: l10n.title, hintText: l10n.composerTitleHint),
                            textCapitalization: TextCapitalization.sentences,
                            enabled: !_isSubmitting,
                          ),
                          const SizedBox(height: DesignTokens.spacingL),
                        ],
                        // The page holds still while a finger is on the text:
                        // see _HoldWhilePressedScrollController.
                        Listener(
                          onPointerDown: (_) => _scrollController.press(),
                          onPointerUp: (_) => _scrollController.lift(),
                          onPointerCancel: (_) => _scrollController.lift(),
                          child: TextField(
                            controller: _contentController,
                            focusNode: _contentFocusNode,
                            minLines: 10,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: l10n.content,
                              hintText: l10n.composerContentHint,
                              alignLabelWithHint: true,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            enabled: !_isSubmitting,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_suggestions.isNotEmpty && _isContentFieldFocused) _suggestionStrip(),
              _toolbar(context),
            ],
          ),
        ),
      ),
    );
  }

  /// The members matching the `@name` being typed, a tap away.
  Widget _suggestionStrip() => SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.spacingS),
          itemBuilder: (_, i) => ActionChip(
            avatar: FlarumAvatar(user: _suggestions[i], radius: 12),
            label: Text(_suggestions[i].displayName),
            onPressed: () => _pickSuggestion(_suggestions[i]),
          ),
        ),
      );

  Widget _toolbar(BuildContext context) {
    final l10n = flarumL10n(context);
    final kit = kitL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _isContentFieldFocused ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);
    PopupMenuEntry<String> item(String action, IconData icon, String label) => PopupMenuItem(
          value: action,
          child: Row(
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: DesignTokens.spacingS),
              Flexible(child: Text(label)),
            ],
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow * 0.33),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingXS),
          child: Row(
            children: [
              Semantics(
                label: l10n.formatting,
                hint: l10n.composerFormattingHint,
                button: true,
                enabled: _isContentFieldFocused,
                child: PopupMenuButton<String>(
                  enabled: _isContentFieldFocused,
                  // A menu of actions: a bold glyph would read as a bold button.
                  icon: Icon(Icons.text_format, color: iconColor),
                  tooltip: l10n.formatting,
                  onSelected: _insertMarkup,
                  itemBuilder: (context) => [
                    item('B', Icons.format_bold, l10n.bold),
                    item('I', Icons.format_italic, kit.italic),
                    item('U', Icons.format_underline, l10n.underline),
                    item('S', Icons.strikethrough_s, l10n.strikethrough),
                    const PopupMenuDivider(),
                    item('URL', Icons.link, kit.link),
                    item('IMG', Icons.image, kit.image),
                    item('VIDEO', Icons.videocam, l10n.video),
                    const PopupMenuDivider(),
                    item('QUOTE', Icons.format_quote, kit.quote),
                    item('CODE', Icons.code, kit.code),
                    item('SPOILER', Icons.visibility_off, l10n.spoiler),
                    const PopupMenuDivider(),
                    item('LIST', Icons.format_list_bulleted, l10n.bulletList),
                    item('LIST=1', Icons.format_list_numbered, l10n.numberedList),
                    item('*', Icons.subdirectory_arrow_right, l10n.listItem),
                  ],
                ),
              ),
              if (_canMention)
                IconButton(
                  icon: Icon(Icons.alternate_email, color: iconColor),
                  tooltip: l10n.mentionUser,
                  onPressed: _isContentFieldFocused ? _mention : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Something the composer's caller found wrong before sending (tags that break the forum's
/// rules): shown as it is, and the page stays open.
class ComposeProblem implements Exception {
  const ComposeProblem(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The composer's scroll view, held still while a finger is on the text (from discourse_ui).
///
/// Flutter brings the keyboard up for a long-press too, and the page then scrolls the selection
/// above it while the finger is still down: the finger is over other words by then, and the
/// selection runs on to them. The page keeps still until the finger lifts, then brings the
/// selection into view.
class _HoldWhilePressedScrollController extends ScrollController {
  int _fingers = 0;

  bool get _held => _fingers > 0;

  void press() => _fingers++;

  void lift() {
    if (_fingers == 0 || --_fingers > 0) return;
    for (final position in positions) {
      (position as _HoldWhilePressedScrollPosition)._afterLift();
    }
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) =>
      _HoldWhilePressedScrollPosition(
        this,
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        oldPosition: oldPosition,
        debugLabel: debugLabel,
      );
}

class _HoldWhilePressedScrollPosition extends ScrollPositionWithSingleContext {
  _HoldWhilePressedScrollPosition(
    this._controller, {
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  final _HoldWhilePressedScrollController _controller;

  /// Where showing the selection asked to scroll while held, and from where.
  double? _heldTarget;
  double? _heldFrom;

  /// How the text field shows its caret or selection; drags and flings scroll by other means.
  @override
  Future<void> moveTo(double to, {Duration? duration, Curve? curve, bool? clamp = true}) {
    if (_controller._held) {
      _heldTarget = to;
      _heldFrom = pixels;
      return Future<void>.value();
    }
    return super.moveTo(to, duration: duration, curve: curve, clamp: clamp);
  }

  void _afterLift() {
    final target = _heldTarget;
    _heldTarget = null;
    // Not over a scroll the reader made meanwhile.
    if (target == null || _heldFrom != pixels) return;
    animateTo(target.clamp(minScrollExtent, maxScrollExtent), duration: kThemeAnimationDuration, curve: Curves.easeOut);
  }
}
