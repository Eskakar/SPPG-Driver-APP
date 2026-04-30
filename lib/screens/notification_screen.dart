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

      // saat buka screen → mark read
      await NotificationService.instance.markAsRead();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: notif.isEmpty
          ? const Center(child: Text("Tidak ada notifikasi"))
          : ListView.builder(
              itemCount: notif.length,
              itemBuilder: (context, index) {
                final item = notif[index];

                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item["is_read"]
                        ? Colors.grey[200]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["judul"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(item["pesan"]),
                      const SizedBox(height: 5),
                      Text(
                        item["jenis"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}