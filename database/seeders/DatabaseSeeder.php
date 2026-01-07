<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Créer les permissions en premier
        $this->call(PermissionSeeder::class);
        
        // Créer les rôles et leur attribuer les permissions
        $this->call(RoleSeeder::class);
        
        // Créer ou récupérer un utilisateur admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@admin.com'],
            [
            'name' => 'Admin User',
                'password' => bcrypt('password'),
            ]
        );
        
        // Attribuer le rôle admin s'il ne l'a pas déjà
        if (!$admin->hasRole('admin')) {
            $admin->assignRole('admin');
        }
        
        // Créer des utilisateurs de test pour chaque rôle
        $manager = User::firstOrCreate(
            ['email' => 'manager@resto.com'],
            [
                'name' => 'Manager User',
                'password' => bcrypt('password'),
            ]
        );
        if (!$manager->hasRole('manager')) {
            $manager->assignRole('manager');
        }
        
        $caissier = User::firstOrCreate(
            ['email' => 'caissier@resto.com'],
            [
                'name' => 'Caissier User',
                'password' => bcrypt('password'),
            ]
        );
        if (!$caissier->hasRole('caissier')) {
            $caissier->assignRole('caissier');
        }
        
        $serveur = User::firstOrCreate(
            ['email' => 'serveur@resto.com'],
            [
                'name' => 'Serveur User',
            'password' => bcrypt('password'),
            ]
        );
        if (!$serveur->hasRole('serveur')) {
            $serveur->assignRole('serveur');
        }
    }
}
