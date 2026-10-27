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
use Flarum\Queue\AbstractJob;
use Flarum\User\User;
use ForumCopilot\Flapp\Push\Pusher;

/**
 * One notification's pushes, queued by the driver. Most forums run the sync
 * queue, so this usually runs at once, inside the request that caused it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class SendPushesJob extends AbstractJob
{
    /**
     * @var BlueprintInterface
     */
    protected $blueprint;

    /**
     * @var User[]
     */
    protected $recipients;

    /**
     * @param User[] $recipients
     */
    public function __construct(BlueprintInterface $blueprint, array $recipients)
    {
        parent::__construct();

        $this->blueprint = $blueprint;
        $this->recipients = $recipients;
    }

    public function handle(Pusher $pusher): void
    {
        $pusher->send($this->blueprint, $this->recipients);
    }
}
