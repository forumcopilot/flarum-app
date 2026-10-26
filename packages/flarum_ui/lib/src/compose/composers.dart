import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../polls/poll_editor_page.dart';
import '../tags/tag_label.dart';
import 'compose_page.dart';
import '../widgets/flarum_avatar.dart';
import 'flarum_markup.dart';
import 'mention_picker_page.dart';
import 'tag_picker_page.dart';

/// Opens the composer for a reply in [discussion], starting from [initialContent] (a quote, a
/// reply to a post), or from [draft]. The reply once posted, or null.
Future<FlarumPost?> composeReply(BuildContext context, SiteContext site, FlarumDiscussion discussion,
    {String? initialContent, FlarumDraft? draft, List<FlarumUser> mentionable = const []}) {
  final forum = FlarumForum.of(site);
  return Navigator.of(context).push(MaterialPageRoute<FlarumPost>(
    fullscreenDialog: true,
    builder: (context) => ComposePage(
      site: site,
      title: kitL10n(context).reply,
      topicTitle: discussion.title,
      initialContent: draft?.content ?? initialContent,
      mentionable: mentionable,
      onSubmit: (_, content) async {
        final post = await forum.api.reply(discussion.id, content);
        _posted(forum, draft);
        return post;
      },
      onSaveDraft: canSaveDrafts(forum)
          ? (_, content) => _saveDraft(
              context, forum, () => forum.api.saveDraft(id: draft?.id, content: content, discussionId: discussion.id))
          : null,
    ),
  ));
}

/// Whether the reader may keep drafts (fof/drafts).
bool canSaveDrafts(FlarumForum forum) => forum.isSignedIn && (forum.info?.can('canSaveDrafts') ?? false);

/// Opens [draft] in the composer it was written in. What it posted (a reply or a discussion), or
/// null. Throws when a reply's discussion can't be read.
Future<Object?> resumeDraft(BuildContext context, SiteContext site, FlarumDraft draft) async {
  if (draft.discussionId case final id?) {
    final discussion = await FlarumForum.of(site).api.discussion(id);
    if (!context.mounted) return null;
    return composeReply(context, site, discussion, draft: draft);
  }
  return Navigator.of(context).push(MaterialPageRoute<FlarumDiscussion>(
    fullscreenDialog: true,
    builder: (_) => draft.isPrivateDiscussion
        ? _NewPrivateDiscussionPage(site: site, draft: draft)
        : _NewDiscussionPage(site: site, draft: draft),
  ));
}

/// Saves a draft with [save], says so, and has the reader's draft count read again.
Future<void> _saveDraft(BuildContext context, FlarumForum forum, Future<FlarumDraft> Function() save,
    {bool withoutPoll = false}) async {
  await save();
  forum.refresh().ignore();
  if (context.mounted) {
    final l10n = flarumL10n(context);
    SnackbarHelper.showInfo(context, withoutPoll ? l10n.draftSavedWithoutPoll : l10n.draftSaved);
  }
}

/// What [draft] held is posted: nothing on the forum deletes it.
void _posted(FlarumForum forum, FlarumDraft? draft) {
  if (draft == null) return;
  () async {
    try {
      await forum.api.deleteDraft(draft.id);
      await forum.refresh();
    } catch (_) {
      // It stays in the reader's drafts, to delete by hand.
    }
  }();
}

/// Opens the composer on [post]'s source, to edit it. The post as saved, or null. Flarum sends
/// the source only to readers who may edit, so a post read without it is fetched again.
Future<FlarumPost?> composeEdit(BuildContext context, SiteContext site, FlarumPost post) async {
  final forum = FlarumForum.of(site);
  var source = post.source;
  if (source == null) {
    try {
      source = (await forum.api.post(post.id)).source;
    } catch (_) {
      source = null;
    }
    if (!context.mounted) return null;
    if (source == null) {
      SnackbarHelper.showError(context, flarumL10n(context).editLoadFailed);
      return null;
    }
  }
  return Navigator.of(context).push(MaterialPageRoute<FlarumPost>(
    fullscreenDialog: true,
    builder: (context) => ComposePage(
      site: site,
      title: flarumL10n(context).editPost,
      initialContent: source,
      isEdit: true,
      onSubmit: (_, content) => forum.api.editPost(post.id, content),
    ),
  ));
}

/// Opens the composer for a new discussion, in [tag] when given. The discussion once started,
/// or null.
Future<FlarumDiscussion?> composeDiscussion(BuildContext context, SiteContext site, {FlarumTag? tag}) =>
    Navigator.of(context).push(MaterialPageRoute<FlarumDiscussion>(
      fullscreenDialog: true,
      builder: (_) => _NewDiscussionPage(site: site, tag: tag),
    ));

