<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Api;

use Flarum\Api\Context;
use Flarum\Api\Schema;
use Flarum\User\User;
use ForumCopilot\Flapp\Device;

/**
 * How many Flapp devices the reader has here, on their own user record only.
 * The web's notification grid shows the Flapp column when there are any.
 *
 * Flarum 2.0 only.
 */
class UserResourceFields
{
    public function __invoke(): array
    {
        return [
            Schema\Integer::make('flappDeviceCount')
                ->visible(fn (User $user, Context $context) => $context->getActor()->is($user))
                ->get(fn (User $user) => Device::query()->where('user_id', $user->id)->count()),
        ];
    }
}
