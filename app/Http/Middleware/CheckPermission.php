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

        if (!$request->user()->hasAnyPermission($permissions)) {
            return response()->json([
                'message' => 'Accès refusé. Permission requise: ' . implode(', ', $permissions)
            ], 403);
        }

        return $next($request);
    }
}
