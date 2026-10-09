# Testing on a phone

The test forums run on the dev server (1.8 on port 8081, 2.0 on 8082), as plain HTTP on
127.0.0.1. A phone reaches them through the Mac: an SSH tunnel to the server, then `adb reverse`.

```bash
# On the Mac, in one terminal: forward the forums' ports from the server.
ssh -N -L 8081:127.0.0.1:8081 -L 8082:127.0.0.1:8082 <dev server>

# With the Pixel connected: the phone's 127.0.0.1:808N goes to the Mac's.
adb reverse tcp:8081 tcp:8081
adb reverse tcp:8082 tcp:8082

# In flarum-app (with pubspec_overrides.yaml copied from the .example files):
flutter run --dart-define=FLARUM_URL=http://127.0.0.1:8082 --dart-define=FLARUM_NAME="Flarum 2 test"
```

Debug builds allow plain HTTP to 127.0.0.1 and localhost only
(`android/app/src/debug/res/xml/network_security_config.xml`); iOS allows local networking. The
forum is chosen at build time (`AppForumConfig`), so a local address never needs committing.

Without `--dart-define`, the app opens the template's default forum, discuss.flarum.org, as a
guest. CI builds that as a debug APK on every push (artifact `app-debug.apk` on the run's page).

## Quickest: CI's debug APK and the forum switcher

1. From the latest green run on GitHub Actions (branch `phase-2`), download the artifact
   `app-debug.apk` and install it: `adb install -r app-debug.apk`.
2. A debug build has a forum switcher at the bottom of the Account tab ("Forum (debug)"): the two
   local test forums (with the tunnel and `adb reverse` above), the 21 census forums, or any address.
   Each forum keeps its own sign-in.

## What only the phone can confirm (Phase 2 exit)

- Sign-in in the app: Account → Sign in on both local forums (1.8 has Turnstile on its log-in, as on
  a real forum); the app returns signed in, Following appears on Home, the Notifications tab lists
  alice's notifications, and Sign out works.
- Browsing: the census forums in the switcher, both versions and several languages (Arabic is
  right-to-left): the home list, a tag, a long thread (scrolling, opening part-way down, "Load earlier
  posts"), a profile, search.
- Posts as the web draws them: the "Formatting samples" discussion on each local forum, beside the
  same posts in the phone's browser (images, YouTube card, video, spoilers, code, task lists, quotes,
  the file card's download).
- Light and dark (Account → Appearance) and the forum's colours.
- The same on an iPhone (iOS web view: sign-in and the remember cookie).

Test accounts on the local forums: alice, bob and carol (password in the server's credentials
file, not in the repo).
