# Phase 4 notes

Phase 4 is Flapp: the multi-forum app for Flarum, built on flarum-app the way ABDA is built on
discourse-app (the plan: the "Flarum App Plan", Phase 4). Flapp's own code (the forum list,
Explore and its directory, onboarding, the brand) is in its own repository; this repo's part is
letting flarum_ui's screens run inside it. Work is on branch `phase-4`, started 16 October 2026
from `phase-3` at b029ad1.

## Hosting flarum_ui

The single-forum app had one forum per run: `FlarumApp.initialize` connected it before `runApp`,
and the debug switcher restarted the app on another. A host needs to open any forum, come back
to its own screens, and open another, each with its own sign-in and colours. What was already
per forum stayed as it was: `FlarumForum` (the API client, its token and `GET /api` info),
`FlarumTokenStore`, `IgnoredUsers`, the upload limits and `ForumMediaAuth` are all keyed by the
forum's address, and flarum_ui's screens take the forum's `SiteContext` rather than reaching
for a global one.

- **`FlarumHost`:** `ensureInitialized()` (the SDK, Flarum's proxy factory, relative times, the
  remembered colours), `localizationsDelegates` and `supportedLocales` for the host's
  `MaterialApp`, and `site(name:, url:)`.
- **`FlarumForumPage(site:, link:, appearance:)`:** the forum, pushed over the host's screens.
  It connects (`FlarumForumPage.connect`: the sign-in kept from earlier, `GET /api`, the
  forum's colours), showing the forum's name and a spinner meanwhile, then shows `AppShell`.
  A forum already connected this run opens at once. `link` (a `ForumLink`) opens a discussion,
  profile or tag over the home. Every tab's top bar gets a back arrow to the host's screens.
  `appearance` null leaves the light/dark choice off the Account tab, for a host that offers it
  on its own settings screen, as ABDA does.
- **`FlarumForumTheme`:** discourse_ui's `ForumTheme` for Flarum. `FlarumForumPage` enters and
  leaves it; `current` is the innermost open forum's palette (also set as forum_kit's
  `AppTheme.palette`), null on the host's own screens. The host builds its `MaterialApp`
  themes from `current`. Palettes are remembered on the phone (`flarum_forum_palettes`, 50
  forums), so a forum opens in its colours at once; a host with a directory gives a forum's
  colours before its first visit with `update(url, flarumPaletteOf(primary, secondary))`. The
  forum page themes itself from its first frame, since the app-wide change lands a microtask
  later (a page's `initState` can't rebuild the host's theme builder mid-build).
- **The single-forum app** uses the same pieces: `FlarumApp.initialize` is
  `FlarumHost.ensureInitialized`, `FlarumForumPage.connect` and `FlarumForumTheme.enter`, and its
  `MaterialApp` follows `FlarumForumTheme.current`. Nothing changes for it on screen.
- **Tests:** `test/app/hosting_test.dart` hosts a 1.x and a 2.0 forum at two addresses
  (`FixtureForum.forum(url:)`) in a stand-in host: each opens from the host's list with its own
  requests, title and colours, Back returns to the list in the host's colours, a forum opened
  again opens without a spinner, one opened at a discussion has its home under it, one that
  doesn't answer keeps the colours the host gave it, and the Account tab leaves the appearance
  to the host.

Not yet: links in a post to another Flarum forum still open in the browser (a host hook can
open them in the app later), and push (Phase 5).
