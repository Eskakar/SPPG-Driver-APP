import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/notification_local_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  //  ambil notif belum dikirim
  Future<List<dynamic>> _getUnsentNotif() async {
    try {
      final res = await ApiService().dio.get("/notif/unsent");

      if (res.data["success"] == false) {
        throw Exception(res.data["message"]);
      }

      return res.data["data"];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal ambil notif",
      );
    }
  }

  // tandai sudah dikirim ke device
  Future<void> markAsSent(List ids) async {
    try {
      await ApiService().dio.post(
        "/notif/mark-sent",
        data: {"ids": ids},
      );
    } catch (e) {
      throw Exception("Gagal update notif sent");
    }
  }

  // tandai sudah dibaca
  Future<void> markAsRead() async {
    try {
      await ApiService().dio.post("/notif/read");
    } catch (e) {
      throw Exception("Gagal update notif read");
    }
  }

  //  fetch + tampilkan notif HP, hanya di splash screen
  Future<void> fetchAndShowNotif() async {
    final data = await _getUnsentNotif();

    if (data.isEmpty) return;

    List ids = [];

    for (var n in data) {
      await LocalNotifService.instance.showNotif(
        title: n["judul"],
        body: n["pesan"],
      );

      ids.add(n["id"]);
    }

    //  tandai sudah dikirim
    await markAsSent(ids);
  }
}