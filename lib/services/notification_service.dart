import 'package:dio/dio.dart';
import 'package:sppg_driver_app/services/notification_local_service.dart';
import '../services/api_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  // 🔥 ambil semua notif user
  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await ApiService().dio.get("/notif");

      if (res.data["success"] == false) {
        throw Exception(res.data["message"]);
      }

      return res.data["data"];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal ambil notifikasi",
      );
    }
  }
  int countUnread(List notif) {
    return notif.where((n) => n["is_read"] == false).length;
  }
  // 🔥 tandai semua sudah dibaca
  Future<void> markAsRead() async {
    try {
      await ApiService().dio.post("/notif/read");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal update notifikasi",
      );
    }
  }
  
  Future<void> fetchAndShowNotif() async {
    final res = await ApiService().dio.get("/notif");

    final data = res.data["data"];

    for (var n in data) {
      if (n["is_read"] == false) {
        await LocalNotifService.instance.showNotif(
          title: n["judul"],
          body: n["pesan"],
        );
      }
    }
  }
}