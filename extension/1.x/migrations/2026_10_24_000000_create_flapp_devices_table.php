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

// A device goes with its access token and its user, so a sign-in ended on the
// forum stops its pushes even if the app never hears.
return Migration::createTable(
    'flapp_devices',
    function (Blueprint $table) {
        $table->increments('id');
        $table->unsignedInteger('user_id');
        $table->unsignedInteger('access_token_id');
        $table->string('handle', 128)->unique();
        $table->string('platform', 10);
        $table->string('app', 40);
        $table->string('locale', 30)->nullable();
        $table->dateTime('created_at');
        $table->dateTime('last_sent_at')->nullable();

        $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        $table->foreign('access_token_id')->references('id')->on('access_tokens')->onDelete('cascade');
    }
);
