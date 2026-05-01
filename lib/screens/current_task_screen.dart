import 'package:flutter/material.dart';
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

  Future<void> openMap(Map sekolah) async {
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
    final primaryColor = const Color.fromARGB(255, 135, 206, 235);

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
      backgroundColor: const Color.fromARGB(255, 219, 219, 219),
      appBar: AppBar(
        title: const Text("Tugas Saat Ini"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgress(tugas!["statistik"], primaryColor),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: sekolahList.length,
                itemBuilder: (context, index) {
                  final s = sekolahList[index];
                  return _buildSekolahCard(s, primaryColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProgress(Map statistik, Color primaryColor) {
    final progress = statistik["progress"];
    final mbgSppg = statistik["mbg_sppg"];
    final mbgAngkut = statistik["mbg_perjalanan"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 151, 139, 205),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Progress Pengantaran"),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress / 100,
            color: const Color.fromARGB(255, 22, 96, 12),
            minHeight: 10,
          ),

          const SizedBox(height: 10),
          Text("$progress%"),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Di SPPG", mbgSppg),
              _statItem("Diangkut", mbgAngkut),
            ],
          )
        ],
      ),
    );
  }
  Widget _statItem(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color.fromARGB(255, 237, 237, 237),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSekolahCard(Map s, Color primaryColor) {
    final progress = s["progress"];
    final isDone = progress.split("/")[0] == progress.split("/")[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 255, 242, 65),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          // ICON SEKOLAH
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school, color: primaryColor),
          ),

          const SizedBox(width: 12),

          // INFO SEKOLAH
          Expanded(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["nama"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text("Progress: $progress"),
                  ],
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green : const Color.fromARGB(255, 255, 136, 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isDone ? "Selesai" : "Proses",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            )
          ),

          
          GestureDetector(
            onTap: (){openMap(s);},
            child : SizedBox(
              width: 50,
              height: 50,
              child: Image.asset("assets/maps.png", fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
