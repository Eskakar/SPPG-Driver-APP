import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sppg_driver_app/screens/chat_screen.dart';
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

  Future<void> _checkLogin() async {
    final isLogin = await ApiService().checkSession();
    if (!isLogin && mounted) {
      showErrorToast(context, "Cookies expired");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
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

    return Scaffold (
      body: Stack(
        children: [
          // Background gambar
          Positioned.fill(
            child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
            // child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
          ),

          // background blur dengan foto sppg
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: const Color.fromARGB(82, 167, 240, 255)),
            ),
          ),

          // Konten
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 12),
                  _currentTask(),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  _historySection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _AiChatButton(context),
    );
  }

  // ========================
  // HEADER — dipertahankan persis
  // ========================
  Widget _header() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color.fromARGB(153, 79, 152, 247),
              BlendMode.srcOver,
            ),
            child: Image.asset(
              "assets/sppg.png",
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: const Color(0x00000000)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        "Selamat datang",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?["nama"] ?? "Nama",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        user != null
                            ? NumberFormat.currency(
                                locale: "id_ID",
                                symbol: "Rp",
                                decimalDigits: 0,
                              ).format(
                                double.tryParse(user!["gaji"].toString()) ?? 0,
                              )
                            : "Rp0",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 37,
                      backgroundImage: user != null && user!["foto_profil"] != null
                          ? NetworkImage(user!["foto_profil"])
                          : const AssetImage("assets/profile.png") as ImageProvider,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // CURRENT TASK — glass hijau
  // ========================
  Widget _currentTask() {
    final sekolah = currentTugas != null
        ? currentTugas!["sekolah"] as List
        : [];
    final hasTugas = sekolah.isNotEmpty;

    return GestureDetector(
      onTap: hasTugas
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrentTaskScreen()),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xCC6DBF67), // hijau ~80%
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x6693D68D), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Tugas Saat ini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (hasTugas)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!hasTugas)
                  Text(
                    "Tidak ada tugas",
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  )
                else
                  ...sekolah.map<Widget>((s) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            s["nama"] ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // SEARCH — glass style
  // ========================
  Widget _buildSearch() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x40FFFFFF), width: 1),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: Colors.white,
            onChanged: (value) {
              searchTugas(value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: "Search data history tugas",
              hintStyle: const TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 14,
              ),
              border: InputBorder.none,
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
                size: 20,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () {
                        searchController.clear();
                        searchTugas("");
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // HISTORY — glass biru
  // ========================
  Widget _historySection() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (history.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x40FFFFFF), width: 1),
            ),
            child: const Text(
              "Tidak ada history tugas",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Column(
      children: history.map<Widget>((h) {
        final tanggal = _formatTanggal(h["tanggal"]?.toString());
        final hari = h["hari"] ?? "";

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC6B9FD4), // biru ~80%
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x4D8BB8E8), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Tugas Selesai $hari $tanggal",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
Widget _AiChatButton(BuildContext context){
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        ),
      );
    },
    child: Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 30,
      ),
    ),
  );
}