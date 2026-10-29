import app from 'flarum/forum/app';
import Page from 'flarum/common/components/Page';
import Button from 'flarum/common/components/Button';
import LogInModal from 'flarum/forum/components/LogInModal';
import SignUpModal from 'flarum/forum/components/SignUpModal';

function trans(key, params) {
  return app.translator.trans(`forumcopilot-flapp.forum.authorize.${key}`, params);
}

/**
 * /flapp/authorize: where a member lets an app sign in through this forum, in
 * the phone's browser. A guest logs in or signs up first, with the forum's own
 * modals; both reload the page, which then asks to Authorize. The forum has
 * already checked the request (AuthorizeContent) and named the app.
 */
export default class AuthorizePage extends Page {
  oninit(vnode) {
    super.oninit(vnode);

    this.request = app.data.flappAuthorize || { error: true };
    this.params = new URLSearchParams(window.location.search);
    this.working = false;
    this.done = false;

    app.setTitle(trans('title', { app: this.request.appName || 'Flapp' }));
  }

  view() {
    return (
      <div className="FlappAuthorizePage">
        <div className="container" style={{ maxWidth: '480px', paddingTop: '40px', paddingBottom: '40px' }}>
          {this.content()}
        </div>
      </div>
    );
  }

  content() {
    const request = this.request;

    if (request.error) return <p>{trans('invalid_text')}</p>;

    if (this.done) return <p>{trans('done_text', { app: request.appName })}</p>;

    const user = app.session.user;
    const forum = app.forum.attribute('title');

    if (!user) {
      return [
        <h2>{trans('guest_heading', { app: request.appName })}</h2>,
        <p>{trans('guest_text', { app: request.appName, forum })}</p>,
        <div className="Form-group">
          <Button className="Button Button--primary Button--block" onclick={() => app.modal.show(LogInModal)}>
            {app.translator.trans('core.forum.header.log_in_link')}
          </Button>
        </div>,
        app.forum.attribute('allowSignUp') ? (
          <div className="Form-group">
            <Button className="Button Button--block" onclick={() => app.modal.show(SignUpModal)}>
              {app.translator.trans('core.forum.header.sign_up_link')}
            </Button>
          </div>
        ) : null,
        <p>
          <a href={request.cancelUrl}>{trans('cancel_button')}</a>
        </p>,
      ];
    }

    return [
      <h2>{trans('member_heading', { app: request.appName, forum, username: user.username() })}</h2>,
      <p>{trans('member_text', { app: request.appName })}</p>,
      <div className="Form-group">
        <Button className="Button Button--primary Button--block" loading={this.working} disabled={this.working} onclick={this.authorize.bind(this)}>
          {trans('authorize_button')}
        </Button>
      </div>,
      <div className="Form-group">
        <a className="Button Button--block" href={request.cancelUrl}>
          {trans('cancel_button')}
        </a>
      </div>,
      <p>
        <a href="#" onclick={this.logOut.bind(this)}>
          {trans('not_you_link', { username: user.username() })}
        </a>
      </p>,
    ];
  }

  authorize() {
    this.working = true;

    // A failure shows Flarum's own alert.
    app
      .request({
        method: 'POST',
        url: app.forum.attribute('apiUrl') + '/flapp-auth/approve',
        body: { app: this.params.get('app'), publicKey: this.params.get('publicKey'), nonce: this.params.get('nonce') },
      })
      .then((result) => {
        this.done = true;
        window.location.href = result.redirect;
      })
      .finally(() => {
        this.working = false;
        m.redraw();
      });
  }

  // Signed in as someone else in this browser: log out and come back here.
  logOut(e) {
    e.preventDefault();

    window.location.href = `${app.forum.attribute('baseUrl')}/logout?token=${app.session.csrfToken}&return=${encodeURIComponent(
      window.location.href
    )}`;
  }
}
