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
    
    try {
      int? tableId;
      
      // Extraire l'ID de table de l'URL
      if (qrData.contains('/tables/')) {
        // Format: http://.../api/tables/{id}/menu ou /tables/{id}
        final parts = qrData.split('/tables/');
        if (parts.length > 1) {
          // Prendre la première partie après /tables/
          final idPart = parts[1].split('/').first.split('?').first;
          tableId = int.tryParse(idPart);
        }
      } else if (qrData.contains('/table/')) {
        // Format alternatif: /table/{id}
        final parts = qrData.split('/table/');
        if (parts.length > 1) {
          final idPart = parts[1].split('/').first.split('?').first;
          tableId = int.tryParse(idPart);
        }
      } else {
        // Essayer de parser directement comme ID
        tableId = int.tryParse(qrData);
      }

      // Si on a un ID, récupérer la table par ID
      models.Table? table;
      if (tableId != null) {
        table = await _tableService.getTable(tableId);
      } else {
        // Sinon, essayer de récupérer par numéro
        final tableNumber = int.tryParse(qrData);
        if (tableNumber != null) {
          table = await _tableService.getTableByNumber(tableNumber);
        }
      }

      if (table == null) {
        throw Exception('Table introuvable. Vérifiez le QR code.');
      }

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

