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

use GuzzleHttp\ClientInterface;
use GuzzleHttp\Exception\GuzzleException;

/**
 * Calls flapp-push, the relay that hands pushes to Firebase and Apple.
 * docs/relay-protocol.md describes the calls.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class RelayClient
{
    /**
     * Placeholder until the relay's address is settled; a forum keeps the
     * address it connected to (Connection::relayUrl()).
     */
    const DEFAULT_URL = 'https://push.flarumapp.com';

    /**
     * The protocol version GET /api announces in flappPush.
     */
    const PROTOCOL_VERSION = 1;

    /**
     * Seconds. Most forums run the sync queue, so a push is sent inside the
     * poster's own request.
     */
    const TIMEOUT = 2;

    /**
     * The most pushes the relay takes in one call.
     */
    const MAX_PUSHES = 500;

    /**
     * @var ClientInterface
     */
    protected $http;

    public function __construct(ClientInterface $http)
    {
        $this->http = $http;
    }

    /**
     * Enrol the forum. The call is signed with the new key, so the relay
     * knows the caller holds it.
     *
     * @return string the forum's id on the relay
     */
    public function enrol(string $relay, string $forumUrl, string $title, string $privateKey): string
    {
        $response = $this->call($relay, 'POST', '/v1/forums', [
            'url' => $forumUrl,
            'title' => $title,
            'publicKey' => Signer::publicKey($privateKey),
        ], $privateKey, null);

        $forumId = $response['forumId'] ?? null;

        if (! is_string($forumId) || ! preg_match('/^[A-Za-z0-9_-]{1,64}$/', $forumId)) {
            throw new RelayException('The relay answered without a forum id.');
        }

        return $forumId;
    }

    /**
     * Tell the relay to forget the forum and its phones' handles. A forum it
     * no longer knows counts as forgotten.
     */
    public function forget(string $relay, string $forumId, string $privateKey): void
    {
        try {
            $this->call($relay, 'DELETE', '/v1/forums/'.rawurlencode($forumId), null, $privateKey, $forumId);
        } catch (RelayException $e) {
            if ($e->getCode() !== 404 && $e->getCode() !== 410) {
                throw $e;
            }
        }
    }

    /**
     * Hand a batch of pushes to the relay.
     *
     * @param array[] $pushes each ['handle' => …, 'payload' => […]], at most MAX_PUSHES
     * @return string[] the handles the relay no longer knows for this forum
     * @throws RelayException
     */
    public function push(string $relay, string $forumId, string $privateKey, array $pushes): array
    {
        try {
            $answer = $this->call($relay, 'POST', '/v1/push', [
                'forumId' => $forumId,
                'pushes' => array_values($pushes),
            ], $privateKey, $forumId);
        } catch (RelayException $e) {
            // The relay has this call already: sent again after an answer
            // that never arrived.
            if ($e->getCode() === 409) {
                return [];
            }

            throw $e;
        }

        $gone = isset($answer['gone']) && is_array($answer['gone']) ? $answer['gone'] : [];

        return array_values(array_filter($gone, 'is_string'));
    }

    /**
     * Tell the relay the readers' unread counts after they read
     * notifications, for the iPhone badge.
     *
     * @param array[] $counts each ['handle' => …, 'unread' => n], at most MAX_PUSHES
     * @return string[] the handles the relay no longer knows for this forum
     * @throws RelayException
     */
    public function unread(string $relay, string $forumId, string $privateKey, array $counts): array
    {
        try {
            $answer = $this->call($relay, 'POST', '/v1/unread', [
                'forumId' => $forumId,
                'counts' => array_values($counts),
            ], $privateKey, $forumId);
        } catch (RelayException $e) {
            if ($e->getCode() === 409) {
                return [];
            }

            throw $e;
        }

        $gone = isset($answer['gone']) && is_array($answer['gone']) ? $answer['gone'] : [];

        return array_values(array_filter($gone, 'is_string'));
    }

    /**
     * @param array|null $data the JSON body, if any
     * @return array the JSON answer
     */
    protected function call(string $relay, string $method, string $path, ?array $data, string $privateKey, ?string $forumId): array
    {
        $url = rtrim($relay, '/').$path;
        $body = $data === null ? '' : json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $time = time();

        $headers = [
            'Accept' => 'application/json',
            'User-Agent' => 'flarum-flapp/'.self::PROTOCOL_VERSION,
            'X-Flapp-Time' => (string) $time,
            // Signed over the path the relay sees, which includes any prefix
            // in its address.
            'X-Flapp-Signature' => Signer::sign($privateKey, $method, (string) parse_url($url, PHP_URL_PATH), $time, $body),
        ];

        if ($data !== null) {
            $headers['Content-Type'] = 'application/json';
        }

        if ($forumId !== null) {
            $headers['X-Flapp-Forum'] = $forumId;
        }

        try {
            $response = $this->http->request($method, $url, [
                'headers' => $headers,
                'body' => $body,
                'http_errors' => false,
            ]);
        } catch (GuzzleException $e) {
            throw new RelayException('The relay could not be reached: '.$e->getMessage(), 0, $e);
        }

        $status = $response->getStatusCode();
        $json = json_decode((string) $response->getBody(), true);

        if ($status < 200 || $status >= 300) {
            $detail = is_array($json) && isset($json['error']) && is_string($json['error']) ? ': '.$json['error'] : '';

            throw new RelayException("The relay refused the call (HTTP $status)$detail.", $status);
        }

        return is_array($json) ? $json : [];
    }
}
