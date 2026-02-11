import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/table.dart' as models;
import '../../services/table_service.dart';
import 'table_detail_screen.dart';

class QrScanScreen extends StatefulWidget {
  final bool
  returnTableOnly; // Si true, retourne juste la table au lieu de naviguer

  const QrScanScreen({super.key, this.returnTableOnly = false});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final TableService _tableService = TableService();
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedQr; // Pour éviter de scanner le même QR plusieurs fois

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

    final qrData = barcode.rawValue!.trim();

    // Vérifier si c'est le même QR code qu'on vient de scanner
    if (_lastScannedQr == qrData) {
      debugPrint('QR code déjà traité, ignoré: $qrData');
      return;
    }

    // Arrêter immédiatement le scanner pour éviter les scans multiples
    _controller.stop();

    setState(() {
      _isProcessing = true;
      _lastScannedQr = qrData;
    });

    // Le QR code devrait contenir l'URL ou l'ID de la table
    // Format attendu: http://.../api/tables/{id}/menu
    // ou http://.../tables/{id} ou juste l'ID
    debugPrint('=== SCAN QR CODE ===');
    debugPrint('QR Code scanné (raw): $qrData');

    try {
      int? tableId;

      // Nettoyer l'URL (enlever les espaces, etc.)
      final cleanUrl = qrData.trim();
      debugPrint('URL nettoyée: $cleanUrl');

      // Extraire l'ID de table de l'URL avec plusieurs méthodes
      // Méthode 1: Format standard /api/tables/{id}/menu ou /tables/{id}
      final tablesPattern = RegExp(r'/tables/(\d+)');
      final tablesMatch = tablesPattern.firstMatch(cleanUrl);
      if (tablesMatch != null && tablesMatch.group(1) != null) {
        tableId = int.tryParse(tablesMatch.group(1)!);
        debugPrint('ID extrait via /tables/ : $tableId');
      }

      // Méthode 2: Format alternatif /table/{id} (sans 's')
      if (tableId == null) {
        final tablePattern = RegExp(r'/table/(\d+)');
        final tableMatch = tablePattern.firstMatch(cleanUrl);
        if (tableMatch != null && tableMatch.group(1) != null) {
          tableId = int.tryParse(tableMatch.group(1)!);
          debugPrint('ID extrait via /table/ : $tableId');
        }
      }

      // Méthode 3: Essayer de parser directement comme ID (si le QR contient juste un nombre)
      if (tableId == null && RegExp(r'^\d+$').hasMatch(cleanUrl)) {
        tableId = int.tryParse(cleanUrl);
        if (tableId != null) {
          debugPrint('ID extrait directement: $tableId');
        }
      }

      debugPrint('ID final extrait: $tableId');

      if (tableId == null) {
        // Redémarrer le scanner pour permettre un nouveau scan
        _controller.start();
        setState(() {
          _isProcessing = false;
          _lastScannedQr = null;
        });
        throw Exception(
          'Impossible d\'extraire l\'ID de la table depuis le QR code. Format attendu: http://.../api/tables/{id}/menu',
        );
      }

      // Si on a un ID, récupérer la table
      models.Table? table;
      debugPrint('Tentative de récupération de la table ID: $tableId');

      // Essayer d'abord via l'endpoint menu (pour le scan QR)
      try {
        table = await _tableService.getTableFromMenuEndpoint(tableId);
        debugPrint(
          'Table récupérée via endpoint menu: ${table?.numero} (ID: ${table?.id})',
        );
      } catch (e) {
        debugPrint('Erreur avec endpoint menu: $e');
        debugPrint('Essai avec endpoint standard...');
        // Fallback: essayer avec l'endpoint standard
        try {
          table = await _tableService.getTable(tableId);
          debugPrint(
            'Table récupérée via endpoint standard: ${table?.numero} (ID: ${table?.id})',
          );
        } catch (e2) {
          debugPrint('Erreur avec endpoint standard: $e2');
          throw Exception(
            'Table introuvable (ID: $tableId). Vérifiez le QR code scanné: $qrData',
          );
        }
      }

      if (table == null) {
        debugPrint(
          'Table null après toutes les tentatives. ID recherché: $tableId',
        );
        // Redémarrer le scanner pour permettre un nouveau scan
        _controller.start();
        setState(() {
          _isProcessing = false;
          _lastScannedQr = null;
        });
        throw Exception(
          'Table introuvable (ID: $tableId). Vérifiez le QR code scanné: $qrData',
        );
      }

      debugPrint('=== TABLE TROUVÉE ===');
      debugPrint('Numéro: ${table.numero}');
      debugPrint('ID: ${table.id}');
      debugPrint('Type: ${table.type}');
      debugPrint('Statut: ${table.statut}');

      debugPrint('Table trouvée: ${table.numero} (ID: ${table.id})');

      if (!mounted) return;

      // Si on vient du panier, retourner juste la table
      if (widget.returnTableOnly) {
        Navigator.pop(context, table);
        return;
      }

      // Sinon, naviguer vers les détails de la table (le scanner reste arrêté car on change d'écran)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TableDetailScreen(table: table!)),
      );
    } catch (e) {
      if (!mounted) return;

      // Extraire le message d'erreur de manière plus claire
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      // Redémarrer le scanner après un délai pour permettre un nouveau scan
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isProcessing) {
          _controller.start();
          setState(() {
            _lastScannedQr = null;
          });
        }
      });

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Scanner QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  offset: const Offset(-1, -1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.orange),
              onPressed: () {
                _controller.toggleTorch();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.orange),
                      SizedBox(height: 24),
                      Text(
                        'Traitement...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Instructions
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF252525).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.orange, size: 32),
                  SizedBox(height: 12),
                  Text(
                    'Scannez le QR code sur la table pour accéder au menu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
