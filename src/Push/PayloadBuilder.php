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

use Carbon\Carbon;
use Carbon\CarbonInterface;
use Flarum\Discussion\Discussion;
use Flarum\Notification\Blueprint\BlueprintInterface;
use Flarum\Notification\MailableInterface;
use Flarum\Notification\Notification;
use Flarum\Post\Post;
use Flarum\Settings\SettingsRepositoryInterface;
use Flarum\User\User;
use Symfony\Contracts\Translation\LocaleAwareInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * Writes one reader's push for a notification, in their language and in
 * Flarum's own words:
 *
 *     {v, id?, type, title, body, excerpt?, open?, unread}
 *
 * The body is the web's line for the type from the forum's language packs;
 * failing that the type's email subject; failing that "New notification".
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class PayloadBuilder
{
    const VERSION = 1;

    const EXCERPT_LENGTH = 140;

    /**
     * The web's own line for each type; {username} is whoever acted. A key the
     * forum doesn't have (its extension isn't installed) falls through to the
     * email subject.
     */
    const LINES = [
        'discussionRenamed' => 'core.forum.notifications.discussion_renamed_text',
        'discussionLocked' => 'flarum-lock.forum.notifications.discussion_locked_text',
        'postLiked' => 'flarum-likes.forum.notifications.post_liked_text',
        'postMentioned' => 'flarum-mentions.forum.notifications.post_mentioned_text',
        'userMentioned' => 'flarum-mentions.forum.notifications.user_mentioned_text',
        'groupMentioned' => 'flarum-mentions.forum.notifications.group_mentioned_text',
        'newPost' => 'flarum-subscriptions.forum.notifications.new_post_text',
        'userUnsuspended' => 'flarum-suspend.forum.notifications.user_unsuspended_text',
        'byobuPrivateDiscussionCreated' => 'fof-byobu.forum.notifications.pd_text',
        'byobuPrivateDiscussionReplied' => 'fof-byobu.forum.notifications.pd_reply_text',
        'byobuPrivateDiscussionAdded' => 'fof-byobu.forum.notifications.pd_added_text',
        'newDiscussionInTag' => 'fof-follow-tags.forum.notifications.new_discussion_text',
        'newPostInTag' => 'fof-follow-tags.forum.notifications.new_post_text',
        'newDiscussionTag' => 'fof-follow-tags.forum.notifications.new_discussion_tag_text',
        'awardedBestAnswer' => 'fof-best-answer.forum.notification.awarded',
        'bestAnswerInDiscussion' => 'fof-best-answer.forum.notification.best_answer_in_discussion',
    ];

    /**
     * Types whose push quotes the post or message it opens. A like quotes
     * nothing: the post is the reader's own.
     */
    const EXCERPTED = [
        'postMentioned', 'userMentioned', 'groupMentioned', 'newPost', 'newPostInTag', 'newDiscussionInTag',
        'byobuPrivateDiscussionCreated', 'byobuPrivateDiscussionReplied', 'messageReceived',
    ];

    /**
     * @var TranslatorInterface
     */
    protected $translator;

    /**
     * @var SettingsRepositoryInterface
     */
    protected $settings;

    public function __construct(TranslatorInterface $translator, SettingsRepositoryInterface $settings)
    {
        $this->translator = $translator;
        $this->settings = $settings;
    }

    public function build(BlueprintInterface $blueprint, User $user): array
    {
        // In the reader's language, as Flarum's notification emails are.
        $locale = $this->locale($user);
        $previous = null;

        if ($this->translator instanceof LocaleAwareInterface && $locale !== null) {
            $previous = $this->translator->getLocale();
            $this->translator->setLocale($locale);
        }

        try {
            $subject = $blueprint->getSubject();
            list($open, $source) = $this->opens($blueprint, $subject);

            $payload = ['v' => self::VERSION];

            $id = Notification::query()->matchingBlueprint($blueprint)->where('user_id', $user->id)->value('id');
            if ($id !== null) {
                $payload['id'] = (int) $id;
            }

            $payload['type'] = $blueprint::getType();
            $payload['title'] = $this->cut($this->title($subject), 200);
            $payload['body'] = $this->cut($this->body($blueprint, $locale), 500);

            $excerpt = in_array($payload['type'], self::EXCERPTED, true) ? $this->excerpt($source) : null;
            if ($excerpt !== null) {
                $payload['excerpt'] = $excerpt;
            }

            if ($open !== null) {
                $payload['open'] = $open;
            }

            $payload['unread'] = UnreadCount::of($user);

            return $payload;
        } finally {
            if ($previous !== null) {
                $this->translator->setLocale($previous);
            }
        }
    }

    protected function locale(User $user): ?string
    {
        $locale = $user->getPreference('locale') ?: $this->settings->get('default_locale');

        return is_string($locale) && $locale !== '' ? $locale : null;
    }

    /**
     * The discussion's title, or the forum's when there is none.
     */
    protected function title($subject): string
    {
        if ($subject instanceof Discussion) {
            return (string) $subject->title;
        }

        if ($subject instanceof Post && $subject->discussion) {
            return (string) $subject->discussion->title;
        }

        return (string) $this->settings->get('forum_title');
    }

    protected function body(BlueprintInterface $blueprint, ?string $locale): string
    {
        $type = $blueprint::getType();

        if ($type === 'userSuspended') {
            return $this->suspended($blueprint->getSubject(), $locale);
        }

        if (isset(self::LINES[$type])) {
            $from = $blueprint->getFromUser();
            $username = $from ? $from->display_name : $this->translator->trans('core.lib.username.deleted_text');
            $line = $this->line(self::LINES[$type], ['username' => $username]);

            if ($line !== null) {
                return $line;
            }
        }

        if ($blueprint instanceof MailableInterface) {
            $subject = trim((string) $blueprint->getEmailSubject($this->translator));

            if ($subject !== '') {
                return $subject;
            }
        }

        return $this->translator->trans('forumcopilot-flapp.push.new_notification');
    }

    /**
     * "You have been suspended for 3 days", worked out as the web does; a
     * suspension to 2038 or later is indefinite, as flarum/suspend sets it.
     */
    protected function suspended($user, ?string $locale): string
    {
        $until = $user instanceof User ? $user->suspended_until : null;

        if ($until === null || Carbon::instance($until)->year >= 2038) {
            return (string) $this->line('flarum-suspend.forum.notifications.user_suspended_indefinite_text', []);
        }

        $time = Carbon::instance($until)->locale($locale ?: 'en')->diffForHumans(Carbon::now(), CarbonInterface::DIFF_ABSOLUTE);

        return (string) $this->line('flarum-suspend.forum.notifications.user_suspended_text', ['timeReadable' => $time]);
    }

    /**
     * What a tap opens, and the post or message the push may quote.
     *
     * @return array the open object (or null) and the source (or null)
     */
    protected function opens(BlueprintInterface $blueprint, $subject): array
    {
        $data = $blueprint->getData();
        $data = is_array($data) ? $data : [];

        if ($subject instanceof Post) {
            // A reply to the reader's post: the subject is their post, the
            // data names the reply. Flarum 1.8 gives only its number; the
            // reply is in the same discussion.
            if (isset($data['replyNumber'])) {
                $discussionId = isset($data['discussionId']) ? $data['discussionId'] : $subject->discussion_id;

                return [
                    $this->open(['discussion' => $discussionId, 'post' => $data['replyNumber']]),
                    $this->post($discussionId, $data['replyNumber']),
                ];
            }

            return [$this->open(['discussion' => $subject->discussion_id, 'post' => $subject->number]), $subject];
        }

        if ($subject instanceof Discussion) {
            if (isset($data['postNumber'])) {
                return [
                    $this->open(['discussion' => $subject->id, 'post' => $data['postNumber']]),
                    $this->post($subject->id, $data['postNumber']),
                ];
            }

            return [$this->open(['discussion' => $subject->id]), null];
        }

        if ($subject instanceof User) {
            return [$this->open(['user' => $subject->id]), null];
        }

        // Flarum 2.0's private messages.
        if ($subject !== null && get_class($subject) === 'Flarum\Messages\DialogMessage') {
            return [$this->open(['dialog' => $subject->dialog_id]), $subject];
        }

        return [null, null];
    }

    /**
     * @return array|null the ids as integers, or null if any is missing
     */
    protected function open(array $ids)
    {
        foreach ($ids as $key => $id) {
            if ((int) $id < 1) {
                return null;
            }

            $ids[$key] = (int) $id;
        }

        return $ids;
    }

    protected function post($discussionId, $number)
    {
        return Post::query()->where('discussion_id', $discussionId)->where('number', $number)->first();
    }

    /**
     * The first 140 characters of the post or message, as plain text.
     */
    protected function excerpt($source): ?string
    {
        if ($source === null || ! method_exists($source, 'formatContent')) {
            return null;
        }

        try {
            $html = (string) $source->formatContent();
        } catch (\Throwable $e) {
            return null;
        }

        // A space before every tag, so paragraphs don't run together.
        $text = html_entity_decode(strip_tags(str_replace('<', ' <', $html)), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = trim((string) preg_replace('/\s+/u', ' ', $text));

        return $text === '' ? null : $this->cut($text, self::EXCERPT_LENGTH);
    }

    /**
     * The translation, or null when the forum has no such key.
     */
    protected function line(string $key, array $parameters)
    {
        $line = $this->translator->trans($key, $parameters);

        return $line === $key ? null : $line;
    }

    protected function cut(string $text, int $length): string
    {
        return mb_strlen($text) > $length ? rtrim(mb_substr($text, 0, $length - 1)).'…' : $text;
    }
}
