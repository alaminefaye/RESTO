<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Liste des notifications de l'utilisateur (lu / non lu).
     * GET /api/notifications
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $query = $user->notifications();

        if ($request->has('unread_only') && $request->boolean('unread_only')) {
            $query->whereNull('read_at');
        }

        $notifications = $query->limit(100)->get();
        $unreadCount = $user->notifications()->whereNull('read_at')->count();

        return response()->json([
            'success' => true,
            'unread_count' => $unreadCount,
            'data' => $notifications->map(fn (UserNotification $n) => [
                'id' => $n->id,
                'type' => $n->type,
                'title' => $n->title,
                'body' => $n->body,
                'data' => $n->data,
                'read_at' => $n->read_at?->toIso8601String(),
                'created_at' => $n->created_at->toIso8601String(),
            ]),
        ]);
    }

    /**
     * Nombre de notifications non lues (pour le badge).
     * GET /api/notifications/unread-count
     */
    public function unreadCount(Request $request)
    {
        $count = $request->user()->notifications()->whereNull('read_at')->count();
        return response()->json(['success' => true, 'unread_count' => $count]);
    }

    /**
     * Marquer une notification comme lue.
     * PATCH /api/notifications/{id}/read
     */
    public function markAsRead(Request $request, int $id)
    {
        $notification = $request->user()->notifications()->find($id);
        if (!$notification) {
            return response()->json(['success' => false, 'message' => 'Notification non trouvée'], 404);
        }
        $notification->markAsRead();
        return response()->json(['success' => true, 'message' => 'Notification marquée comme lue']);
    }

    /**
     * Marquer toutes les notifications comme lues.
     * POST /api/notifications/mark-all-read
     */
    public function markAllAsRead(Request $request)
    {
        $request->user()->notifications()->whereNull('read_at')->update(['read_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Toutes les notifications ont été marquées comme lues']);
    }
}
