<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Push;

use Flarum\User\User;

/**
 * The reader's unread notifications, plus their unread conversations where
 * Flarum 2.0's messages run: the relay adds these up over the phone's forums
 * for the iPhone badge.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class UnreadCount
{
    public static function of(User $user): int
    {
        $count = (int) $user->getUnreadNotificationCount();

        if (class_exists('Flarum\Messages\UserDialogState')) {
            try {
                $count += \Flarum\Messages\UserDialogState::query()
                    ->join('dialogs', 'dialogs.id', '=', 'dialog_user.dialog_id')
                    ->where('dialog_user.user_id', $user->id)
                    ->whereColumn('dialog_user.last_read_message_id', '<', 'dialogs.last_message_id')
                    ->count();
            } catch (\Throwable $e) {
                // Installed but not enabled: no tables to count.
            }
        }

        return $count;
    }
}
