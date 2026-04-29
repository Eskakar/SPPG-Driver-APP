import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isScanning = false;

  void handleScan(String qr) async {
    if (isScanning) return;

    setState(() => isScanning = true);

    try {
      final result = await ScanService.instance.scanBox(qr);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            result["type"] == "pickup"
                ? "Pickup Berhasil"
                : "Berhasil Dikirim",
          ),
          content: Text(result["message"]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isScanning = false);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      setState(() => isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null) {
                  handleScan(code);
                  break; // biar tidak double scan
                }
              }
            },
          ),

          // overlay loading
          if (isScanning)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}