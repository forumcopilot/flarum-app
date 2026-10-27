import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/profile/profile_common.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';
import 'forum_web_page.dart';

/// The reader's profile, as the Discourse app's Edit Profile: their picture with a button to change
/// it, then a row for each thing the forum lets them change, showing what is set. Tapping one
/// changes just that, saved as it's made (there is no page-wide Save), with Undo where it can be put
/// back. A row the forum keeps from the reader (the username, admins' alone) shows a lock.
///
/// Flarum keeps the email and password behind the reader's own password: those stay on the forum's
/// settings page, a link at the foot.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EditProfilePage(site: site)));

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);

  /// The reader as the forum last answered (a save answers with them).
  late FlarumUser? _user = _forum.info?.actor;
  bool _uploading = false;

  /// Shows [user] as saved, and reads the forum again, which the rest of the app (the drawer, the
  /// Profile tab) shows the reader from.
  void _saved(FlarumUser user) {
    setState(() => _user = user);
    _forum.refresh().ignore();
  }

  Future<void> _changePicture() async {
    final l10n = flarumL10n(context);
    final user = _user!;
    final choice = await showProfileSheet<_Picture>(
      context: context,
      title: l10n.profilePicture,
      children: (sheet) => [
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(l10n.takePhoto),
          onTap: () => Navigator.of(sheet).pop(_Picture.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(l10n.chooseFromLibrary),
          onTap: () => Navigator.of(sheet).pop(_Picture.library),
        ),
        if (user.avatarUrl != null)
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(sheet).colorScheme.error),
            title: Text(l10n.removeProfilePicture, style: TextStyle(color: Theme.of(sheet).colorScheme.error)),
            onTap: () => Navigator.of(sheet).pop(_Picture.remove),
          ),
      ],
    );
    if (choice == null || !mounted) return;
    if (choice == _Picture.remove) {
      await _send(() => _forum.api.removeAvatar(user.id), done: l10n.profilePictureRemoved);
      return;
    }
    final photo = await pickProfilePhoto(choice == _Picture.camera ? ImageSource.camera : ImageSource.gallery);
    if (photo == null || !mounted) return;
    await _send(
      () => _forum.api.uploadAvatar(user.id, FlarumApi.fileFromBytes(photo.bytes, name: 'avatar.${photo.extension}')),
      done: l10n.profilePictureUpdated,
    );
  }

  /// Sends a change of picture, with the picture's spinner while it goes.
  Future<void> _send(Future<FlarumUser> Function() change, {required String done}) async {
    setState(() => _uploading = true);
    try {
      final user = await change();
      if (!mounted) return;
      _saved(user);
      SnackbarHelper.showInfo(context, done);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _changeDisplayName() async {
    final l10n = flarumL10n(context);
    final user = _user!;
    final previous = user.displayName == user.username ? null : user.displayName;
    final saved = await showDialog<FlarumUser>(
      context: context,
      builder: (_) => _DisplayNameDialog(
        initial: previous ?? '',
        username: user.username,
        save: (name) => _forum.api.setNickname(user, name.trim().isEmpty ? null : name.trim()),
      ),
    );
    if (saved == null || !mounted) return;
    _saved(saved);
    SnackbarHelper.showInfo(
      context,
      l10n.displayNameSaved,
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () async {
          try {
            final back = await _forum.api.setNickname(saved, previous);
            if (mounted) _saved(back);
          } catch (e) {
            if (mounted) SnackbarHelper.showError(context, describeError(context, e));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final user = _user;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
              children: [
                _PictureHeader(user: user, uploading: _uploading, onChange: _changePicture),
                _ProfileRow(
                  label: l10n.displayName,
                  value: user.displayName,
                  locked: !user.canEditNickname,
                  lockedReason: l10n.displayNameLocked,
                  onTap: _changeDisplayName,
                ),
                _ProfileRow(
                  label: l10n.usernameField,
                  value: '@${user.username}',
                  // Admins change it on the forum's settings page, with the rest of their account.
                  locked: !user.canEditCredentials,
                  lockedReason: l10n.usernameAdminsOnly,
                  onTap: () => _openSettings(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => _openSettings(context),
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: Text(l10n.forumSettingsPage),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _openSettings(BuildContext context) =>
      ForumWebPage.open(context, widget.site, path: '/settings', title: flarumL10n(context).settings);
}

/// What the picture sheet offers.
enum _Picture { camera, library, remove }

/// The reader's picture, large, with a button over its edge to change it.
class _PictureHeader extends StatelessWidget {
  const _PictureHeader({required this.user, required this.uploading, required this.onChange});

  final FlarumUser user;
  final bool uploading;
  final VoidCallback onChange;

  static const double _radius = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingL),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FlarumAvatar(user: user, radius: _radius),
            if (uploading)
              Container(
                width: _radius * 2,
                height: _radius * 2,
                decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.5), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: DesignTokens.iconSizeL,
                  height: DesignTokens.iconSizeL,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Positioned(
              right: -6,
              bottom: -6,
              child: IconButton.filled(
                tooltip: l10n.changeProfilePicture,
                onPressed: uploading ? null : onChange,
                icon: const Icon(Icons.photo_camera_outlined, size: DesignTokens.iconSizeSMedium),
                style: IconButton.styleFrom(side: BorderSide(color: colorScheme.surface, width: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row: a label, what is set, and a chevron, or a lock where the forum doesn't let the reader
/// change it (a tap then says why).
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.locked = false,
    this.lockedReason,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool locked;
  final String? lockedReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.45),
            child: Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: DesignTokens.spacingS),
          locked
              ? Icon(Icons.lock_outline, size: DesignTokens.iconSizeM, color: muted, semanticLabel: lockedReason)
              : Icon(Icons.chevron_right, color: muted),
        ],
      ),
      onTap: locked ? () => SnackbarHelper.showInfo(context, lockedReason ?? '') : onTap,
    );
  }
}

/// The display name in a dialog: the forum's refusal (too long, taken, characters it doesn't
/// allow) shows under the field, which keeps what was typed.
class _DisplayNameDialog extends StatefulWidget {
  const _DisplayNameDialog({required this.initial, required this.username, required this.save});

  final String initial;
  final String username;
  final Future<FlarumUser> Function(String name) save;

  @override
  State<_DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<_DisplayNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await widget.save(_controller.text);
      if (mounted) Navigator.of(context).pop(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = describeError(context, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return AlertDialog(
      title: Text(l10n.displayName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_saving,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: widget.username,
          helperText: l10n.displayNameHelper('@${widget.username}'),
          helperMaxLines: 3,
          errorText: _error,
          errorMaxLines: 4,
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(kitL10n(context).cancel)),
        TextButton(onPressed: _saving ? null : _submit, child: Text(l10n.save)),
      ],
    );
  }
}
