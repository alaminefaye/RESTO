import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/table.dart' as models;
import '../../models/cart.dart';
import '../../utils/formatters.dart';
import '../menu/products_screen.dart';

class TableDetailScreen extends StatelessWidget {
  final models.Table table;

  const TableDetailScreen({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${table.numero}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card avec infos de la table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table ${table.numero}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(table.type.displayName),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: table.statut.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: table.statut.color,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            table.statut.displayName,
                            style: TextStyle(
                              color: table.statut.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      context,
                      Icons.people,
                      'Capacité',
                      '${table.capacite} personnes',
                    ),
                    if (table.prix != null)
                      _buildInfoRow(
                        context,
                        Icons.attach_money,
                        'Prix',
                        Formatters.formatCurrency(table.prix!),
                      ),
                    if (table.prixParHeure != null)
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        'Prix/heure',
                        '${Formatters.formatCurrency(table.prixParHeure!)}/h',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // QR Code
            if (table.qrCodeUrl.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'QR Code de la Table',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: table.qrCodeUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scannez pour accéder au menu',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            // Bouton pour voir le menu
            ElevatedButton.icon(
              onPressed: () {
                final cart = Provider.of<Cart>(context, listen: false);
                cart.setTable(table.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductsScreen(tableId: table.id),
                  ),
                );
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Voir le Menu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

