<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\integration;

use Flarum\Testing\integration\RetrievesAuthorizedUsers;
use Flarum\User\User;

class NotificationSettingsTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    protected function setUp(): void
    {
        parent::setUp();

        $this->prepareDatabase([
            User::class => [$this->normalUser()],
        ]);
    }

    protected function preferences(): array
    {
        $response = $this->send($this->request('GET', '/api/users/2', ['authenticatedAs' => 2]));

        return $this->json($response)['data']['attributes']['preferences'];
    }

    public function test_every_type_gets_a_flapp_setting_on_where_the_web_alert_is(): void
    {
        $this->extension('flarum-mentions', 'flarum-subscriptions', 'flarum-messages', 'forumcopilot-flapp');

        $preferences = $this->preferences();

        foreach (['discussionRenamed', 'postMentioned', 'userMentioned', 'newPost'] as $type) {
            $this->assertArrayHasKey("notify_{$type}_alert", $preferences, "$type has a Web alert");
            $this->assertSame($preferences["notify_{$type}_alert"], $preferences["notify_{$type}_flapp"], "$type follows its Web alert");
        }
    }

    public function test_messages_get_push_though_they_have_no_web_alert(): void
    {
        $this->extension('flarum-mentions', 'flarum-messages', 'forumcopilot-flapp');

        $preferences = $this->preferences();

        $this->assertArrayNotHasKey('notify_messageReceived_alert', $preferences);
        $this->assertTrue($preferences['notify_messageReceived_flapp']);
    }

    public function test_a_reader_turns_a_type_off(): void
    {
        $this->extension('forumcopilot-flapp');

        $response = $this->send($this->request('PATCH', '/api/users/2', [
            'authenticatedAs' => 2,
            'json' => ['data' => ['type' => 'users', 'id' => '2', 'attributes' => ['preferences' => ['notify_discussionRenamed_flapp' => false]]]],
        ]));

        $this->assertEquals(200, $response->getStatusCode(), (string) $response->getBody());
        $this->assertFalse($this->preferences()['notify_discussionRenamed_flapp']);
    }
}
