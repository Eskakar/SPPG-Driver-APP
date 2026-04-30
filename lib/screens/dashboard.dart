import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sppg_driver_app/screens/current_task_screen.dart';
import 'package:sppg_driver_app/screens/splash_screen.dart';
import 'package:sppg_driver_app/services/api_service.dart';
import 'package:sppg_driver_app/services/tugas_service.dart';
import 'package:sppg_driver_app/widgets/error_toast.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController searchController = TextEditingController();

  Map? currentTugas;
  List history = [];
  Map? user;
  bool isLoading = true;
  bool isSearching = false;
  
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
    }else{
      loadData();
    }
  }
  
  Future<void> loadData() async {
    try {
      final result = await TugasService.instance.fetchAllTugas();

      if (!mounted) return;

      setState(() {
        currentTugas = result["current"];
        history = result["history"];
        user = result["user"];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      showErrorToast(context, "Gagal menyambungkan dengan server");
    }
  }

  Future<void> searchTugas(String keyword) async {
    setState(() => isSearching = true);

    try {
      final result = await TugasService.instance.searchTugas(keyword);
      setState(() {
        history = result;
      });
    } finally {
      setState(() => isSearching = false);
    }
  }

  String _formatTanggal(String? raw) {
    if (raw == null) return "";
    try {
      final dt = DateTime.parse(raw);
      return DateFormat("dd/MM/yyyy").format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          _buildSearch(),
          const SizedBox(height: 12),
          _taskAndHistory(),
        ],
      ),
    );
  }

  // ========================
  // HEADER
  // ========================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Selamat datang",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: user != null && user!["foto_profil"] != null
                        ? NetworkImage(user!["foto_profil"])
                        : const AssetImage("assets/profile.png")
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?["nama"] ?? "Nama",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            user != null
                ? NumberFormat.currency(
                    locale: "id_ID",
                    symbol: "Rp",
                    decimalDigits: 2,
                  ).format(double.tryParse(user!["gaji"].toString()) ?? 0)
                : "Rp0",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ========================
  // SEARCH
  // ========================
  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          searchTugas(value);
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: "Search data history tugas",
          border: InputBorder.none,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    searchTugas("");
                    setState(() {});
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ========================
  // CURRENT TASK + HISTORY (dalam 1 container)
  // ========================
  Widget _taskAndHistory() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _currentTask(),
          if (isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _history(),
        ],
      ),
    );
  }

  // ========================
  // CURRENT TASK
  // ========================
  Widget _currentTask() {
    final sekolah = currentTugas != null
        ? currentTugas!["sekolah"] as List
        : [];

    return GestureDetector(
      onTap: currentTugas != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrentTaskScreen()),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF6DBF67),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tugas Saat ini",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (sekolah.isEmpty)
              const Text(
                "Tidak ada tugas",
                style: TextStyle(color: Colors.white),
              )
            else
              ...sekolah.map<Widget>((s) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    s["nama"] ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // ========================
  // HISTORY
  // ========================
  Widget _history() {
    return Column(
      children: history.map<Widget>((h) {
        final tanggal = _formatTanggal(h["tanggal"]?.toString());
        final hari = h["hari"] ?? "";

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF6B9FD4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "Tugas Selesai $hari $tanggal",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
