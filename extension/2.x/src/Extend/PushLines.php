<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Extend;

use Flarum\Extend\ExtenderInterface;
use Flarum\Extension\Extension;
use Illuminate\Contracts\Container\Container;

/**
 * Gives a notification type the words of its push: the translation key of
 * the web's line for it, where {username} is whoever acted. An extension
 * whose types have no line here otherwise gets their email subject, or
 * "New notification".
 *
 *     (new \ForumCopilot\Flapp\Extend\PushLines())
 *         ->line('postBookmarked', 'acme-bookmarks.forum.notifications.post_bookmarked_text'),
 *
 * Nothing happens on a forum without the Flapp extension, though the class
 * must be there to use it: check class_exists() first, or require the
 * extension.
 */
class PushLines implements ExtenderInterface
{
    /**
     * @var array<string, string>
     */
    protected $lines = [];

    public function line(string $type, string $translationKey): self
    {
        $this->lines[$type] = $translationKey;

        return $this;
    }

    public function extend(Container $container, ?Extension $extension = null): void
    {
        $lines = $this->lines;

        $container->extend('forumcopilot-flapp.push-lines', function (array $existing) use ($lines) {
            return array_merge($existing, $lines);
        });
    }
}
