<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

use Flarum\Database\Migration;
use Illuminate\Database\Schema\Blueprint;

// The forum's private signing key. Not a setting: Flarum sends every setting
// to the admin page.
return Migration::createTable(
    'flapp_keys',
    function (Blueprint $table) {
        $table->string('forum_id', 64)->primary();
        $table->text('private_key');
        $table->dateTime('created_at');
    }
);
