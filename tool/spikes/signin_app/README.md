# Sign-in spike

Proves the plan's sign-in (§6) on a phone: the forum's own log-in page in an in-app web view,
with "Remember me" ticked by injected JavaScript (`assets/signin.js`). The app watches the web
view's cookies for `<prefix>_remember`, uses it as the API token (`GET /api` must show the
reader), then signs out with `FlarumApi.logOut()` and checks the token is refused.

Already checked in headless Chromium posing as a Pixel 7 (`browser_check/check.mjs`): the
cookie is captured and works as a token on Flarum 1.8 with Turnstile, 2.0, and 2.0 with
Turnstile. What's left is the real Android WebView (and later WKWebView on an iPhone).

## Run on the Pixel, from the Mac

The test forums live on the dev server, bound to 127.0.0.1. Tunnel them to the Mac, then let
the phone reach the Mac's ports. The phone then uses the same `http://127.0.0.1:808x`
addresses as the forums, so their links and cookies work unchanged.

```bash
# 1. Keep this open: forwards the Mac's 8081/8082 to the dev server's forums.
ssh -N -L 8081:127.0.0.1:8081 -L 8082:127.0.0.1:8082 ubuntu@<dev server>

# 2. With the Pixel connected:
adb reverse tcp:8081 tcp:8081
adb reverse tcp:8082 tcp:8082

# 3. From this folder. The test password is TEST_USER_PASS in the dev server's
#    /var/www/flarumapp/.credentials. It only fills the form; you still tap "Log In".
flutter run -d <pixel id> --dart-define=FLARUM_TEST_USER=alice --dart-define=FLARUM_TEST_PASSWORD=…

# 4. In another terminal, the run's log:
adb logcat | grep SIGNIN_SPIKE
```

In the app, for each forum chip ("Flarum 1.8 · Turnstile", then "Flarum 2.0"):

1. Tap **Sign in**. The forum opens with its log-in form showing, filled in, "Remember me" ticked.
2. On 1.8, wait for the Turnstile widget to show its tick (the test key passes by itself), then
   tap **Log In**. The page closes on its own.
3. Tap **Sign out**.

A good run logs, per forum:

```
captured flarum_remember (xxxxxx…) … ms after opening the page
GET /api with it: Flarum v1, signed in as alice
logOut revoked the token: true
old token now gets HTTP 401: revoked
```

Turnstile on 2.0's log-in form is off by default on the dev server, because it also blocks
`POST /api/token`, which the tests use. Ask for `flectar-turnstile.signin` to be switched on
to try that case.

Worth trying as well: a real forum's address in the text field, e.g. one that offers fof/oauth
providers. Google refuses to sign in inside web views; the plan expects that.
