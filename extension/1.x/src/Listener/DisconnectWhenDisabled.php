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

use Flarum\Extension\Event\Disabling;
use ForumCopilot\Flapp\Connector;

/**
 * Disabling the extension disconnects the forum, so the relay forgets it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class DisconnectWhenDisabled
{
    const EXTENSION_ID = 'forumcopilot-flapp';

    /**
     * @var Connector
     */
    protected $connector;

    public function __construct(Connector $connector)
    {
        $this->connector = $connector;
    }

    public function handle(Disabling $event): void
    {
        if ($event->extension->getId() === self::EXTENSION_ID) {
            $this->connector->disconnect();
        }
    }
}
