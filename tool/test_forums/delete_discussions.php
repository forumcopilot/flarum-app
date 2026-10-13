<?php
// Deletes discussions on a test forum by id, private ones (fof/byobu) included: byobu hides those
// even from an admin who isn't in them, so the API can't. The write recorder's cleanup runs it:
//
//   sudo -u www-data php tool/test_forums/delete_discussions.php /var/www/flarumapp/flarum1 60 61
//
// Each discussion goes with its posts and notifications (the model's own deletion), and the
// counts of the people who posted in it are worked out again.

use Flarum\Discussion\Discussion;
use Flarum\User\User;

[, $dir] = $argv;
$ids = array_slice($argv, 2);
chdir($dir);
$site = require "$dir/site.php";
$site->bootApp();

foreach ($ids as $id) {
    $discussion = Discussion::find($id);
    if (! $discussion) {
        echo "$id: not there\n";
        continue;
    }
    $posters = User::whereIn('id', $discussion->posts()->pluck('user_id'))->get();
    $discussion->delete();
    foreach ($posters as $user) {
        $user->refreshDiscussionCount()->refreshCommentCount()->save();
    }
    echo "$id: deleted\n";
}
