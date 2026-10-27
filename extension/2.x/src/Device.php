<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp;

use Flarum\Database\AbstractModel;
use Flarum\User\User;

/**
 * A phone that gets the reader's pushes from this forum.
 *
 * It hangs on the access token that registered it: when the token goes (the
 * app logs out, the reader ends that session on the website, the account is
 * deleted), the database removes the device too.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 *
 * @property int $id
 * @property int $user_id
 * @property int $access_token_id
 * @property string $handle
 * @property string $platform
 * @property string $app
 * @property string|null $locale
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon|null $last_sent_at
 * @property User $user
 */
class Device extends AbstractModel
{
    /**
     * The most devices a reader can have on one forum. Registering another
     * drops the oldest.
     */
    const LIMIT = 10;

    const PLATFORMS = ['android', 'ios'];

    protected $table = 'flapp_devices';

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'access_token_id' => 'integer',
        'created_at' => 'datetime',
        'last_sent_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
