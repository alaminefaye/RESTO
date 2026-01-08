import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/table.dart' as models;
import '../../services/table_service.dart';
import 'table_detail_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final TableService _tableService = TableService();
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Le QR code devrait contenir l'URL ou l'ID de la table
    // Format attendu: http://.../api/tables/{id}/menu
    // ou http://.../tables/{id} ou juste l'ID
    final qrData = barcode.rawValue!;
    
    // Log pour le débogage
    debugPrint('=== SCAN QR CODE ===');
    debugPrint('QR Code scanné (raw): $qrData');
    
    try {
      int? tableId;
      
      // Nettoyer l'URL (enlever les espaces, etc.)
      final cleanUrl = qrData.trim();
      debugPrint('URL nettoyée: $cleanUrl');
      
      // Extraire l'ID de table de l'URL avec plusieurs méthodes
      // Méthode 1: Format standard /api/tables/{id}/menu
      final tablesPattern = RegExp(r'/tables/(\d+)');
      final tablesMatch = tablesPattern.firstMatch(cleanUrl);
      if (tablesMatch != null) {
        tableId = int.tryParse(tablesMatch.group(1)!);
        debugPrint('ID extrait via /tables/ : $tableId');
      }
      
      // Méthode 2: Format alternatif /table/{id}
      if (tableId == null) {
        final tablePattern = RegExp(r'/table/(\d+)');
        final tableMatch = tablePattern.firstMatch(cleanUrl);
        if (tableMatch != null) {
          tableId = int.tryParse(tableMatch.group(1)!);
          debugPrint('ID extrait via /table/ : $tableId');
        }
      }
      
      // Méthode 3: Essayer de parser directement comme ID
      if (tableId == null) {
        tableId = int.tryParse(cleanUrl);
        if (tableId != null) {
          debugPrint('ID extrait directement: $tableId');
        }
      }
      
      // Si toujours pas d'ID, essayer d'extraire n'importe quel nombre de l'URL
      if (tableId == null) {
        final numberPattern = RegExp(r'\d+');
        final numberMatch = numberPattern.firstMatch(cleanUrl);
        if (numberMatch != null) {
          tableId = int.tryParse(numberMatch.group(0)!);
          debugPrint('ID extrait via pattern nombre: $tableId');
        }
      }

      debugPrint('ID final extrait: $tableId');
      
      if (tableId == null) {
        throw Exception('Impossible d\'extraire l\'ID de la table depuis le QR code: $qrData');
      }

      // Si on a un ID, récupérer la table
      models.Table? table;
      debugPrint('Tentative de récupération de la table ID: $tableId');
      
      // Essayer d'abord via l'endpoint menu (pour le scan QR)
      try {
        table = await _tableService.getTableFromMenuEndpoint(tableId);
        debugPrint('Table récupérée via endpoint menu: ${table?.numero} (ID: ${table?.id})');
      } catch (e) {
        debugPrint('Erreur avec endpoint menu: $e');
        debugPrint('Essai avec endpoint standard...');
        // Fallback: essayer avec l'endpoint standard
        try {
          table = await _tableService.getTable(tableId);
          debugPrint('Table récupérée via endpoint standard: ${table?.numero} (ID: ${table?.id})');
        } catch (e2) {
          debugPrint('Erreur avec endpoint standard: $e2');
          throw Exception('Table introuvable (ID: $tableId). Vérifiez le QR code scanné: $qrData');
        }
      }

      if (table == null) {
        debugPrint('Table null après toutes les tentatives. ID recherché: $tableId');
        throw Exception('Table introuvable (ID: $tableId). Vérifiez le QR code scanné: $qrData');
      }
      
      debugPrint('=== TABLE TROUVÉE ===');
      debugPrint('Numéro: ${table.numero}');
      debugPrint('ID: ${table.id}');
      debugPrint('Type: ${table.type}');
      debugPrint('Statut: ${table.statut}');
      
      debugPrint('Table trouvée: ${table.numero} (ID: ${table.id})');

      if (!mounted) return;

      // Naviguer vers les détails de la table
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TableDetailScreen(table: table!),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              _controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Traitement...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: const Text(
                'Scannez le QR code sur la table pour accéder au menu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

