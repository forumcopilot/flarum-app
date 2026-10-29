<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\SignIn;

/**
 * The apps a member may sign in to through this forum, each with the only
 * address the sign-in may be sent to. The page names the app from here, never
 * from the request, so a request can't call itself Flapp.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class Apps
{
    const APPS = [
        'flapp' => ['name' => 'Flapp', 'redirect' => 'flapp://auth'],
    ];

    /**
     * @return array|null the app's name and redirect, or null for an app this
     *                    forum doesn't know
     */
    public static function find(?string $id): ?array
    {
        return $id !== null && isset(self::APPS[$id]) ? self::APPS[$id] : null;
    }
}
