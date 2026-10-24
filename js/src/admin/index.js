import app from 'flarum/admin/app';
import FlappPage from './components/FlappPage';

app.initializers.add('forumcopilot-flapp', () => {
  app.registry.for('forumcopilot-flapp').registerPage(FlappPage);
});
