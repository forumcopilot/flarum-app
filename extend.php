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

use Flarum\Api\Resource\ForumResource;
use Flarum\Api\Resource\UserResource;
use Flarum\Extend;
use Flarum\Extension\Event\Disabling;
use Flarum\User\User;

return [
    (new Extend\Frontend('forum'))
        ->js(__DIR__.'/js/dist/forum.js'),

    (new Extend\Frontend('admin'))
        ->js(__DIR__.'/js/dist/admin.js'),

    new Extend\Locales(__DIR__.'/locale'),

    (new Extend\Routes('api'))
        ->post('/flapp-push/devices', 'flapp.devices.create', Api\Controller\CreateDeviceController::class)
        ->delete('/flapp-push/devices/{id}', 'flapp.devices.delete', Api\Controller\DeleteDeviceController::class)
        ->post('/flapp-push/connection', 'flapp.connection.create', Api\Controller\ConnectController::class)
        ->delete('/flapp-push/connection', 'flapp.connection.delete', Api\Controller\DisconnectController::class),

    // Every type gets a Flapp box, not only alertable ones, so 2.0's messages
    // reach the phone too. The defaults are worked out per type in the driver.
    (new Extend\Notification())
        ->driver('flapp', Notification\FlappNotificationDriver::class),

    (new Extend\Model(User::class))
        ->hasMany('flappDevices', Device::class, 'user_id'),

    // Flarum 2.0 only: 1.x adds these through ApiSerializer.
    (new Extend\ApiResource(ForumResource::class))
        ->fields(Api\ForumResourceFields::class),

    (new Extend\ApiResource(UserResource::class))
        ->fields(Api\UserResourceFields::class),

    (new Extend\ServiceProvider())
        ->register(FlappServiceProvider::class),

    (new Extend\Event())
        ->listen(Disabling::class, Listener\DisconnectWhenDisabled::class),
];
