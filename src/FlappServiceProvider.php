<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp;

use Flarum\Foundation\AbstractServiceProvider;
use ForumCopilot\Flapp\Push\RelayClient;
use GuzzleHttp\Client;

class FlappServiceProvider extends AbstractServiceProvider
{
    public function register()
    {
        $this->container->singleton(RelayClient::class, function () {
            return new RelayClient(new Client([
                'timeout' => RelayClient::TIMEOUT,
                'connect_timeout' => RelayClient::TIMEOUT,
                'http_errors' => false,
            ]));
        });
    }
}
