import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notif = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotif();
  }

  Future<void> fetchNotif() async {
    try {
      final res = await ApiService().dio.get("/notif");
      setState(() {
        notif = res.data["data"];
        isLoading = false;
      });
      await NotificationService.instance.markAsRead();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color _accentColor(Map item) {
    switch (item["jenis"]) {
      case "pengumuman":
        return Colors.lightBlueAccent;
      case "tugas":
        return Colors.lightGreenAccent;
      case "sanksi":
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  IconData _accentIcon(Map item) {
    switch (item["jenis"]) {
      case "pengumuman":
        return Icons.campaign_outlined;
      case "tugas":
        return Icons.assignment_outlined;
      case "sanksi":
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gambar ──────────────────────────────────────
          Positioned.fill(
            child: Image.asset("assets/logo_sppg.png", fit: BoxFit.cover),
          ),

          // ── Blur + tint biru (sama dengan Dashboard) ──────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: const Color.fromARGB(82, 167, 240, 255)),
            ),
          ),

          // ── Konten ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : notif.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // APP BAR
  // ========================
  Widget _buildAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0x33FFFFFF),
            border: Border(
              bottom: BorderSide(color: Color(0x40FFFFFF), width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const Text(
                "Notifikasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================
  // EMPTY STATE
  // ========================
  Widget _buildEmpty() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x40FFFFFF), width: 1),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: Colors.white70,
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  "Tidak ada notifikasi",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // LIST NOTIFIKASI
  // ========================
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: notif.length,
      itemBuilder: (context, index) {
        final item = notif[index];
        final isRead = item["is_read"] ?? false;
        final accent = _accentColor(item);
        final icon = _accentIcon(item);

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
                  // ── Lebih gelap agar teks terbaca ──────────────
                  color: isRead
                      ? const Color(0xAA1A3A5C) // sudah dibaca → redup
                      : const Color(0xDD1A3A5C), // belum dibaca → solid
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x4D8BB8E8), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ikon jenis ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: accent, size: 18),
                    ),
                    const SizedBox(width: 12),

                    // ── Teks ────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item["judul"] ?? "",
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item["jenis"] ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: accent,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item["pesan"] ?? "",
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
