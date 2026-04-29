import 'package:flutter/material.dart';
import 'package:sppg_driver_app/services/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController searchController = TextEditingController();

  Map? currentTugas;
  List history = [];
  List historySearch = [];
  Map? user;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final current = await ApiService().dio.get("/tugas/current");
      final historyRes = await ApiService().dio.get("/tugas/history/preview");
      final userRes = await ApiService().dio.get("/user/me");
      setState(() {
        currentTugas = current.data["data"];
        history = historyRes.data["data"];
        isLoading = false;
        user = userRes.data["data"];
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
  Future<void> searchTugas(String keyword) async {
    setState(() => isSearching = true);

    try {
      final res = await ApiService()
          .dio
          .get("/tugas/search", queryParameters: {
        "search": keyword,
      });

      setState(() {
        history = res.data["data"];
      });
    } catch (e) {
      // handle error
    } finally {
      setState(() => isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 15),
              _currentTask(),
              const SizedBox(height: 15),
              _buildSearch(),
              const SizedBox(height: 15),
              _history(),
            ],
          ),
        )
      )
    );
  }

  Widget _header() {
    if (user == null) {
      return const CircularProgressIndicator();
    }
    

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Selamat Datang"),

                const SizedBox(height: 5),

                Text(
                  user!["nama"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Rp ${user!["gaji"]}",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),

          // FOTO
          CircleAvatar(
            radius: 25,
            backgroundImage: user!["foto_profil"] != null
                ? NetworkImage(user!["foto_profil"])
                : const AssetImage("assets/profile.png") as ImageProvider,
          ),
        ],
      ),
    );
  }
  Widget _buildSearch() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        searchTugas(value); // realtime search
      },
      decoration: InputDecoration(
        hintText: "Search tanggal / sekolah",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  searchTugas(""); // reset
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ========================
  // CURRENT TASK
  // ========================
  Widget _currentTask() {
    if (currentTugas == null) {
      return const Text("Tidak ada tugas");
    }

    final sekolah = currentTugas!["sekolah"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tugas Saat Ini"),

          const SizedBox(height: 10),

          ...sekolah.map<Widget>((s) {
            return Text("${s["nama"]} (${s["progress"]})");
          }).toList(),
        ],
      ),
    );
  }

  // ========================
  // HISTORY
  // ========================
  Widget _history() {
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: history.map<Widget>((h) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Tugas ${h["hari"]} (${h["tanggal"]})",
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}