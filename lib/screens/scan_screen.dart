import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'package:sppg_driver_app/widgets/error_toast.dart';
import '../services/scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isScanning = false;
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }
  Future<void> _checkLogin() async{
    final isLogin = await ApiService().checkSession();
    if(!isLogin && mounted){
      showErrorToast(context,"Cokiess expired");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
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
      showErrorToast(context, e.toString());
      setState(() => isScanning = false);
    }
    // delay sebelum bisa scan lagi
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 135, 206, 235);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          // CAMERA
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null) {
                  handleScan(code);
                  break;
                }
              }
            },
          ),

          //  OVERLAY GELAP + HOLE
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),

                //  AREA SCAN (lubang)
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //  BORDER AREA SCAN
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          //  TEXT INSTRUCTION
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Arahkan QR ke dalam kotak",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Scan akan otomatis",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          //  LOADING
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