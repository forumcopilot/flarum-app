<?php
// Deletes flarum/messages dialogs (2.0) on a test forum by id, with their messages: members can't
// delete their own messages by default, and dialogs have no delete endpoint. The write recorder's
// cleanup runs it:
//
//   sudo -u www-data php tool/test_forums/delete_dialogs.php /var/www/flarumapp/flarum2 2

use Flarum\Messages\Dialog;

[, $dir] = $argv;
$ids = array_slice($argv, 2);
chdir($dir);
$site = require "$dir/site.php";
$site->bootApp();

foreach ($ids as $id) {
    $dialog = Dialog::find($id);
    if (! $dialog) {
        echo "dialog $id: not there\n";
        continue;
    }
    // Its messages, its people and their read state go with it (the tables' foreign keys).
    $dialog->delete();
    echo "dialog $id: deleted\n";
}
