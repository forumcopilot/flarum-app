# Phone check: the UI review's changes

The 15 changes from the UI review, the bugs it found, and the message notification fix, on the
Pixel (the iPhone's part is in `iphone-tests.md`, run at the end). What each change should look
like, with the website beside it: the "Flarum App UI Changes" page,
https://claude.ai/artifact/7tRPwsajPnnFewKn5dPJ6S.

Setup: in flarum-app, `git fetch && git checkout phase-4 && git pull` (expect 1ab43bd or later),
against the pinned discourse-app (no pubspec_overrides). Build once per forum, 2.0 first:

    flutter run -d <pixel> --dart-define=FLARUM_URL=https://flarum20.betterdiscourse.app --dart-define=FLARUM_NAME="Flarum 2 test"
    flutter run -d <pixel> --dart-define=FLARUM_URL=https://flarum18.betterdiscourse.app --dart-define=FLARUM_NAME="Flarum 1.8 test"

Log In as **bob**, never alice; members' password 12344321. Everything below on both forums
unless it names one.

1. **Home**: the forum's welcome message heads Latest; ✕ hides it, and it stays hidden after the
   app is closed and opened again. Discussion rows: Forum rules has the red pin and the lock;
   secondary tags (question, bug, iOS) are filled with their colour; a private discussion says
   "With carol". The double tick (Mark All as Read) asks "Are you sure…"; Cancel.
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
6. **Share and Copy Link**: the top bar's share icon opens Android's share sheet (cancel it). A
   post's ⋮ → Copy Link → "Link copied."; paste it into Chrome: it opens that post on the website.
   On bob's profile, ⋮ → Share and Copy Link.
7. **Notifications**: grouped under each discussion's title, each with its kind's icon on the
   avatar and the post's first lines; a tap opens the post.
8. **Account**: Profile opens bob's card; Settings opens the forum's settings page in the
   browser; on 2.0 an unread-messages badge on the Account tab when bob has one; Log Out asks
   first: Cancel.
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
    it goes back inside the page, not out of it.
13. **Dark mode**: with the phone in dark mode, the discussion header, a tag's page and the
    profile card are readable.
14. **A message notification** (2.0 only): on the website as bob, Settings → Notifications → tick
    the alert (bell) column for "Someone sends me a message". As carol on the website, send bob a
    message. In the app, Notifications shows "carol sent you a message" with its text; a tap opens
    the conversation. Then untick bob's setting again.

Report: PASS or FAIL per check and forum, with what you saw and screenshots of failures; the
Pixel model and Android version; and everything created (likes left, messages, anything posted)
so it can be removed on the server. Save it as ~/flarum-phone-run/report-ui-review.md.
