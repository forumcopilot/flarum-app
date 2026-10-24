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

use Flarum\Api\Schema;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Push\RelayClient;

/**
 * flappPush on GET /api, for everyone, guests included: the app reads it to
 * know the forum pushes, and where to get a handle. Absent until connected.
 *
 * Flarum 2.0 only.
 */
class ForumResourceFields
{
    public function __construct(
        private readonly Connection $connection
    ) {
    }

    public function __invoke(): array
    {
        return [
            Schema\Arr::make('flappPush')
                ->visible(fn () => $this->connection->isConnected())
                ->get(fn () => [
                    'relay' => $this->connection->connectedRelayUrl(),
                    'forumId' => $this->connection->forumId(),
                    'version' => RelayClient::PROTOCOL_VERSION,
                ]),
        ];
    }
}
