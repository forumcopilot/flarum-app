# Phase 1 notes

Phase 1 extracted `forum_kit`, the UI layer flarum-app shares with discourse-app, into
discourse-app's `packages/forum_kit` (pull request
[#37](https://github.com/forumcopilot/discourse-app/pull/37)). Last updated 9 October 2026.

**Decision (9 October): share only the generic layer.** The plan (§5.2) also moves the post
renderer, composer and push client into the kit behind platform hooks. In practice they are woven
into Discourse's sign-in, links and media: the renderer's imports reach about 200 discourse_ui
files (72,000 lines). Flarum needs its own renderer profile, composer formats and screens anyway,
so flarum-app copies and adapts those into `flarum_ui` instead. Push waits for Phase 5.

## What forum_kit holds

About 15,000 lines, 87 files, moved from discourse_ui with a re-export (or a thin Discourse
wrapper) left at each old path, so discourse-app and ABDA are unchanged:

- Theme: `AppTheme`, `ForumPalette`, `ForumColors`, design tokens, style builders, the hex colour
  parser and the Font Awesome → Material icon map (Flarum tags use both).
- Widgets: images and avatars (cached, broken-image fallback), code block, empty state,
  skeletons, sheets and app bars, search field and filters, `UserRow`, `DiscardChangesScope`,
  emoji picker, themed web view.
- Services and utilities: caches, logging, memory, async helpers, `AppearanceSync`, time,
  accessibility, file picking, link previews.
- Its own strings, `KitLocalizations` (106 strings, 11 languages), read with `kitL10n(context)`.

CI in discourse-app fails if forum_kit imports discourse_core, discourse_ui or
discourse_notifications.

## Checked

Every step ran discourse-app's CI steps on the dev server, and the pull request's CI passed on
GitHub: analyze (742 infos against main's 747; no warnings or errors), all four test suites
(discourse_core 496, discourse_ui 844, discourse_appearance 3, app 1), the Windows bootstrap, and
the debug APK.

## Left

- Merge #37 into discourse-app's `main` (approval). flarum-app then pins `forum_kit` and
  `forumcopilot_sdk` to that commit.
- Later, with approval: remove the duplicated strings from discourse_ui's `app_*.arb`, cut a
  discourse-app release, repin ABDA.
