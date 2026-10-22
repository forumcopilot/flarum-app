# Phone check: the UI review's changes

The 15 changes from the UI review, the bugs it found, the message notification fix and the
review's Later list, on the Pixel (the iPhone's part is in `iphone-tests.md`, run at the end). What each change should look
like, with the website beside it: the "Flarum App UI Changes" page,
https://claude.ai/artifact/7tRPwsajPnnFewKn5dPJ6S.

Setup: in flarum-app, `git fetch && git checkout phase-4 && git pull` (expect 5fcb495 or later),
against the pinned discourse-app (no pubspec_overrides). Build once per forum, 2.0 first:

    flutter run -d <pixel> --dart-define=FLARUM_URL=https://flarum20.betterdiscourse.app --dart-define=FLARUM_NAME="Flarum 2 test"
    flutter run -d <pixel> --dart-define=FLARUM_URL=https://flarum18.betterdiscourse.app --dart-define=FLARUM_NAME="Flarum 1.8 test"

Log In as **bob**, never alice; members' password 12344321. Everything below on both forums
unless it names one.

1. **Home**: the forum's welcome message heads Latest; ✕ hides it, and it stays hidden after the
   app is closed and opened again. Discussion rows: Forum rules has the red pin and the lock;
   secondary tags (question, bug, iOS) are filled with their colour; a private discussion names
   only the others in it, never bob ("With alice"). The double tick (Mark All as Read) asks "Are
   you sure…"; Cancel.
2. **A discussion**: open "Router keeps dropping Wi-Fi every evening" (Tech Help). The header is in
   the tag's colour with the lock and the green check; scrolled up, the title moves into the top
   bar. The bottom bar says "1 of 5 posts" and Can't Reply (it's locked). Under each post: Like
   and the likers ("… like this."), with a thumbs-up.
3. **Where am I**: open "Long thread for paging tests". The bar's position follows the scrolling.
   Tap it: the scrubber; drag the slider to about 40 and let go (the thread lands there); Original
   Post; Now. Reply in the bar opens the composer: close it without posting.
4. **Like and Reply under a post**: in "Welcome to the test forum", Like carol's post (the thumb
   turns blue, the line says you like it), then Unlike. Reply under alice's post opens the
   composer with the mention: close it without posting.
5. **Follow**: the star in the discussion's top bar → Following (the star fills; Following on
   the header); set it back to Not Following.
6. **Share and Copy Link**: the top bar's share icon opens Android's share sheet with the
   website's address (`…/d/3-welcome-to-the-test-forum`, the id once); cancel it. A post's ⋮ →
   Copy Link → "Link copied."; paste it into Chrome: `…/d/3-welcome-to-the-test-forum/4` opens
   that post on the website.
   On bob's profile, ⋮ → Share and Copy Link.
7. **Notifications**: grouped under each discussion's title, each with its kind's icon on the
   avatar and the post's first lines; a tap opens the post.
8. **Account**: Profile opens bob's card; Settings opens the forum's settings page in the app,
   logged in as bob (the ↗ in its top bar opens it in Chrome); Back returns to Account. Log Out
   asks first: Cancel.
9. **Profile**: bob's card is a darkened version of his avatar colour, his avatar ringed in
   white; Last seen, Joined, best answers. The Likes and Mentions tabs list posts, and a tap opens
   one.
10. **Search**: type "thread": the matching words in bold, in a line of the post; on 2.0 a Posts
    tab, on 1.8 only Discussions and Users. Type "bo": Users lists bob. Close and open Search: the
    recent searches show; Clear empties them.
11. **A tag's page**: Tags → Support: the top bar is the tag's orange, with its icon.
12. **As a guest**: Account → Log Out → Log Out. Home still offers Start a Discussion. In a
    discussion: Reply under the posts, and Log In to Reply in the bar; tap it: the Log In page,
    and Back returns to the discussion. The Notifications tab offers Log In. Then Log In as bob
    from there: with the phone in dark mode, the page shows no white flash before the forum's
    page; on the forum's page, open a "Log in with …" link if the forum has one and press Back:
    it goes back inside the page, not out of it. Logged in, Start a Discussion → Choose Tags:
    General can be chosen (it stayed greyed out until a restart); close the composer without
    posting.
13. **Dark mode**: with the phone in dark mode, the discussion header, a tag's page and the
    profile card are readable.
14. **The unread-messages badge** (2.0 only; flarum/messages only emails about a message, so it
    never shows in Notifications): with the app on Home, as carol on the website send bob a
    message. Put the app in the background and bring it back: the Account tab shows 1 (or change
    tab: it shows then too). Open the conversation in Account → Messages, then Back: the Account
    tab's badge is gone at once.

