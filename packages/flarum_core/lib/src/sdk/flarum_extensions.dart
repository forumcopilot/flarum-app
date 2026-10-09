/// Which extensions a forum runs, as far as `GET /api` reveals them.
///
/// Flarum lists no extensions to members; each one shows itself through the
/// forum attributes it adds. The keys below are present on 1.8 and 2.0 alike
/// (checked on the test forums). Bundled extensions with no forum attribute
/// (likes, lock, sticky, approval, subscriptions) are taken as on: nearly every
/// forum keeps them, and the per-resource `can*` flags (`canLike`, `canLock`…)
/// decide what a reader may actually do.
class FlarumExtensions {
  const FlarumExtensions(this._attributes, {this.actorAttributes = const {}});

  final Map<String, dynamic> _attributes;

  /// The signed-in reader's own attributes, which reveal what the forum
  /// attributes don't (flarum/messages adds `messageCount` there).
  final Map<String, dynamic> actorAttributes;

  bool _has(String key) => _attributes.containsKey(key);

  bool get tags => _has('minPrimaryTags');
  bool get flags => _has('canViewFlags');
  bool get mentions => _has('allowUsernameMentionFormat');
  bool get nicknames => _has('displayNameDriver');
  bool get suspend => true; // bundled; 2.0 also sends canSuspendUsers
  bool get gdpr => _has('erasureAnonymizationAllowed');

  /// fof/byobu: private discussions, on both versions.
  bool get byobu => _has('byobu.icon-badge') || _has('canStartPrivateDiscussion');

  /// flarum/messages (2.0 only): direct messages, visible on the reader's account.
  bool get messages => actorAttributes.containsKey('messageCount');

  bool get upload => _has('fof-upload.canUpload');
  bool get followTags => _has('fofFollowTagsFollowingPageDefault');
  bool get polls => _has('canStartPolls');
  bool get reactions => _has('fofReactionsAllowAnonymous');
  bool get drafts => _has('canSaveDrafts');
  bool get bookmarks => _has('fof-bookmarks.independentButton');
  bool get bestAnswer => _has('useAlternativeBestAnswerUi');
  bool get terms => _has('fof-terms.hide-updated-at');
  bool get oauth => _has('fofOauthModerate') || _has('fof-oauth.only_icons');
}
