import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sppg_driver_app/services/api_service.dart';

class CurrentTaskScreen extends StatefulWidget {
  const CurrentTaskScreen({super.key});

  @override
  State<CurrentTaskScreen> createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  Map? tugasData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentTugas();
  }

  Future<void> fetchCurrentTugas() async {
    try {
      final res = await ApiService().dio.get("/tugas/current");
      setState(() {
        tugasData = res.data["data"];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openMap(double latitude, double longitude, String nama) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tugasData == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada tugas berjalan")),
      );
    }

    final statistik = tugasData!["statistik"];
    final sekolahList = tugasData!["sekolah"] as List;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tugas Saat Ini"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATA MBG SPPG
            _mbgCard(statistik),
            const SizedBox(height: 12),
            // LIST SEKOLAH
            ...sekolahList.map<Widget>((s) => _sekolahCard(s)).toList(),
          ],
        ),
      ),
    );
  }

  // ========================
  // CARD DATA MBG
  // ========================
  Widget _mbgCard(Map statistik) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9FD4),
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DATA MBG sppg",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60), // space kosong seperti mockup
          Text(
            "MBG di sppg : ${statistik["mbg_sppg"]}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "MBG dalam perjalanan : ${statistik["mbg_perjalanan"]}",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "MBG telah sampai : ${statistik["mbg_sampai"]}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ========================
  // CARD SEKOLAH
  // ========================
  Widget _sekolahCard(Map sekolah) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF6DBF67),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sekolah["nama"] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = sekolah["latitude"];
              final lng = sekolah["longitude"];
              if (lat != null && lng != null) {
                _openMap(
                  double.parse(lat.toString()),
                  double.parse(lng.toString()),
                  sekolah["nama"] ?? "",
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            child: const Text("MAP"),
          ),
        ],
      ),
    );
  }
}
