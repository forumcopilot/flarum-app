<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Listener;

use Flarum\User\User;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Device;
use ForumCopilot\Flapp\Notification\SendUnreadJob;
use Illuminate\Contracts\Container\Container;
use Illuminate\Contracts\Queue\Queue;

/**
 * The reader read a notification, all of them, or (Flarum 2.0) a
 * conversation, or deleted them all: their phones' badges should follow, on
 * the web as in the app. Each such event names the reader differently.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class SendUnreadWhenRead
{
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

    public function handle($event): void
    {
        $userId = $this->readerId($event);

        if ($userId === null || ! $this->connection->isConnected() || ! Device::query()->where('user_id', $userId)->exists()) {
            return;
        }

        $this->container->make(Queue::class)->push(new SendUnreadJob($userId));
    }

    protected function readerId($event): ?int
    {
        // Read and ReadAll: the actor. DeletedAll: the user.
        foreach (['actor', 'user'] as $property) {
            if (isset($event->$property) && $event->$property instanceof User) {
                return (int) $event->$property->id;
            }
        }

        // Flarum 2.0's Dialog\Event\UserRead: the reader's state in the conversation.
        if (isset($event->state) && isset($event->state->user_id)) {
            return (int) $event->state->user_id;
        }

        return null;
    }
}
