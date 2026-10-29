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
open them in the app later), and push (Phase 5). Both came later: the hook on 21 Oct (item 27
below), push on 26 Oct.

### Push through the Flapp extension (25 Oct)

A forum running forumcopilot/flarum-flapp announces `flappPush` on `GET /api` (its relay and its
id there; `FlarumForumInfo.flappPush`). A host with push sets `FlarumPush.device` (a
`FlarumPushDevice`: platform, app, version, locale, the push token, the notification permission
and the phone's relay installation) before the first sign-in; the single-forum app sets none, and
nothing runs.

- **Registering:** signing in, and `FlarumForumPage.connect` once a run, call
  `FlarumPush.registerQuietly`: `PUT /v1/installation` and `POST /v1/handles` on the relay, then
  `POST /api/flapp-push/devices` with the handle on the forum. The registration (relay, forum id,
  handle, device id) is kept in secure storage per forum (`FlappRegistrationStore`). Failures leave
  the forum unregistered until the next launch. A forum without the extension is left alone.
- **Signing out:** `FlarumForum.signOut` first deletes the device on the forum and the handle on the
  relay (5 s at most), then revokes the token, which would take the device with it anyway.
- **A push:** its data names the forum by `forum_id`; `FlarumPush.forumUrlFor` gives the forum's
  address while the phone is registered there, null after sign-out (drop the push).
  `ForumLink.fromPush(data)` is what it opens (`DiscussionLink`, `DialogLink`, `UserIdLink`), for
  `FlarumForumPage(link:, notificationId:)`, which also marks the notification read.
- **Token changes:** `FlarumPush.updateInstallations()` tells each relay once.
- **Tests:** flarum_core's `flapp_push_test.dart` (fixtures from both forums, recorded as bob by
  `tool/record_flapp_fixtures.dart`, and a scripted relay); flarum_ui's `forum_links_test.dart`
  and `hosting_test.dart` (a forum opened from a push).

## The UI review (20 Oct)

