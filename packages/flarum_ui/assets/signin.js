// Injected into the forum page by the app's sign-in (flarum_ui SignInPage). Works on Flarum 1.x and 2.0.
//
// flarumAppSignIn.start(fill) opens the forum's log-in modal by clicking its own
// "Log In" button, ticks "Remember me" (without it Flarum sets no flarum_remember
// cookie, only a server-side session), and, when `fill` has an identification and
// password, types them in. The reader still presses "Log In" themselves, so a
// CAPTCHA in the modal (Turnstile, reCAPTCHA) is completed as on the website.
//
// Progress goes to report(): the Flutter handler "signinStatus" in the app, the
// console elsewhere.
(function () {
  if (window.flarumAppSignIn) return;

  function report(message) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('signinStatus', message);
    } else {
      console.log('signinStatus: ' + message);
    }
  }

  // Mithril reads input values from input events, so a plain assignment isn't enough.
  function type(input, value) {
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }

  function step(fill) {
    var modal = document.querySelector('.LogInModal');
    if (!modal) {
      if (document.querySelector('.item-session, .SessionDropdown')) {
        report('already signed in');
        return true;
      }
      var button = document.querySelector('.item-logIn button, .item-logIn .Button');
      if (button) button.click();
      return false;
    }
    var remember = modal.querySelector('input[type=checkbox]');
    if (!remember) return false;
    if (!remember.checked) remember.click();
    if (fill && fill.identification && fill.password) {
      var identification = modal.querySelector('input[name=identification]');
      var password = modal.querySelector('input[name=password]');
      if (identification && password) {
        type(identification, fill.identification);
        type(password, fill.password);
      }
    }
    report('log-in modal open, remember me ' + (remember.checked ? 'ticked' : 'NOT ticked'));
    return true;
  }

  window.flarumAppSignIn = {
    start: function (fill) {
      var tries = 0;
      var timer = setInterval(function () {
        var done = false;
        try {
          done = step(fill);
        } catch (e) {
          report('error: ' + e);
        }
        if (done || ++tries > 60) {
          clearInterval(timer);
          if (!done) report('log-in modal not found');
        }
      }, 250);
    },
  };
})();
