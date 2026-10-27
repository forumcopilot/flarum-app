import app from 'flarum/admin/app';
import ExtensionPage from 'flarum/admin/components/ExtensionPage';
import Button from 'flarum/common/components/Button';

const FORUM_ID = 'forumcopilot-flapp.forum_id';
const CONNECTED_RELAY_URL = 'forumcopilot-flapp.connected_relay_url';

function trans(key, params) {
  return app.translator.trans(`forumcopilot-flapp.admin.page.${key}`, params);
}

/**
 * What connecting does, and Connect or Disconnect. There is nothing else to
 * set: the relay needs no account.
 */
export default class FlappPage extends ExtensionPage {
  oninit(vnode) {
    super.oninit(vnode);

    this.working = false;
  }

  content() {
    const connected = !!app.data.settings[FORUM_ID];

    return (
      <div className="ExtensionPage-settings">
        <div className="container">
          <div className="Form">
            <p>{trans('intro')}</p>
            <p>{trans('independent')}</p>

            <h3>{trans('how_heading')}</h3>
            <p>{trans('how_text')}</p>
            <p>
              <a href="https://flapp.forumcopilot.com/privacy/" target="_blank" rel="noopener">
                {trans('privacy_link')}
              </a>
            </p>

            <h3>{trans('members_heading')}</h3>
            <p>{trans('members_text')}</p>

            <h3>{trans('status_heading')}</h3>
            <p>{connected ? trans('connected_text', { relay: app.data.settings[CONNECTED_RELAY_URL] }) : trans('not_connected_text')}</p>

            <div className="Form-group">
              {connected ? (
                <Button className="Button" loading={this.working} disabled={this.working} onclick={this.disconnect.bind(this)}>
                  {trans('disconnect_button')}
                </Button>
              ) : (
                <Button className="Button Button--primary" loading={this.working} disabled={this.working} onclick={this.connect.bind(this)}>
                  {trans('connect_button')}
                </Button>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }

  connect() {
    this.call('POST', (result) => {
      app.data.settings[FORUM_ID] = result.forumId;
      app.data.settings[CONNECTED_RELAY_URL] = result.relay;
    });
  }

  disconnect() {
    if (!confirm(trans('disconnect_confirmation'))) return;

    this.call('DELETE', () => {
      delete app.data.settings[FORUM_ID];
      delete app.data.settings[CONNECTED_RELAY_URL];
    });
  }

  // A failure shows Flarum's own alert, with the relay's words.
  call(method, done) {
    this.working = true;

    app
      .request({ method, url: app.forum.attribute('apiUrl') + '/flapp-push/connection' })
      .then(done)
      .finally(() => {
        this.working = false;
        m.redraw();
      });
  }
}
