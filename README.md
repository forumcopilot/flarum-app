# flarum-app

A native Flutter app for [Flarum](https://flarum.org) forums. It supports Flarum 1.8 and 2.0 and
needs no plugin on the forum. It is built on the same stack as
[discourse-app](https://github.com/forumcopilot/discourse-app), and its screens follow that
app's Material 3 layout.

One build is one forum's app: fork it, name your forum, and build it for Android and iOS. The same
screens also run inside a multi-forum app (Flapp), which hosts them as described in
`docs/phase-4-notes.md`.

## What it does

- **Reading:** the forum's discussions with Latest, Top, Newest and Oldest views, and its tags
  (subforums), shown as cards with child tags. A discussion opens at the reader's last read post,
  with a scrubber, replies and Flarum's event posts. The app also covers search, profiles with
  member cards, and notifications.
- **Writing:** start a discussion with the forum's tag rules, reply, quote and edit.
  - The composer has formatting, @mentions suggested from the discussion's people, uploads
    (fof/upload), polls (fof/polls) and drafts (fof/drafts).
- **Taking part:**
  - Likes and reactions (fof/reactions), with who liked and reacted.
  - Best answers (fof/best-answer).
  - Following discussions and tags (fof/follow-tags), and bookmarks (fof/bookmarks).
  - Private discussions (fof/byobu), and direct messages (flarum/messages, 2.0).
- **Safety and moderation:**
  - Reporting, ignoring members (fof/ignore-users), and accepting the forum's terms (fof/terms).
  - Approving, locking, pinning, hiding and suspending, for moderators.
- **Account:**
  - Sign-in through the forum's own page, so CAPTCHAs and OAuth providers work.
  - Sign-out that revokes the token.
  - A Profile tab with Edit Profile (picture and display name) and notification settings.
- **Push:** on forums that run the optional Flapp extension
  ([forumcopilot/flarum-flapp](https://github.com/forumcopilot/flarum-flapp)), for an app that
  gives `FlarumPush` the phone's push token. Flapp does this. The single-forum build here has no
  Firebase set up, so it has no push.
- **Languages:** English, German, Spanish, French, Italian, Japanese, Korean, Dutch, Portuguese,
  Russian and Chinese.

## Layout

- `lib/main.dart`: the runner for one forum.
- `packages/flarum_core/`: the Flarum JSON:API client.
  - Forum info and version detection, sign-in and sign-out, and every read and write the screens
    use.
  - Its tests replay responses recorded from a Flarum 1.8 and a 2.0 forum.
  - It implements forumcopilot_sdk's interfaces (from discourse-app).
- `packages/flarum_ui/`: the screens, on discourse-app's `forum_kit`.
  - `FlarumApp` runs one forum.
  - `FlarumHost` and `FlarumForumPage` let another app host them.
- `tool/test_forums/`: seeds the Flarum 1.8 and 2.0 test forums and records the fixtures.
- `docs/`: what each phase found and decided (`phase-0-notes.md` to `phase-4-notes.md`), the UI
  review against the Discourse app (`ui-review-notes.md`), and the device checks.

## Your forum's app

Edit `packages/flarum_ui/lib/config/app_forum_config.dart`, or pass the forum when you build:

```bash
flutter run --dart-define=FLARUM_URL=https://your.forum --dart-define=FLARUM_NAME="Your Forum"
```

Without these, the app opens the Flarum Community (discuss.flarum.org) as a guest. Before
publishing, change the app's ID (`com.forumcopilot.flarum_app`), name and icon.

## Development

Flutter 3.38.7 (Dart 3.10), as CI uses.

```bash
cd packages/flarum_core && flutter pub get && flutter analyze && flutter test
cd packages/flarum_ui && flutter pub get && flutter analyze && flutter test
flutter pub get && flutter analyze && flutter test   # the app, from the repo's root
```

The tests run offline, against the recorded fixtures. To build against a local discourse-app
checkout, copy `pubspec_overrides.yaml.example` to `pubspec_overrides.yaml`. Live tests and
re-recording are described in `packages/flarum_core/test/live_test.dart` and
`tool/test_forums/README.md`.

## License

MIT. See [LICENSE](LICENSE).
