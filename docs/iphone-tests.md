# Left for the iPhone

What only a real iPhone can confirm, kept here to run together at the end (decided 15 October
2026). The Pixel 4a has passed the Android side of everything below unless it says otherwise.
Setup is in `device-testing.md` (iPhone): a signing team chosen locally, the phone unlocked,
Developer Mode on. Write as **bob** on the test forums, never alice; members' password 12344321.

Done so far on the iPhone (iPhone 17, iOS 26.7.1, 15 October, at 988c77a): the app builds, signs
and launches; Home, a thread ("Formatting samples"), a profile, Tags and a tag, the forum switcher
and mondedie.fr all worked. Sign in opened the web view but wasn't completed.

## From Phase 2's exit

1. **Sign-in in the iOS web view**, on both test forums (1.8 has Turnstile on its log-in): Account
   → Sign in → the forum's page → the app returns signed in as bob (the remember cookie read from
   WKWebView's cookie store). Following appears on Home, Notifications lists bob's. Sign out, then
   sign in again. This is the one Phase 2 item never seen on an iPhone.
2. **Census forums**, as a guest through the forum switcher: Home, one thread, Tags, a profile on
   each of the 21 (`device-testing.md`'s list); Arabic right to left (foro.arsoporte.com /d/647),
   Chinese (discuss.flarum.org.cn), Russian, Thai fonts.
3. **What the web draws**, beside Safari: "Formatting samples" (images, the YouTube card, video,
   spoilers, code, task lists, quotes), a file card's download and Share (the share sheet), links
   opening in Safari.
4. **Light and dark**, and the forum's colours; the notch and home indicator (safe areas) on every
   screen.

## From Phase 3's exit: reading and posting

5. **Composer**: Start a discussion with tags, Reply, Quote, Edit, an @mention from the
   suggestions; the keyboard doesn't cover the toolbar; the close prompt (Discard / Save draft /
   Cancel) when closing with something written.
6. **Uploads**: Upload image asks for the photo library the first time (the app's own words: "To
   add photos from your library to a post."), then posts the photo, named like IMG_<date>_<time>.jpg
   (iOS's picker calls it image_picker_<UUID>.jpg); a photo taken by the iPhone (HEIC on the phone;
   the picker hands it over as JPEG) shows in the post; a photo over 2 MB is shrunk with the notice; Take photo
   asks for the camera ("To take a photo for a post.") and posts it; Attach file picks from Files.
7. **Actions**: like, react, bookmark (Account → Bookmarks, and after Back), follow a discussion,
   a tag's level, best answer where possible.
8. **Polls and drafts**: a discussion with a poll (the date and time pickers), voting, who voted;
   Save draft from a reply, a new discussion and a private discussion; Account → Drafts.
9. **Safety and private**: Flag, Ignore and Stop ignoring, a private discussion with carol, a
   message to carol (2.0).
10. **Offline**: airplane mode, pull Home → the list stays with "Couldn't reach the forum…".

## From Phase 4's UI review

The Pixel's list is `phone-check-ui-review.md`; on the iPhone, what differs from Android:

1. **Share**: the discussion's share icon and a profile's Share open iOS's share sheet; Copy Link
   then pasting into Safari opens the post on the website.
2. **Where am I**: the bottom bar and the scrubber clear the home indicator; dragging the slider.
3. **Log In**: no white flash before the forum's page in dark mode (WKWebView), and Back inside a
   "Log in with …" page goes back in it.
4. **Saving a picture**: the picture viewer's Save Image asks to add to Photos the first time
   (the app's words: "To save pictures from posts to your photos."), then the picture is in
   Photos; Share offers the picture, with Save Image among the choices.
5. **Colours under the notch**: the discussion header and a tag's page in the tag's colour reach
   the top of the screen cleanly, in light and dark.

## Later phases

- Phase 5: a push notification arrives (APNs) within a poll interval, and tapping it opens the
  post.
- Phase 6: the release build (not debug) on the iPhone before the store.

Report the iPhone model and iOS version, PASS or FAIL per item with what was seen, screenshots of
failures, and everything created on the forums, so it can be removed on the server.
