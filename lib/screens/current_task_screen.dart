import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sppg_driver_app/screens/map_screen.dart';
import 'package:sppg_driver_app/services/location_service.dart';
import 'package:sppg_driver_app/widgets/error_toast.dart';
import '../services/tugas_service.dart';

class CurrentTaskScreen extends StatefulWidget {
  const CurrentTaskScreen({super.key});

  @override
  State<CurrentTaskScreen> createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  Map? tugas;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _openMap(Map sekolah) async {
    try {
      final position = await LocationService.instance.getCurrentLocation();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            driverLat: position.latitude,
            driverLng: position.longitude,
            sekolahLat: sekolah["latitude"],
            sekolahLng: sekolah["longitude"],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, "Gagal mengambil lokasi");
      print("Error open map: $e");
    }
  }


  Future<void> fetchData() async {
    final data = await TugasService.instance.getCurrentTugas();

    setState(() {
      tugas = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tugas == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada tugas berjalan")),
      );
    }

    final sekolahList = tugas!["sekolah"];

    return Scaffold(
      appBar: AppBar(title: const Text("Tugas Saat Ini")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ========================
            // PROGRESS GLOBAL
            // ========================
            _buildProgress(),

            const SizedBox(height: 20),

            // ========================
            // LIST SEKOLAH
            // ========================
            Expanded(
              child: ListView.builder(
                itemCount: sekolahList.length,
                itemBuilder: (context, index) {
                  final s = sekolahList[index];

                  return _buildSekolahCard(s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // PROGRESS GLOBAL
  // ========================
  Widget _buildProgress() {
    final progress = tugas!["statistik"]["progress"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Progress Pengantaran"),
          const SizedBox(height: 10),
          Text("$progress%"),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress / 100)
        ],
      ),
    );
  }

  // ========================
  // CARD SEKOLAH
  // ========================
  Widget _buildSekolahCard(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(s["nama"]),
        subtitle: Text("Progress: ${s["progress"]}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        // 🔥 nanti bisa ke map
        onTap: () {
          _openMap(s);
        },
      ),
    );
  }
}