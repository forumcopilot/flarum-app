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
use Flarum\Http\AccessToken;
use Flarum\Notification\Blueprint\BlueprintInterface;
use Flarum\User\User;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Device;
use Illuminate\Contracts\Cache\LockProvider;
use Illuminate\Contracts\Cache\Repository as CacheRepository;
use Psr\Log\LoggerInterface;

/**
 * Sends a notification's pushes: one payload per reader, to each of their
 * devices whose sign-in is still valid, in signed batches to the relay.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class Pusher
{
    /**
     * How long a push counts as sent for duplicate syncs of the same
     * notification, as Flarum 2.0 guards its emails (#4622).
     */
    const LOCK_SECONDS = 600;

    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var RelayClient
     */
    protected $relay;

    /**
     * @var PayloadBuilder
     */
    protected $payloads;

    /**
     * @var CacheRepository
     */
    protected $cache;

    /**
     * @var LoggerInterface
     */
    protected $log;

    public function __construct(Connection $connection, RelayClient $relay, PayloadBuilder $payloads, CacheRepository $cache, LoggerInterface $log)
    {
        $this->connection = $connection;
        $this->relay = $relay;
        $this->payloads = $payloads;
        $this->cache = $cache;
        $this->log = $log;
    }

    /**
     * @param User[] $users the notification's new recipients who want it pushed
     */
    public function send(BlueprintInterface $blueprint, array $users): void
    {
        $forumId = $this->connection->forumId();
        $relayUrl = $this->connection->connectedRelayUrl();
        $privateKey = $this->connection->privateKey();

        if (! $forumId || ! $relayUrl || ! $privateKey || ! $users) {
            return;
        }

        $devicesByUser = [];
        $ids = array_map(function (User $user) {
            return $user->id;
        }, $users);

        // A token Flarum no longer counts as valid gets no pushes, even if its
        // row is still there.
        $devices = Device::query()
            ->whereIn('user_id', $ids)
            ->whereIn('access_token_id', AccessToken::query()->whereValid()->select('id'))
            ->get();

        foreach ($devices as $device) {
            $devicesByUser[$device->user_id][] = $device;
        }

        $pushes = [];
        $sentTo = [];

        foreach ($users as $user) {
            if (empty($devicesByUser[$user->id]) || ! $this->firstTime($blueprint, $user)) {
                continue;
            }

            $payload = $this->payloads->build($blueprint, $user);

            foreach ($devicesByUser[$user->id] as $device) {
                $pushes[] = ['handle' => $device->handle, 'payload' => $payload];
                $sentTo[] = $device->id;
            }
        }

        foreach (array_chunk($pushes, RelayClient::MAX_PUSHES) as $batch) {
            try {
                $gone = $this->relay->push($relayUrl, $forumId, $privateKey, $batch);
            } catch (RelayException $e) {
                // Most forums run the sync queue, so this runs in the poster's
                // own request: a relay that is down must not fail it.
                $this->log->warning('[forumcopilot/flarum-flapp] Pushes not sent: '.$e->getMessage());

                return;
            }

            if ($gone) {
                Device::query()->whereIn('handle', $gone)->delete();
            }
        }

        if ($sentTo) {
            Device::query()->whereIn('id', $sentTo)->update(['last_sent_at' => Carbon::now()]);
        }
    }

    /**
     * Whether this is the first push of this notification to this reader:
     * a notification synced twice in quick succession is pushed once.
     */
    protected function firstTime(BlueprintInterface $blueprint, User $user): bool
    {
        $store = $this->cache->getStore();

        if (! $store instanceof LockProvider) {
            return true;
        }

        $subject = $blueprint->getSubject();
        $from = $blueprint->getFromUser();
        $data = $blueprint->getData();

        $identity = implode(':', [
            $blueprint::getType(),
            $from ? $from->id : '',
            $subject ? $subject->getKey() : '',
            $data === null ? '' : md5((string) json_encode($data)),
        ]);

        return (bool) $store->lock('forumcopilot-flapp.pushed:'.md5($identity).':'.$user->id, self::LOCK_SECONDS)->get();
    }
}