15. **The picture viewer**: in "Formatting samples", tap a picture (for the sideways swipe, 2.0's
    "Feature request: dark mode" has bob's post with two). Drag it down a little and let
    go: it springs back; drag it further: it closes, the discussion showing through as it goes.
    Double-tap: it zooms in where tapped; drag around; double-tap: back out. Save Image: "Image
    saved.", and the picture is in Google Photos (or the gallery). Share: the share sheet offers
    the picture itself. Swipe sideways to the next picture.

16. **Pull to refresh and long silences**: in a discussion, pull down at the top: the spinner,
    then the posts again. 2.0's "Feature request: dark mode" shows "10 DAYS LATER" before bob's
    iPhone post. (On discuss.flarum.org, through the forum switcher at the bottom of Account,
    "Install Issue - templateSpec.call", sorted Oldest, shows "12 DAYS LATER".)
17. **The composer's bar**: Reply, write a word, select it, tap B: it becomes **bold** markup;
    the bar has Italic, Quote, Link, List and Code too, ••• holds the rest, and the bar scrolls
    sideways to @ and the uploads. Close without posting.

18. **Home's menus**: "All Discussions ▾" lists All Discussions, Following, Bookmarks, Private
    Discussions (and Messages on 2.0), then the tags; Following lists the discussions bob follows,
    a tag opens its page. The sort menu ("Latest ▾") has Latest, Top, Newest, Oldest, and on 2.0
    Title (A–Z) and (Z–A); Oldest puts the oldest first.
19. **Sticky discussions**: on Home and on a tag's page, a sticky discussion bob hasn't opened
    shows its first lines under its row (Forum rules: "Be kind. Stay on topic…"); once opened, it
    doesn't.
20. **Swipe and long-press on a discussion**: swipe an unread discussion to the right: "Mark as
    Read" shows behind it, and the row's unread count goes. Long-press a row: its title, Mark as
    Read (if unread), Not Following / Following / Ignoring, Bookmark, Share, Copy Link.
21. **Closing a composer**: Reply, write something, ✕: "You have not posted your reply. Do you
    wish to discard it?" with Cancel, Save Draft and Discard; Start a Discussion asks about "your
    discussion", an edit about "your changes" (2.0: bob's latest post; on 1.8 none of bob's posts
    can be edited any more). Cancel each time.
22. **Mentions**: in a discussion with several people, Reply and type "@": the discussion's
    people show at once, the latest poster first, without bob; type a letter to narrow them.
    Close without posting.
23. **Messages** (2.0 only): Account → Messages: the ✓✓ (Mark all as read) when one is unread.
    In bob's conversation with carol (check 14 started one): "Start of the conversation" above the
    first message. Send carol two short messages in a row: they're drawn as one run, the time once
    under the second. Long-press a message: "Message copied.", and it pastes elsewhere.
24. **Notification settings**: Notifications → ⚙: a row per kind of notification, in the
    forum's words, with Web and Email boxes (likes have Web only, messages Email only), then
    "Automatically follow discussions that I reply to". Untick one, and check Account → Settings
    (the forum's page, in the app) shows it unticked; tick it again.
25. **Tags and best answers**: Tags: each tag shows its latest discussion and when; a tap on it
    opens the discussion at its last post. "Router keeps dropping Wi-Fi every evening": under the
    first post, the best answer's preview (Best Answer, Nils Hagen, its first lines); a tap goes to
    it.
26. **Moderation** (only with a moderator's login on a test forum; skip it otherwise, tests cover
    it): a discussion's shield menu → Edit Tags (the tag picker, on its tags); Account → Flagged
    Posts; a member's profile → ⋮ → Suspend: Flarum's page (Not suspended, Suspended
    indefinitely, for a number of days, the reason and the message). Cancel each time.

**Flapp** (forumcopilot/flapp main, 697d1b6 or later): in its checkout beside flarum-app (clone
git@github.com:forumcopilot/flapp.git there if it's missing), `git pull`, move any
`pubspec_overrides.yaml` aside so it builds the pinned flarum-app, then `flutter run -d <pixel>`.
Log in to the 2.0 test forum as bob inside Flapp for check 27.

27. **Your forums' badges**: log in to a test forum in Flapp, go back to the list: its tile has a
    badge with its unread notifications and messages; one you aren't logged in to has none.
28. **Explore**: type "discuss.flarum.org" into Explore's search: "Open discuss.flarum.org" above
    the results opens it. Add forum → "example.com": "…isn't a Flarum forum…" with Open in
    browser, which opens it in Chrome.
29. **Links to other forums**: in Flapp, on the 2.0 test forum as bob, Start a Discussion "Phone
    check links" (tag General) with the text `https://discuss.flarum.org/d/4 and https://example.com`.
    In the posted discussion tap the first link: it opens in Flapp (Flarum Community, "Install
    Issue - templateSpec.call"), not in Chrome. Back goes to Flarum Community's Home, then to Your
    forums: one forum is open at a time, so the test forum closed. Open the test forum and the
    discussion again: the second link opens Chrome. List the discussion in the report, to be removed
    on the server.

Report: PASS or FAIL per check and forum, with what you saw and screenshots of failures; the
Pixel model and Android version; and everything created (likes left, messages, anything posted)
so it can be removed on the server. Save it as ~/flarum-phone-run/report-ui-review.md.
