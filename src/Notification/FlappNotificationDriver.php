<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Notification;

use Flarum\Notification\Blueprint\BlueprintInterface;
use Flarum\Notification\Driver\NotificationDriverInterface;
use Flarum\User\User;

/**
 * The Flapp delivery method: a notify_<type>_flapp setting for every type,
 * shown as the Flapp column of the reader's notification settings.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class FlappNotificationDriver implements NotificationDriverInterface
{
    /**
     * Types that are on by default though they have no Web alert to follow:
     * Flarum 2.0's private messages.
     */
    const ALSO_ON_BY_DEFAULT = ['messageReceived'];

    public function send(BlueprintInterface $blueprint, array $users): void
    {
        // Sending comes with the relay's push endpoint (milestone 3).
    }

    /**
     * Every type gets the setting, alertable or not. It is on by default
     * where the Web alert is, worked out here rather than in the extender so
     * it covers types from extensions that load after this one.
     */
    public function registerType(string $blueprintClass, array $driversEnabledByDefault): void
    {
        $type = $blueprintClass::getType();

        User::registerPreference(
            User::getNotificationPreferenceKey($type, 'flapp'),
            'boolval',
            in_array('alert', $driversEnabledByDefault, true)
                || in_array('flapp', $driversEnabledByDefault, true)
                || in_array($type, self::ALSO_ON_BY_DEFAULT, true)
        );
    }
}
