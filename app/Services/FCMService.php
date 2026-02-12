<?php

namespace App\Services;

use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;

class FCMService
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    /**
     * Envoyer une notification à une liste de tokens
     *
     * @param array $tokens Liste des tokens FCM
     * @param string $title Titre de la notification
     * @param string $body Corps de la notification
     * @param array $data Données supplémentaires (optionnel)
     * @return array Résultat de l'envoi
     */
    public function sendToTokens(array $tokens, string $title, string $body, array $data = [])
    {
        if (empty($tokens)) {
            return ['success' => 0, 'failure' => 0];
        }

        $notification = Notification::create($title, $body);

        $message = CloudMessage::new()
            ->withNotification($notification)
            ->withData($data);

        $report = $this->messaging->sendMulticast($message, $tokens);

        Log::info('FCM Notification sent', [
            'success' => $report->successes()->count(),
            'failure' => $report->failures()->count(),
            'tokens_count' => count($tokens)
        ]);

        return [
            'success' => $report->successes()->count(),
            'failure' => $report->failures()->count(),
            'failures' => $report->failures(),
        ];
    }

    /**
     * Envoyer une notification à un topic
     *
     * @param string $topic Nom du topic
     * @param string $title Titre de la notification
     * @param string $body Corps de la notification
     * @param array $data Données supplémentaires (optionnel)
     */
    public function sendToTopic(string $topic, string $title, string $body, array $data = [])
    {
        $notification = Notification::create($title, $body);

        $message = CloudMessage::withTarget('topic', $topic)
            ->withNotification($notification)
            ->withData($data);

        try {
            $this->messaging->send($message);
            Log::info("FCM Notification sent to topic: $topic");
            return true;
        } catch (\Throwable $e) {
            Log::error("FCM Topic Error: " . $e->getMessage());
            return false;
        }
    }
}
