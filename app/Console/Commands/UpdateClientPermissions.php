<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class UpdateClientPermissions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'client:update-permissions';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Mettre à jour les permissions du rôle client pour inclure update_orders';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Mise à jour des permissions du rôle client...');

        $clientRole = Role::where('name', 'client')->first();

        if (!$clientRole) {
            $this->error('Le rôle client n\'existe pas. Exécutez d\'abord le seeder SpatieRolesPermissionsSeeder.');
            return 1;
        }

        // S'assurer que les permissions existent
        $permissions = [
            'create_orders',
            'view_orders',
            'update_orders',
        ];

        foreach ($permissions as $permissionName) {
            Permission::firstOrCreate(
                ['name' => $permissionName, 'guard_name' => 'web']
            );
        }

        // Synchroniser les permissions du rôle client
        $clientRole->syncPermissions($permissions);

        $this->info('✓ Permissions du rôle client mises à jour avec succès !');
        $this->info('Les permissions suivantes ont été assignées :');
        foreach ($permissions as $permission) {
            $this->line("  - {$permission}");
        }

        $this->warn('⚠ Les utilisateurs existants devront se reconnecter pour que les nouvelles permissions prennent effet.');

        return 0;
    }
}
