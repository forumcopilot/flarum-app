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
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Device;
use Illuminate\Contracts\Container\Container;
use Illuminate\Contracts\Queue\Queue;

/**
 * The Flapp delivery method: a notify_<type>_flapp setting for every type,
 * shown as the Flapp column of the reader's notification settings, and the
 * pushes to the readers who ticked it.
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

    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var Container
     */
    protected $container;

    public function __construct(Connection $connection, Container $container)
    {
        $this->connection = $connection;
        $this->container = $container;
    }

    /**
     * Flarum hands over the notification's new recipients only, already
     * limited to those who may see it. Of those, the readers who ticked Flapp
     * for the type and have a device here get one queued job between them.
     */
    public function send(BlueprintInterface $blueprint, array $users): void
    {
        if (! $users || ! $this->connection->isConnected()) {
            return;
        }

        $key = User::getNotificationPreferenceKey($blueprint::getType(), 'flapp');
        $wanting = [];

        foreach ($users as $user) {
            if ($user->getPreference($key)) {
                $wanting[$user->id] = $user;
            }
        }

        if (! $wanting) {
            return;
        }

        $withDevices = Device::query()->whereIn('user_id', array_keys($wanting))->distinct()->pluck('user_id')->all();
        $recipients = array_values(array_intersect_key($wanting, array_flip($withDevices)));

        if ($recipients) {
            // Resolved now, not when the driver is made at boot: Flarum 2.0
            // wraps the queue for routing after the drivers are built.
            $this->container->make(Queue::class)->push(new SendPushesJob($blueprint, $recipients));
        }
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