/// Opens the composer for a private discussion (fof/byobu), with [to] when given. The discussion
/// once started, or null.
Future<FlarumDiscussion?> composePrivateDiscussion(BuildContext context, SiteContext site, {FlarumUser? to}) =>
    Navigator.of(context).push(MaterialPageRoute<FlarumDiscussion>(
      fullscreenDialog: true,
      builder: (_) => _NewPrivateDiscussionPage(site: site, to: to),
    ));

/// A reply to [post], as the web's Reply button on a post starts one.
String replyTo(FlarumPost post, FlarumLocalizations l10n) =>
    '${FlarumMarkup.postMention(post.author?.displayName ?? l10n.someone, post.id)} ';

/// A quote of [post], as the web's Quote button writes it: from its source when the reader has
/// it, else its words, leaving out what it quotes itself.
String quoteOf(FlarumPost post, FlarumLocalizations l10n) {
  final text = post.source ??
      plainText((post.contentHtml ?? '').replaceAll(RegExp(r'<blockquote[\s\S]*?</blockquote>', caseSensitive: false), ''));
  return FlarumMarkup.quote(post.author?.displayName ?? l10n.someone, post.id, text);
}

/// The new-discussion composer: the title, the text, the tags the forum's rules ask for, and a
/// poll where the reader may start one (fof/polls).
class _NewDiscussionPage extends StatefulWidget {
  const _NewDiscussionPage({required this.site, this.tag, this.draft});

  final SiteContext site;
  final FlarumTag? tag;

  /// The draft it resumes.
  final FlarumDraft? draft;

  @override
  State<_NewDiscussionPage> createState() => _NewDiscussionPageState();
}

class _NewDiscussionPageState extends State<_NewDiscussionPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  List<FlarumTag>? _tags;
  late List<FlarumTag> _chosen = [
    if (widget.tag case final tag?) tag,
  ];

  FlarumNewPoll? _poll;

  /// Set once the writer picks tags or adds, changes or removes the poll.
  final _touched = ValueNotifier(false);

  @override
  void dispose() {
    _touched.dispose();
    super.dispose();
  }

  /// Without flarum/tags the forum has no tags to choose.
  bool get _usesTags => _forum.info?.tagRules != null;

  bool get _canStartPolls => _forum.info?.can('canStartPolls') ?? false;

  @override
  void initState() {
    super.initState();
    if (_usesTags) {
      _forum.tags().then((tags) {
        if (!mounted) return;
        setState(() {
          _tags = tags;
          if (widget.draft case final draft?) {
            _chosen = [...tags.where((t) => draft.tagIds.contains(t.id))];
            return;
          }
          // A child tag goes with its parent.
          final parent = widget.tag?.parentId;
          if (parent != null) _chosen = [...tags.where((t) => t.id == parent), ..._chosen];
        });
      }, onError: (_) {});
    }
  }

  Future<void> _chooseTags() async {
    final tags = _tags;
    if (tags == null) return;
    final chosen = await TagPickerPage.open(context, tags: tags, rules: _forum.info?.tagRules, selected: _chosen);
    if (chosen != null && mounted) {
      setState(() => _chosen = chosen);
      _touched.value = true;
    }
  }

  Future<void> _editPoll() async {
    final poll = await PollEditorPage.open(
      context,
      maxOptions: _forum.info?.pollMaxOptions ?? 10,
      poll: _poll,
      limitsChoices: _forum.info?.version == FlarumVersion.v2,
    );
    if (poll != null && mounted) {
      setState(() => _poll = poll);
      _touched.value = true;
    }
  }

  Future<FlarumDiscussion> _start(String title, String content) async {
    final problem = _usesTags ? tagRuleProblem(_chosen, _forum.info?.tagRules, flarumL10n(context)) : null;
    if (problem != null) throw ComposeProblem(problem);
    final discussion =
        await _forum.api.startDiscussion(title, content, tagIds: [for (final tag in _chosen) tag.id], poll: _poll);
    _posted(_forum, widget.draft);
    return discussion;
  }

  /// A draft keeps the title, text and tags; fof/drafts has no place for a poll.
  Future<void> _saveAsDraft(String title, String content) => _saveDraft(
        context,
        _forum,
        () => _forum.api.saveDraft(
            id: widget.draft?.id, title: title, content: content, tagIds: [for (final tag in _chosen) tag.id]),
        withoutPoll: _poll != null,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final poll = _poll;
    return ComposePage(
      site: widget.site,
      title: l10n.startDiscussion,
      showTitleField: true,
      otherChanges: _touched,
      initialTitle: widget.draft?.title,
      initialContent: widget.draft?.content,
      header: _usesTags || _canStartPolls
          ? Wrap(
              spacing: DesignTokens.spacingS,
              runSpacing: DesignTokens.spacingXS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_usesTags) ...[
                  for (final tag in tagsInWebOrder(_chosen)) TagLabel(tag: tag),
                  ActionChip(
                    avatar: const Icon(Icons.sell_outlined, size: 18),
                    label: Text(l10n.chooseTags),
                    onPressed: _tags == null ? null : _chooseTags,
                  ),
                ],
                if (_canStartPolls)
                  poll == null
                      ? ActionChip(
                          avatar: const Icon(Icons.poll_outlined, size: 18),
                          label: Text(l10n.addPoll),
                          onPressed: _editPoll,
                        )
                      : InputChip(
                          avatar: const Icon(Icons.poll, size: 18),
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(poll.question, overflow: TextOverflow.ellipsis),
                          ),
                          tooltip: l10n.editPoll,
                          onPressed: _editPoll,
                          deleteButtonTooltipMessage: l10n.removePoll,
                          onDeleted: () {
                            setState(() => _poll = null);
                            _touched.value = true;
                          },
                        ),
              ],
            )
          : null,
      onSubmit: _start,
      onSaveDraft: canSaveDrafts(_forum) ? _saveAsDraft : null,
    );
  }
}

