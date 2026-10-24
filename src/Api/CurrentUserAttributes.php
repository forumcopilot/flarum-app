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

use Flarum\Api\Serializer\CurrentUserSerializer;
use Flarum\User\User;
use ForumCopilot\Flapp\Device;

/**
 * How many Flapp devices the reader has here, on their own user record only
 * (CurrentUserSerializer). The web's notification grid shows the Flapp column
 * when there are any.
 *
 * Flarum 1.x only.
 */
class CurrentUserAttributes
{
    public function __invoke(CurrentUserSerializer $serializer, User $user, array $attributes): array
    {
        return [
            'flappDeviceCount' => Device::query()->where('user_id', $user->id)->count(),
        ];
    }
}
