# Testing on a phone

The two test forums are public, over HTTPS, so a phone reaches them directly:

| | Address |
|---|---|
| Flarum 1.8 | https://flarum18.betterdiscourse.app |
| Flarum 2.0 | https://flarum20.betterdiscourse.app |

They run on the dev server behind Cloudflare (proxied, with a Cloudflare Origin CA certificate on
the server), carry sample content, are closed to sign-ups and send `X-Robots-Tag: noindex`. The
zone challenges cloud networks, the dev server included: a phone on a mobile or home network gets
through, but tools on the server use the forums' local ports (127.0.0.1:8081 and 8082) instead.

```bash
# In flarum-app (with pubspec_overrides.yaml copied from the .example files):
flutter run --dart-define=FLARUM_URL=https://flarum20.betterdiscourse.app --dart-define=FLARUM_NAME="Flarum 2 test"
```

The forum is chosen at build time (`AppForumConfig`). For a forum on your own machine, debug builds
allow plain HTTP to 127.0.0.1 and localhost (`android/app/src/debug/res/xml/network_security_config.xml`,
with `adb reverse tcp:PORT tcp:PORT`); iOS allows local networking.

Without `--dart-define`, the app opens the template's default forum, discuss.flarum.org, as a
guest. CI builds that as a debug APK on every push (artifact `app-debug.apk` on the run's page).

## Quickest: CI's debug APK and the forum switcher

1. From the latest green run on GitHub Actions (branch `phase-2`), download the artifact
   `app-debug.apk` and install it: `adb install -r app-debug.apk`.
2. A debug build has a forum switcher at the bottom of the Account tab ("Forum (debug)"): the two
   test forums, the 21 census forums, or any address.
   Each forum keeps its own sign-in.

## What only the phone can confirm (Phase 2 exit)

- Sign-in in the app: Account → Sign in on both test forums (1.8 has Turnstile on its log-in, as on
  a real forum); the app returns signed in, Following appears on Home, the Notifications tab lists
  alice's notifications, and Sign out works.
- Browsing: the census forums in the switcher, both versions and several languages (Arabic is
  right-to-left): the home list, a tag, a long thread (scrolling, opening part-way down, "Load earlier
  posts"), a profile, search.
- Posts as the web draws them: the "Formatting samples" discussion on each test forum, beside the
  same posts in the phone's browser (images, YouTube card, video, spoilers, code, task lists, quotes,
  the file card's download).
- Light and dark (Account → Appearance) and the forum's colours.
- The same on an iPhone (iOS web view: sign-in and the remember cookie).

Test accounts on the test forums: alice, bob and carol, and the 14 community members (passwords in
the server's credentials file, not in the repo).
