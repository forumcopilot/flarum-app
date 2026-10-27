<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\integration\api;

use Flarum\Testing\integration\RetrievesAuthorizedUsers;
use Flarum\User\User;
use ForumCopilot\Flapp\Device;
use ForumCopilot\Flapp\Tests\integration\FlappTestCase;

class DevicesTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    protected function setUp(): void
    {
        parent::setUp();

        $this->extension('forumcopilot-flapp');

        $this->prepareDatabase([
            User::class => [
                $this->normalUser(),
                ['id' => 3, 'username' => 'carol', 'email' => 'carol@machine.local', 'is_email_confirmed' => 1],
            ],
        ]);
    }

    protected function register(int $userId, array $body): array
    {
        list($request, $tokenId) = $this->withToken($this->request('POST', '/api/flapp-push/devices', ['json' => $body]), $userId);

        return [$this->send($request), $tokenId];
    }

    protected function device(string $handle, array $overrides = []): array
    {
        return array_merge(['handle' => $handle, 'platform' => 'android', 'app' => 'flapp', 'locale' => 'de'], $overrides);
    }

    public function test_registers_a_device_on_the_header_token(): void
    {
        $this->connected();

        list($response, $tokenId) = $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));

        $this->assertEquals(201, $response->getStatusCode(), (string) $response->getBody());

        $data = $this->json($response)['data'];
        $this->assertEquals('flappDevices', $data['type']);
        $this->assertEquals(['platform' => 'android', 'app' => 'flapp', 'locale' => 'de'], array_intersect_key($data['attributes'], array_flip(['platform', 'app', 'locale'])));
        $this->assertArrayNotHasKey('handle', $data['attributes']);

        $device = Device::query()->findOrFail($data['id']);
        $this->assertEquals(2, $device->user_id);
        $this->assertEquals($tokenId, $device->access_token_id);
        $this->assertEquals('aaaaaaaaaaaaaaaaaaaaaa', $device->handle);
    }

    public function test_needs_a_token_in_the_header(): void
    {
        $this->connected();

        $response = $this->send($this->request('POST', '/api/flapp-push/devices', [
            'authenticatedAs' => 2,
            'json' => $this->device('aaaaaaaaaaaaaaaaaaaaaa'),
        ]));

        $this->assertEquals(422, $response->getStatusCode());
        $this->assertEquals(0, Device::query()->count());
    }

    public function test_guests_cannot_register(): void
    {
        $this->connected();

        // Past the CSRF check, which would stop a guest first.
        $response = $this->send($this->request('POST', '/api/flapp-push/devices', [
            'json' => $this->device('aaaaaaaaaaaaaaaaaaaaaa'),
        ])->withAttribute('bypassCsrfToken', true));

        $this->assertEquals(401, $response->getStatusCode());
    }

    public function test_needs_the_forum_connected(): void
    {
        list($response) = $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));

        $this->assertEquals(422, $response->getStatusCode());
        $this->assertEquals(0, Device::query()->count());
    }

    public function test_reports_every_invalid_field(): void
    {
        $this->connected();

        list($response) = $this->register(2, [
            'handle' => 'short',
            'platform' => 'windows',
            'app' => 'Flapp!',
            'locale' => 'not a language',
        ]);

        $this->assertEquals(422, $response->getStatusCode());

        $pointers = array_map(function ($error) {
            return $error['source']['pointer'];
        }, $this->json($response)['errors']);

        sort($pointers);

        $this->assertEquals(['/data/attributes/app', '/data/attributes/handle', '/data/attributes/locale', '/data/attributes/platform'], $pointers);
    }

    public function test_the_language_is_optional(): void
    {
        $this->connected();

        list($response) = $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa', ['locale' => null]));

        $this->assertEquals(201, $response->getStatusCode(), (string) $response->getBody());
        $this->assertNull(Device::query()->firstOrFail()->locale);
    }

    public function test_registering_a_handle_again_moves_it(): void
    {
        $this->connected();

        $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));
        list($response, $tokenId) = $this->register(3, $this->device('aaaaaaaaaaaaaaaaaaaaaa', ['platform' => 'ios']));

        $this->assertEquals(201, $response->getStatusCode());
        $this->assertEquals(1, Device::query()->count());

        $device = Device::query()->firstOrFail();
        $this->assertEquals(3, $device->user_id);
        $this->assertEquals($tokenId, $device->access_token_id);
        $this->assertEquals('ios', $device->platform);
    }

    public function test_keeps_the_newest_devices_up_to_the_limit(): void
    {
        $this->connected();

        for ($i = 0; $i <= Device::LIMIT; $i++) {
            $this->register(2, $this->device(str_pad("handle$i", 22, 'x')));
        }

        $handles = Device::query()->where('user_id', 2)->pluck('handle')->all();

        $this->assertCount(Device::LIMIT, $handles);
        $this->assertNotContains(str_pad('handle0', 22, 'x'), $handles);
        $this->assertContains(str_pad('handle'.Device::LIMIT, 22, 'x'), $handles);
    }

    public function test_a_reader_deletes_their_device(): void
    {
        $this->connected();

        list($response) = $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));
        $id = $this->json($response)['data']['id'];

        $response = $this->send($this->request('DELETE', "/api/flapp-push/devices/$id", ['authenticatedAs' => 2]));

        $this->assertEquals(204, $response->getStatusCode());
        $this->assertEquals(0, Device::query()->count());
    }

    public function test_another_readers_device_is_not_found(): void
    {
        $this->connected();

        list($response) = $this->register(3, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));
        $id = $this->json($response)['data']['id'];

        $response = $this->send($this->request('DELETE', "/api/flapp-push/devices/$id", ['authenticatedAs' => 2]));

        $this->assertEquals(404, $response->getStatusCode());
        $this->assertEquals(1, Device::query()->count());
    }

    public function test_the_device_goes_with_its_token(): void
    {
        $this->connected();

        // flarum/testing runs each test in a transaction, and SQLite can't
        // turn foreign keys on inside one. The other databases check this.
        if ($this->database()->getDriverName() === 'sqlite') {
            $this->markTestSkipped('SQLite runs these tests without foreign keys.');
        }

        list(, $tokenId) = $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));
        $this->register(2, $this->device('bbbbbbbbbbbbbbbbbbbbbb'));

        $this->database()->table('access_tokens')->where('id', $tokenId)->delete();

        $this->assertEquals(['bbbbbbbbbbbbbbbbbbbbbb'], Device::query()->pluck('handle')->all());
    }

    public function test_the_reader_sees_their_own_device_count_only(): void
    {
        $this->connected();

        $this->register(2, $this->device('aaaaaaaaaaaaaaaaaaaaaa'));

        $own = $this->json($this->send($this->request('GET', '/api/users/2', ['authenticatedAs' => 2])));
        $other = $this->json($this->send($this->request('GET', '/api/users/2', ['authenticatedAs' => 3])));

        $this->assertSame(1, $own['data']['attributes']['flappDeviceCount']);
        $this->assertArrayNotHasKey('flappDeviceCount', $other['data']['attributes']);
    }
}
