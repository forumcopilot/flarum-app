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

use Flarum\Queue\AbstractJob;
use Flarum\User\User;
use ForumCopilot\Flapp\Push\Pusher;

/**
 * The reader's new unread count, after they read notifications, for their
 * phones' badges. Queued by SendUnreadWhenRead.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class SendUnreadJob extends AbstractJob
{
    /**
     * @var int
     */
    protected $userId;

    public function __construct(int $userId)
    {
        parent::__construct();

        $this->userId = $userId;
    }

    public function handle(Pusher $pusher): void
    {
        $user = User::query()->find($this->userId);

        if ($user) {
            $pusher->sendUnread($user);
        }
    }
}
