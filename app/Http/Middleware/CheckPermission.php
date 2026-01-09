<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$permissions): Response
    {
        if (!$request->user()) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        $user = $request->user();
        $hasPermission = false;

        // Vérifier d'abord les abilities du token Sanctum (si disponible)
        $currentAccessToken = $user->currentAccessToken();
        if ($currentAccessToken) {
            foreach ($permissions as $permission) {
                if ($currentAccessToken->can($permission)) {
                    $hasPermission = true;
                    break;
                }
            }
        }

        // Si pas de permission via le token, vérifier les permissions Spatie
        if (!$hasPermission) {
            // Recharger les permissions pour s'assurer qu'elles sont à jour
            $user->load('roles.permissions');
            $hasPermission = $user->hasAnyPermission($permissions);
        }

        if (!$hasPermission) {
            // Log pour débogage
            \Log::warning('Permission refusée', [
                'user_id' => $user->id,
                'user_email' => $user->email,
                'required_permissions' => $permissions,
                'user_permissions' => $user->getAllPermissions()->pluck('name')->toArray(),
                'token_abilities' => $currentAccessToken ? $currentAccessToken->abilities : [],
            ]);
            
            return response()->json([
                'message' => 'Non autorisé. Veuillez vous reconnecter.',
            ], 403);
        }

        return $next($request);
    }
}
