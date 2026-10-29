import app from 'flarum/forum/app';
import { extend } from 'flarum/common/extend';
import AuthorizePage from './components/AuthorizePage';

app.initializers.add('forumcopilot-flapp', () => {
  // Where an app signs in through this forum (extend.php names the route).
  app.routes['flapp.authorize'] = { path: '/flapp/authorize', component: AuthorizePage };

  // The Flapp column, for readers with a Flapp device on this forum only, so
  // the grid doesn't change for anyone else. Flarum 2.0 loads the settings
  // page on demand, hence the module name.
  extend('flarum/forum/components/NotificationGrid', 'notificationMethods', function (items) {
    if (!(this.attrs.user.attribute('flappDeviceCount') > 0)) return;

    items.add('flapp', {
      name: 'flapp',
      icon: 'fas fa-mobile-alt',
      label: app.translator.trans('forumcopilot-flapp.forum.settings.notify_by_flapp_heading'),
    });
  });
});
