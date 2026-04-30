import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class ScanService {
  static final ScanService instance = ScanService._();
  ScanService._();

  Future<Map<String, dynamic>> scanBox(String qrCode) async {
    try {
      // ambil lokasi
      final pos = await LocationService.instance.getCurrentLocation();

      final res = await ApiService().dio.post(
        "/tugas/scan",
        data: {
          "qr_code": qrCode,
          "latitude": pos.latitude,
          "longitude": pos.longitude,
        },
        options: Options (validateStatus: (_) => true),
      );
      if (res.data["success"] == false) {
        throw Exception(res.data["message"]);
      }

      return res.data["data"];
    } on DioException catch (e) {
      throw Exception(e.response?.data["message dari message"] ?? "Scan gagal");
    }
  }
}