Three reviews (the app beside Flarum's website on a phone, beside discourse-app and ABDA, and
every string beside Flarum's own) are in the "Flarum App UI Review" doc:
https://claude.ai/artifact/XGRBZHKA3dzFmtP2SZ6PRY. All 15 of its recommended changes were
approved, and are built (its table names each one's commit). Done since:

- **Flarum's wording** (e20f611): every string with a Flarum equivalent says what Flarum's
  website says, from Flarum's English and the flarum-lang packs, in Flarum's Title Case inside
  forums. A phone in a language the app lacks gets English (it got German). forum_kit's strings
  (the suspend page, the discard prompts, Save draft) are still Discourse's.
- **Bugs** (b0bbfb1, e1a12e0): the thread lands on the post after Reply, Edit or a jump (it
  opened about half a page above); closing a composer asks before losing tags, a poll or
  people, and the poll editor asks; the message keyboard stays up; failed next pages offer
  Retry; notifications reload when the tab is opened again; Account says when a logged-in
  reader's forum can't be reached; a post that fails to draw shows its text; a tag's
  description fits; Log In is covered until the forum's page draws, and Back goes back in it.
  `FixtureForum.latency` lets a test draw frames while a request is under way, as a phone does:
  without it, a fixture answers before the next frame and some bugs can't show.
- **The 15 changes** (2cc41a4 to d3c77b0, 20 to 21 Oct): Like and Reply under each post, and
  likes as "bob and carol like this" with Flarum's thumbs-up; Flarum's icons (Follow's star,
  byobu's map); every coloured tag filled; Mark All as Read, asking first. Guests are offered Log
  In where they'd act (`logInFirst`, with `ForumSession` telling every screen). Share and Copy
  Link (`WebLinks` builds the website's addresses); Account opens the reader's profile and the
  forum's settings, and asks before Log Out. Notifications grouped by discussion, with the type's
  icon and the post's first lines. Discussion rows wear the web's badges and name who a private
  one is with. Home shows the forum's logo and its welcome message, which can be hidden until the
  forum changes it. Search: the matched words in bold in context, more pages, a Users tab, recent
  searches; Posts only on 2.0, since on 1.x it repeated the discussions' best posts. The
  discussion's header and a tag's page in the tag's colour. The profile as Flarum's user card,
  with groups, best answers, and Likes and Mentions tabs. The thread's bottom bar: where the
  reader is ("12 of 340 posts", opening the scrubber: Original Post, a slider, Now) and Reply,
  Log In to Reply or Can't Reply, in place of the floating Reply button.

- **The picture viewer** (5da4295; the review's item 16): drag down to close, double-tap to
  zoom, Save Image (saver_gallery; Android 9 and earlier ask for storage, iOS asks to add to
  Photos itself, so permission_handler is only asked on Android) and Share.
- **Message notifications** (1ab43bd) open their conversation (flarum/messages' `messageReceived`).
- **A discussion** (592cfd4; item 21) pulls to refresh, and marks posts more than 4 days apart
  with the website's "12 days later" (counted as dayjs counts it).
- **The composer's bar** (44b3495; item 18): Bold, Italic, Quote, Link, a bulleted list and Code
  in one tap, with flarum-markdown's tooltips; the rest under Formatting.

- **The rest of the Later list** (21 Oct): Home's view and sort menus (19; 3b353a8); messages
  grouped as a chat, with flarum/messages' labels and Mark all as read (22; 74c7762); a sticky
  discussion's opening words (17; 126efa7: 2.0 sends `firstPostExcerpt`, 1.x's are read with
  `filter[number]=1`, since 1.x lists include the first post only when a request names no
  includes); swipe to mark read and long-press controls (20; 98116ca); flarum_ui's own Suspend page
  and close prompts in Flarum's words (23; 294ffb0, no longer forum_kit's); Edit Tags and Flagged
  Posts (24; 7bd401f); the discussion's people on `@` (25; 88e188f); notification settings (29;
  4041917); each tag's latest discussion and the best answer's preview (30; 7abb713). 2.0's
  coloured header (`theme_colored_header`) is only in the web page's HTML, so the app can't follow
  it. Flapp: Explore opens a typed address and a non-Flarum link offers the browser (28; 5b4a725),
  a post's link to another forum opens it in Flapp through `FlarumHost.openOtherForumLink` (27;
  72306ad, b0ebaa8), and Your forums badges unread activity (26; d73e0cf).

- **The Pixel run** (Pixel 4a, 20–21 Oct, at 3174df4; report on the Mac,
  ~/flarum-phone-run/report-ui-review.md): everything passed on both forums but three bugs, fixed
  since with tests: shared links repeated the id (Flarum's slug already starts with it);
  Account → Settings opened the website's settings in Chrome, where the reader isn't logged in
  (it's now a page in the app with the reader's token as the forum's remember cookie,
  `ForumWebPage`, forgotten at Log Out); and the unread-messages badge waited for the Notifications
  tab (the shell now follows `FlarumForum.infoChanges`, and reads the info again on each tab and
  when the app comes back). Also: a private discussion's row no longer names the reader, a
  discussion opened at its first post shows its header, and the bar counts the last post at the
  end. A message notification can't be checked: flarum/messages only emails it (CLAUDE.md).
  Left: Home keeps a discussion's row as it was when it's read from another tab, until a refresh
  (as before for unread counts); a 1.8 visit once left a discussion unread, not reproduced.
  Fixed on 28 Oct: leaving a thread sends what was read, then `FlarumForum.discussionChanges`
  names the discussion, and every `DiscussionListModel` of that forum (Home's lists, a tag's,
  Following, Bookmarks, a profile's) reads the row again. Before, only the list the thread was
  opened from read it, as the page closed, which could be before the last read reached the forum
  (that may be the 1.8 visit). A row's swipe and long-press controls go the same way, so Home's
  other sort chips follow too.

- **The re-check** (Pixel 4a, 22 Oct, flarum-app 6b8634d, Flapp a2a4031 pinning 7abb713): the
  fixes passed on both forums (checks 1, 3, 6, 8, 14, 16, 24, 27, 28). Found: after Log In from a
  guest's visit, every tag in Choose Tags stayed greyed out until the app restarted. Sign-in kept
  the tags read as a guest (`canStartDiscussion` false), as sign-out already forgot them; it
  forgets them now too. Check 29's Back goes to the linked forum's Home, then Your forums: Flapp
  keeps one forum open at a time (`ForumOpener`), so the forum the link was in closes; the
  checklist says so now. Bob's Notifications tab said 13 at launch and 7 once the list had loaded:
  Flarum counts 13 unread notifications, the list shows 7 rows (four suspended and four
  unsuspended notices on his own account make one row each), and the badge goes by the list once
  it has loaded. Flapp's tile, which never loads the list, says 13.

- **The last checks** (Pixel 4a, 28 Oct, Flapp's debug build at flarum-app 6425164, the code of
  v0.1.2; the phone in dark mode): all passed. Log In on a forum where the reader is a guest
  (kagifeedback.org) showed the app's dark cover, then the forum's own dark page, then its log-in
  box with Remember Me ticked: no frame of a screen recording was white. Its Google button opened
  Google's sign-in page inside Log In; Back went back to the forum's log-in box, and Back again
  closed Log In. As bob on the 2.0 forum: the thread's bar followed the reading ("12 of 60
  posts"), and the scrubber went to post 46 from the slider, to the last post with Now and to the
  first with Original Post; Share offered `/d/6-long-thread-for-paging-tests` and a post's Share
  the same with `/3`; a tag's page is tinted with its colour in dark mode as in light. The
  discussion's head has no tag colour, by design since the UI review's phase 1 (d8e0890). A
  message can't reach the notification list (flarum/messages registers no alert for it,
  CLAUDE.md), so it was checked through push: carol's message to bob came as "carol sent you a
  message" under the forum's name, and the tap opened the conversation.

- **Dark mode as ABDA's** (29 Oct): in dark mode every Flarum forum was on #222222, a grey beside
  ABDA's near-black. flarum_ui gave each forum Discourse's stock "Dark" scheme as if the forum had
  chosen it, and forum_kit keeps a forum's own neutral page. A Flarum palette now has no dark
  scheme (Flarum has none to give), so dark mode is forum_kit's for a forum without one, as ABDA's
  is: Material's dark neutral with a hint of the accent (#121315 for Flarum's blue), and the
  selected chip in the accent's hue rather than Discourse's teal. Palettes remembered by earlier
  versions drop the stock scheme as they load. Checked on the 4a beside ABDA in dark mode.
