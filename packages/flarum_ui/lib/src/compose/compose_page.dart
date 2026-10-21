import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/emoji_shortcodes.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/file_picker_utils.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../l10n/flarum_l10n.dart';
import 'discard_changes_scope.dart';
import '../render/file_kind.dart';
import '../widgets/flarum_avatar.dart';
import 'flarum_markup.dart';
import 'mention_picker_page.dart';
import 'upload_tile.dart';
import 'uploads.dart';

/// A full-screen composer: an optional title, the post's text with a formatting toolbar,
/// @-mentions and uploads, and Send (Save for an edit).
///
/// Copied from discourse_ui's MessageComposePage and adapted, as decided on 9 October 2026:
/// Flarum's markup ([FlarumMarkup]), its mention format, its refusals (the posting throttle, a
/// 2.0 forum's reason per field), and fof/upload's files, each in the text as its BBCode.
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
    this.pickFiles = pickUploads,
    this.onSaveDraft,
    this.submitLabel,
    this.titleHint,
    this.contentHint,
    this.otherChanges,
    this.mentionable = const [],
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

  /// Picks the files to upload: the phone's pickers ([pickUploads]), or a test's.
  final Future<List<XFile>> Function(UploadSource source) pickFiles;

  /// Keeps what was written as a draft (fof/drafts), offered with Discard when the writer closes
  /// the page; null where the reader can't save drafts. A throw keeps the page open, with the
  /// reason shown.
  final Future<void> Function(String title, String content)? onSaveDraft;

  /// The submit button and the fields' placeholders, in Flarum's words. By default: Save Changes
  /// for an edit, Post Discussion with a title field, Post Reply without; Discussion Title, and
  /// Write a Post... or Write a Reply....
  final String? submitLabel;
  final String? titleHint;
  final String? contentHint;

  /// Whether the writer changed something the page doesn't hold itself: a new discussion's tags
  /// and poll, a private one's people. Closing then asks too, as it does for the text.
  final ValueListenable<bool>? otherChanges;

  /// The discussion's people, its latest posters first (the reader left out): what `@` offers
  /// before anything is typed, as flarum/mentions suggests the people already in a discussion.
  final List<FlarumUser> mentionable;

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

  /// Send found the field empty: it says so under it until the reader writes in it.
  bool _titleMissing = false;
  bool _contentMissing = false;

  /// Members matching the `@name` being typed, offered above the toolbar.
  List<FlarumUser> _suggestions = const [];
  Timer? _suggestTimer;
  int _suggestSearches = 0;

  /// The files picked for this post, uploading or uploaded, in the order picked.
  final List<_PendingUpload> _uploads = [];
  late final _uploader = ComposerUploader(FlarumForum.of(widget.site));

  /// What the composer opened with, for [_hasChanges].
  late final String _openedTitle = _titleController.text;
  late final String _openedContent = _contentController.text;

  bool _hasChanges() =>
      _titleController.text != _openedTitle ||
      _contentController.text != _openedContent ||
      (widget.otherChanges?.value ?? false);

  /// Whether the toolbar offers @-mentions: they need the forum's search-users permission.
  bool get _canMention => FlarumForum.of(widget.site).info?.can('canSearchUsers') ?? false;

  /// Whether the toolbar offers uploads: the forum runs fof/upload and lets the reader upload.
  bool get _canUpload => FlarumForum.of(widget.site).info?.can('fof-upload.canUpload') ?? false;

  @override
  void initState() {
    super.initState();
    _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      (widget.showTitleField && _titleController.text.isEmpty ? _titleFocusNode : _contentFocusNode).requestFocus();
    });
    _contentFocusNode.addListener(() => setState(() => _isContentFieldFocused = _contentFocusNode.hasFocus));
    // Written in, by the reader or an upload's BBCode: no longer missing.
    _titleController.addListener(() {
      if (_titleMissing && _titleController.text.trim().isNotEmpty) setState(() => _titleMissing = false);
    });
    _contentController.addListener(() {
      if (_contentMissing && _contentController.text.trim().isNotEmpty) setState(() => _contentMissing = false);
    });
    _contentController.addListener(_contentChanged);
    _contentController.addListener(_dropUploadsTakenOutOfText);
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

  /// The `@name` typed just before the cursor (nothing yet, just after `@`), as the web's mention
  /// autocomplete reads it.
  ({int start, String query})? _mentionAtCursor() {
    final value = _contentController.value;
    final cursor = value.selection.baseOffset;
    if (!value.selection.isCollapsed || cursor < 0 || cursor > value.text.length) return null;
    final typed = RegExp(r'(?:^|[\s(])@([^\s@"#]{0,30})$').firstMatch(value.text.substring(0, cursor));
    if (typed == null) return null;
    final query = typed.group(1)!;
    return (start: cursor - query.length - 1, query: query);
  }

  /// The discussion's people whose name starts with [query] (any of them for none).
  List<FlarumUser> _localMatches(String query) {
    final q = query.toLowerCase();
    return [
      for (final user in widget.mentionable)
        if (q.isEmpty || user.displayName.toLowerCase().startsWith(q) || user.username.toLowerCase().startsWith(q)) user,
    ];
  }

  void _contentChanged() {
    if (!_canMention && widget.mentionable.isEmpty) return;
    _suggestTimer?.cancel();
    final typing = _mentionAtCursor();
    if (typing == null) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    // The discussion's own people at once; the forum's members from the second letter.
    final local = _localMatches(typing.query).take(5).toList();
    if (local.isNotEmpty || typing.query.length < 2) setState(() => _suggestions = local);
    if (_canMention && typing.query.length >= 2) {
      _suggestTimer = Timer(const Duration(milliseconds: 250), () => _suggest(typing.query));
    }
  }

  Future<void> _suggest(String query) async {
    final search = ++_suggestSearches;
    try {
      final page = await FlarumForum.of(widget.site).api.searchUsers(query);
      if (!mounted || search != _suggestSearches || _mentionAtCursor()?.query != query) return;
      final local = _localMatches(query);
      final known = {for (final user in local) user.id};
      setState(() => _suggestions = [...local, ...page.items.where((user) => !known.contains(user.id))].take(5).toList());
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

  Future<void> _pick(UploadSource source) async {
    final files = await widget.pickFiles(source);
    if (files.isNotEmpty && mounted) await _uploadAll(files);
  }

  /// Where an upload goes in the text: a line of its own at the cursor, as the web composer
  /// places it, or at the end when the field has no cursor.
  void _insertOnOwnLine(String line) {
    final value = _contentController.value;
    final body = value.text;
    final sel = value.selection;
    final start = sel.isValid ? sel.start.clamp(0, body.length) : body.length;
    final end = sel.isValid ? sel.end.clamp(start, body.length) : body.length;
    final before = body.substring(0, start);
    final after = body.substring(end);
    final inserted = '${before.isEmpty || before.endsWith('\n') ? '' : '\n'}$line${after.startsWith('\n') ? '' : '\n'}';
    _contentController.value = TextEditingValue(
      text: before + inserted + after,
      selection: TextSelection.collapsed(offset: before.length + inserted.length),
    );
  }

  /// Replaces the first [from] in the text with [to]; with nothing, taking its line break along.
  /// Returns whether it was there.
  bool _replaceInText(String from, String to) {
    final text = _contentController.text;
    final i = text.indexOf(from);
    if (i < 0) return false;
    var end = i + from.length;
    if (to.isEmpty && end < text.length && text[end] == '\n') end++;
    final updated = text.replaceRange(i, end, to);
    final sel = _contentController.selection;
    var offset = sel.isValid ? sel.baseOffset : updated.length;
    if (offset >= end) {
      offset += to.length - (end - i);
    } else if (offset > i) {
      offset = i + to.length;
    }
    _contentController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: offset.clamp(0, updated.length)),
    );
    return true;
  }

  /// The web's placeholder, `[Uploading: name…]()`, unique in the text.
  String _placeholderFor(String name) {
    final l10n = flarumL10n(context);
    var label = name;
    for (var n = 2;; n++) {
      final placeholder = '[${l10n.uploadingFilename(label)}]()';
      if (!_contentController.text.contains(placeholder) && !_uploads.any((u) => u.placeholder == placeholder)) {
        return placeholder;
      }
      label = '$name ($n)';
    }
  }

  /// Puts [files] in the text and the strip at once, then uploads them one by one. Each starts as
  /// the web's placeholder on its own line at the cursor and becomes its BBCode when it lands (an
  /// image shown in the post, a download card for any other file); a failure takes the
  /// placeholder out again and says why.
  Future<void> _uploadAll(List<XFile> files) async {
    final l10n = flarumL10n(context);
    final added = <_PendingUpload>[];
    for (final file in files) {
      // Unique against the ones already made for this batch too.
      final upload = _PendingUpload(file, _placeholderFor(file.name));
      _uploads.add(upload);
      added.add(upload);
    }
    for (final upload in added) {
      _insertOnOwnLine(upload.placeholder);
    }
    setState(() {});

    for (final upload in added) {
      if (!mounted) return;
      if (!_uploads.contains(upload)) continue; // removed while waiting
      FlarumUpload? done;
      Object? error;
      try {
        done = await _uploader.upload(upload.file,
            onResized: (r) => _showNotice(
                l10n.imageResizedToFitLimit(r.name, formatFileSize(r.bytes), r.dimensions, formatFileSize(r.limit))));
      } catch (e) {
        error = e;
      }
      if (!mounted) return;
      if (!_uploads.contains(upload)) {
        // Removed while it uploaded.
        if (done != null) _deleteFromForum(done);
        continue;
      }
      if (done == null) {
        setState(() => _uploads.remove(upload));
        _replaceInText(upload.placeholder, '');
        SnackbarHelper.showError(context, switch (error) {
          UploadTooLarge(:final name, :final bytes, :final limit, couldNotResize: true) =>
            l10n.imageTooLargeCouldNotResize(name, formatFileSize(bytes), formatFileSize(limit)),
          UploadTooLarge(:final name, :final bytes, :final limit) =>
            l10n.fileTooLargeForForum(name, formatFileSize(bytes), formatFileSize(limit)),
          // fof/upload's reasons (a type the forum doesn't take, say), or why it couldn't answer.
          _ => l10n.failedToUploadFile2(describeError(context, error)),
        });
        continue;
      }
      if (!_replaceInText(upload.placeholder, done.bbcode)) {
        // The placeholder was deleted meanwhile: the writer took it out.
        setState(() => _uploads.remove(upload));
        _deleteFromForum(done);
        continue;
      }
      setState(() => upload.done = done);
    }
  }

  /// Takes [upload] out of the post: its tile, and its line in the text.
  void _removeUpload(_PendingUpload upload) {
    // Out of the list first, so the text listener does not drop it again.
    setState(() => _uploads.remove(upload));
    _replaceInText(upload.done?.bbcode ?? upload.placeholder, '');
    if (upload.done case final done?) _deleteFromForum(done);
  }

  /// Deletes a file taken out of the post from the forum too, where the reader may: fof/upload
  /// lets only moderators by default, so a member's stays, in no post.
  void _deleteFromForum(FlarumUpload upload) {
    if (upload.canDelete) FlarumForum.of(widget.site).api.deleteUpload(upload.uuid).ignore();
  }

  /// An upload whose BBCode the writer deleted is out of the post: its tile goes too.
  void _dropUploadsTakenOutOfText() {
    final text = _contentController.text;
    final gone = [
      for (final u in _uploads)
        if (u.done case final done? when !text.contains(done.uuid)) u,
    ];
    if (gone.isNotEmpty) setState(() => _uploads.removeWhere(gone.contains));
  }

  void _showNotice(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit() async {
    final l10n = flarumL10n(context);
    // An upload still on its way is a placeholder in the text, not its BBCode.
    if (_uploads.any((u) => u.isUploading)) {
      _showNotice(l10n.pleaseWaitForAttachmentsToFinishUploading);
      return;
    }
    final titleMissing = widget.showTitleField && _titleController.text.trim().isEmpty;
    final contentMissing = _contentController.text.trim().isEmpty;
    if (titleMissing || contentMissing) {
      setState(() {
        _titleMissing = titleMissing;
        _contentMissing = contentMissing;
      });
      (titleMissing ? _titleFocusNode : _contentFocusNode).requestFocus();
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
        _ => describeError(context, e),
      });
    }
  }

  Future<void> _saveDraft() async {
    final l10n = flarumL10n(context);
    // Placeholders aren't worth keeping, and the forum refuses a draft without text.
    if (_uploads.any((u) => u.isUploading)) throw ComposeProblem(l10n.pleaseWaitForAttachmentsToFinishUploading);
    if (_contentController.text.trim().isEmpty) throw ComposeProblem(l10n.draftNeedsText);
    await widget.onSaveDraft!(_titleController.text.trim(), _contentController.text.trim());
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
      listenable: Listenable.merge([_titleController, _contentController, widget.otherChanges]),
      hasChanges: _hasChanges,
      // Flarum's question for what's being written.
      question: widget.isEdit
          ? flarumL10n(context).discardEditQuestion
          : widget.showTitleField
              ? flarumL10n(context).discardDiscussionQuestion
              : flarumL10n(context).discardReplyQuestion,
      busy: _isSubmitting,
      onSaveDraft: widget.onSaveDraft == null ? null : _saveDraft,
      describeFailure: (error, context) => error is ComposeProblem ? error.message : describeError(context, error),
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
                    // Flarum's labels are long ("Post Private Discussion"): at a large text size
                    // the label shrinks to fit half the bar rather than push the title off it.
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.submitLabel ??
                              (widget.isEdit
                                  ? l10n.save
                                  : widget.showTitleField
                                      ? l10n.postDiscussion
                                      : l10n.postReply)),
                        ),
                      ),
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
                            decoration: InputDecoration(
                              labelText: l10n.title,
                              hintText: widget.titleHint ?? l10n.composerTitleHint,
                              errorText: _titleMissing ? l10n.pleaseEnterTitle : null,
                            ),
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
                              hintText: widget.contentHint ??
                                  (widget.showTitleField ? l10n.composerContentHint : l10n.composerReplyHint),
                              alignLabelWithHint: true,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              errorText: _contentMissing ? l10n.pleaseEnterContent : null,
                            ),
                            enabled: !_isSubmitting,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_uploads.isNotEmpty) _uploadStrip(),
              if (_suggestions.isNotEmpty && _isContentFieldFocused) _suggestionStrip(),
              _toolbar(context),
            ],
          ),
        ),
      ),
    );
  }

  /// This post's uploads, as tiles above the toolbar: what each is, its progress, and a remove
  /// button. The text holds where each goes.
  Widget _uploadStrip() => SizedBox(
        height: UploadTile.extent + DesignTokens.spacingS,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
          itemCount: _uploads.length,
          // The badge's room is the gap.
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (_, i) => UploadTile(
            key: ObjectKey(_uploads[i]),
            fileName: _uploads[i].file.name,
            path: _uploads[i].file.path,
            uploading: _uploads[i].isUploading,
            onRemove: _isSubmitting ? null : () => _removeUpload(_uploads[i]),
          ),
        ),
      );

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
    // While the text isn't being edited, the formats wait (they act at its cursor).
    Widget format(String action, IconData icon, String tooltip) => IconButton(
          icon: Icon(icon, color: iconColor),
          tooltip: tooltip,
          onPressed: _isContentFieldFocused ? () => _insertMarkup(action) : null,
        );
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
          // One row that scrolls sideways, as the website's composer bar: the common formats one
          // tap away, the rest under Formatting; then mentions and uploads.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                format('B', Icons.format_bold, l10n.addBold),
                format('I', Icons.format_italic, l10n.addItalic),
                format('QUOTE', Icons.format_quote, l10n.insertQuote),
                format('URL', Icons.link, l10n.addLink),
                format('LIST', Icons.format_list_bulleted, l10n.addBulletedList),
                format('CODE', Icons.code, l10n.insertCode),
                Semantics(
                  label: l10n.formatting,
                  hint: l10n.composerFormattingHint,
                  button: true,
                  enabled: _isContentFieldFocused,
                  child: PopupMenuButton<String>(
                    enabled: _isContentFieldFocused,
                    icon: Icon(Icons.more_horiz, color: iconColor),
                    tooltip: l10n.formatting,
                    onSelected: _insertMarkup,
                    itemBuilder: (context) => [
                      item('U', Icons.format_underline, l10n.underline),
                      item('S', Icons.strikethrough_s, l10n.strikethrough),
                      item('SPOILER', Icons.visibility_off, l10n.spoiler),
                      const PopupMenuDivider(),
                      item('IMG', Icons.image, kit.image),
                      item('VIDEO', Icons.videocam, l10n.video),
                      const PopupMenuDivider(),
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
                // Uploads go at the cursor, or at the end: they don't wait for the text's focus.
                if (_canUpload) ...[
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate_outlined, color: colorScheme.onSurfaceVariant),
                    tooltip: l10n.uploadImage,
                    onPressed: _isSubmitting ? null : () => _pick(UploadSource.photos),
                  ),
                  if (FilePickerUtils.canTakePhoto)
                    IconButton(
                      icon: Icon(Icons.photo_camera_outlined, color: colorScheme.onSurfaceVariant),
                      tooltip: l10n.takePhoto,
                      onPressed: _isSubmitting ? null : () => _pick(UploadSource.camera),
                    ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: colorScheme.onSurfaceVariant),
                    tooltip: l10n.attachFile,
                    onPressed: _isSubmitting ? null : () => _pick(UploadSource.files),
                  ),
                ],
              ],
            ),
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

/// A file picked for the post: its placeholder in the text until it lands, then its upload.
class _PendingUpload {
  _PendingUpload(this.file, this.placeholder);

  final XFile file;
  final String placeholder;
  FlarumUpload? done;

  bool get isUploading => done == null;
}
