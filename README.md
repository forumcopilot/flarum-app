# flarum-app

A native Flutter client for [Flarum](https://flarum.org) forums, supporting Flarum 1.8 and 2.0
with no plugin needed on the forum. Built on the same stack as
[discourse-app](https://github.com/forumcopilot/discourse-app).

**Status: Phase 0 (spike).** So far this repo holds `packages/flarum_core`, the REST client. The
app itself, `flarum_ui` and the shared `forum_kit` come in later phases.

## Layout

- `packages/flarum_core/`: Flarum JSON:API client: forum info and version detection, sign-in,
  discussions, posts, users, notifications. Plain Dart for now.
- `tool/test_forums/`: seeds the local Flarum 1.8 and 2.0 forums the tests are recorded from.
- `tool/spikes/`: one-off experiments, such as rendering Flarum HTML with discourse-app's renderer.
- `docs/phase-0-notes.md`, `docs/phase-1-notes.md`: what each phase found and decided.

## Development

Flutter 3.38.7 (Dart 3.10), as discourse-app's CI.

```bash
cd packages/flarum_core
dart pub get
dart analyze
dart test                     # offline, against fixtures recorded from both versions
```

Live tests against running forums, and re-recording fixtures, are described in
`packages/flarum_core/test/live_test.dart` and `tool/test_forums/README.md`.

## License

MIT. See [LICENSE](LICENSE).
