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

use Flarum\Api\Serializer\CurrentUserSerializer;
use Flarum\Api\Serializer\ForumSerializer;
use Flarum\Extend;
use Flarum\Extension\Event\Disabling;
use Flarum\Notification\Event\DeletedAll;
use Flarum\Notification\Event\Read;
use Flarum\Notification\Event\ReadAll;
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

    // Every type gets a Flapp box, not only alertable ones. The defaults are
    // worked out per type in the driver.
    (new Extend\Notification())
        ->driver('flapp', Notification\FlappNotificationDriver::class),

    (new Extend\Model(User::class))
        ->hasMany('flappDevices', Device::class, 'user_id'),

    // Flarum 1.x only: 2.0 adds these through ApiResource.
    (new Extend\ApiSerializer(ForumSerializer::class))
        ->attributes(Api\ForumAttributes::class),

    (new Extend\ApiSerializer(CurrentUserSerializer::class))
        ->attributes(Api\CurrentUserAttributes::class),

    (new Extend\ServiceProvider())
        ->register(FlappServiceProvider::class),

    // Reading notifications, on the web or in the app, updates the badge.
    (new Extend\Event())
        ->listen(Disabling::class, Listener\DisconnectWhenDisabled::class)
        ->listen(Read::class, Listener\SendUnreadWhenRead::class)
        ->listen(ReadAll::class, Listener\SendUnreadWhenRead::class)
        ->listen(DeletedAll::class, Listener\SendUnreadWhenRead::class),
];