/// The private-discussion composer: who it's with, the title and the text. No tags: byobu lets a
/// private discussion go without.
class _NewPrivateDiscussionPage extends StatefulWidget {
  const _NewPrivateDiscussionPage({required this.site, this.to, this.draft});

  final SiteContext site;
  final FlarumUser? to;

  /// The draft it resumes, whose people are read again by their ids.
  final FlarumDraft? draft;

  @override
  State<_NewPrivateDiscussionPage> createState() => _NewPrivateDiscussionPageState();
}

class _NewPrivateDiscussionPageState extends State<_NewPrivateDiscussionPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final List<FlarumUser> _people = [if (widget.to case final to?) to];

  /// Set once the writer adds or removes someone.
  final _touched = ValueNotifier(false);

  @override
  void dispose() {
    _touched.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (final id in widget.draft?.recipientIds ?? const <String>[]) {
      _forum.api.user(id).then((user) {
        if (mounted && !_people.any((p) => p.id == user.id)) setState(() => _people.add(user));
      }, onError: (_) {});
    }
  }

  /// Members may have only one other person in a private discussion, unless the forum lets them
  /// add more (byobu counts the reader as one of two).
  bool get _onlyOne => !(_forum.info?.can('canAddMoreThanTwoUserRecipients') ?? false);

  Future<void> _add() async {
    if (_onlyOne && _people.isNotEmpty) {
      SnackbarHelper.showInfo(context, flarumL10n(context).privateOnlyOne);
      return;
    }
    final user = await MentionPickerPage.open(context, widget.site);
    if (user == null || !mounted || user.id == _forum.info?.actor?.id || _people.any((p) => p.id == user.id)) return;
    setState(() => _people.add(user));
    _touched.value = true;
  }

  Future<FlarumDiscussion> _start(String title, String content) async {
    if (_people.isEmpty) throw ComposeProblem(flarumL10n(context).choosePerson);
    final discussion = await _forum.api.startPrivateDiscussion(title, content, [for (final user in _people) user.id]);
    _posted(_forum, widget.draft);
    return discussion;
  }

  Future<void> _saveAsDraft(String title, String content) => _saveDraft(
        context,
        _forum,
        () => _forum.api.saveDraft(
            id: widget.draft?.id, title: title, content: content, recipientIds: [for (final user in _people) user.id]),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return ComposePage(
      site: widget.site,
      title: l10n.startPrivateDiscussion,
      showTitleField: true,
      submitLabel: l10n.composerSend,
      otherChanges: _touched,
      titleHint: l10n.privateDiscussionTitleHint,
      initialTitle: widget.draft?.title,
      initialContent: widget.draft?.content,
      header: Wrap(
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingXS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final user in _people)
            InputChip(
              avatar: FlarumAvatar(user: user, radius: 12),
              label: Text(user.displayName),
              onDeleted: () {
                setState(() => _people.remove(user));
                _touched.value = true;
              },
            ),
          ActionChip(
            avatar: const Icon(Icons.person_add_alt, size: 18),
            label: Text(l10n.addPerson),
            onPressed: _add,
          ),
        ],
      ),
      onSubmit: _start,
      onSaveDraft: canSaveDrafts(_forum) ? _saveAsDraft : null,
    );
  }
}
