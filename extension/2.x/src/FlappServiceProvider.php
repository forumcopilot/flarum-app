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
use Flarum\Settings\SettingsRepositoryInterface;
use ForumCopilot\Flapp\Push\PayloadBuilder;
use ForumCopilot\Flapp\Push\RelayClient;
use Symfony\Contracts\Translation\TranslatorInterface;
use GuzzleHttp\Client;

class FlappServiceProvider extends AbstractServiceProvider
{
    public function register()
    {
        // Each type's line, with other extensions' (Extend\PushLines).
        $this->container->singleton('forumcopilot-flapp.push-lines', function () {
            return PayloadBuilder::LINES;
        });

        $this->container->bind(PayloadBuilder::class, function ($container) {
            return new PayloadBuilder(
                $container->make(TranslatorInterface::class),
                $container->make(SettingsRepositoryInterface::class),
                $container->make('forumcopilot-flapp.push-lines')
            );
        });

        $this->container->singleton(RelayClient::class, function () {
            return new RelayClient(new Client([
                'timeout' => RelayClient::TIMEOUT,
                'connect_timeout' => RelayClient::TIMEOUT,
                'http_errors' => false,
            ]));
        });
    }
}
