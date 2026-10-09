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

Test accounts on the local forums: alice, bob and carol (password in the server's credentials
file, not in the repo).
