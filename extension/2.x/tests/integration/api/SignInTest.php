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
use ForumCopilot\Flapp\Tests\integration\FlappTestCase;

class SignInTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    /**
     * One key for the whole class: making RSA keys is slow.
     *
     * @var array|null the PEMs, 'public' and 'private'
     */
    protected static $keys;

    protected function setUp(): void
    {
        parent::setUp();

        $this->extension('forumcopilot-flapp');

        $this->prepareDatabase([
            User::class => [$this->normalUser()],
        ]);
    }

    protected static function keys(): array
    {
        if (self::$keys === null) {
            $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
            openssl_pkey_export($key, $private);
            self::$keys = ['public' => openssl_pkey_get_details($key)['key'], 'private' => $private];
        }

        return self::$keys;
    }

    protected function body(array $overrides = []): array
    {
        return array_merge(['app' => 'flapp', 'publicKey' => self::keys()['public'], 'nonce' => 'abcdefghijklmnop0123'], $overrides);
    }

    protected function approve(array $options): array
    {
        $response = $this->send($this->request('POST', '/api/flapp-auth/approve', $options));

        return [$response, $this->json($response)];
    }

    public function test_get_api_offers_browser_sign_in_whether_or_not_connected(): void
    {
        $response = $this->send($this->request('GET', '/api'));

        $attributes = $this->json($response)['data']['attributes'];
        $this->assertArrayNotHasKey('flappPush', $attributes);
        $this->assertEquals(1, $attributes['flappSignIn']['version']);
        $this->assertStringEndsWith('/flapp/authorize', $attributes['flappSignIn']['authorizeUrl']);
    }

    public function test_approving_hands_the_app_a_remember_token_encrypted_to_its_key(): void
    {
        list($response, $json) = $this->approve(['authenticatedAs' => 2, 'json' => $this->body()]);

        $this->assertEquals(200, $response->getStatusCode(), (string) $response->getBody());

        $prefix = 'flapp://auth?payload=';
        $this->assertStringStartsWith($prefix, $json['redirect']);

        $encrypted = base64_decode(rawurldecode(substr($json['redirect'], strlen($prefix))));
        $this->assertTrue(openssl_private_decrypt($encrypted, $plain, self::keys()['private'], OPENSSL_PKCS1_OAEP_PADDING));

        $payload = json_decode($plain, true);
        $this->assertEquals(1, $payload['v']);
        $this->assertEquals(2, $payload['userId']);
        $this->assertEquals('abcdefghijklmnop0123', $payload['nonce']);
        $this->assertEquals('flarum', $payload['cookiePrefix']);

        $token = $this->database()->table('access_tokens')->where('token', $payload['token'])->first();
        $this->assertNotNull($token);
        $this->assertEquals(2, $token->user_id);
        $this->assertEquals('session_remember', $token->type);

        // The app signs in with it as a header token.
        $api = $this->send($this->request('GET', '/api')->withHeader('Authorization', 'Token '.$payload['token']));
        $this->assertEquals('2', $this->json($api)['data']['relationships']['actor']['data']['id']);
    }

    public function test_a_guest_cannot_approve(): void
    {
        // Past the CSRF check, which refuses a guest's call before this does.
        $request = $this->request('POST', '/api/flapp-auth/approve', ['json' => $this->body()])->withAttribute('bypassCsrfToken', true);

        $this->assertEquals(401, $this->send($request)->getStatusCode());
    }

    public function test_a_call_with_a_token_cannot_approve(): void
    {
        list($request) = $this->withToken($this->request('POST', '/api/flapp-auth/approve', ['json' => $this->body()]), 2);

        $this->assertEquals(403, $this->send($request)->getStatusCode());
    }

    public function test_a_session_without_its_csrf_token_cannot_approve(): void
    {
        // The member's remember cookie, as a browser sends it, without the
        // page's CSRF token: a page elsewhere can't approve for them.
        $request = $this->request('POST', '/api/flapp-auth/approve', ['authenticatedAs' => 2, 'json' => $this->body()])
            ->withoutAttribute('bypassCsrfToken');

        $response = $this->send($request);

        $this->assertEquals(400, $response->getStatusCode());
        $this->assertEquals('csrf_token_mismatch', $this->json($response)['errors'][0]['code']);
    }

    public function test_an_unknown_app_is_refused(): void
    {
        list($response, $json) = $this->approve(['authenticatedAs' => 2, 'json' => $this->body(['app' => 'other'])]);

        $this->assertEquals(422, $response->getStatusCode());
        $this->assertEquals('/data/attributes/app', $json['errors'][0]['source']['pointer']);
    }

    public function test_a_short_or_broken_key_is_refused(): void
    {
        $small = openssl_pkey_new(['private_key_bits' => 1024, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);

        foreach ([openssl_pkey_get_details($small)['key'], 'not a key'] as $key) {
            list($response, $json) = $this->approve(['authenticatedAs' => 2, 'json' => $this->body(['publicKey' => $key])]);

            $this->assertEquals(422, $response->getStatusCode());
            $this->assertEquals('/data/attributes/publicKey', $json['errors'][0]['source']['pointer']);
        }

        // Only the two the test's sign-ins made.
        $this->assertEquals(2, $this->database()->table('access_tokens')->where('user_id', 2)->count());
    }

    public function test_a_bad_nonce_is_refused(): void
    {
        foreach (['short', str_repeat('a', 65), 'has spaces in it, sadly'] as $nonce) {
            list($response, $json) = $this->approve(['authenticatedAs' => 2, 'json' => $this->body(['nonce' => $nonce])]);

            $this->assertEquals(422, $response->getStatusCode());
            $this->assertEquals('/data/attributes/nonce', $json['errors'][0]['source']['pointer']);
        }
    }

    public function test_the_page_names_the_app_for_a_valid_request(): void
    {
        $response = $this->send($this->request('GET', '/flapp/authorize')->withQueryParams($this->body()));

        $this->assertEquals(200, $response->getStatusCode());

        $html = (string) $response->getBody();
        $this->assertStringContainsString('"appName":"Flapp"', $html);
        $this->assertStringContainsString('auth?error=cancelled', $html);
    }

    public function test_the_page_says_when_a_request_is_not_valid(): void
    {
        $response = $this->send($this->request('GET', '/flapp/authorize')->withQueryParams($this->body(['app' => 'other'])));

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertStringContainsString('"flappAuthorize":{"error":true}', (string) $response->getBody());
    }
}
