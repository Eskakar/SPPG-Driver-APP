import 'package:dio/dio.dart';
import 'package:sppg_driver_app/services/api_service.dart';

class TugasService {
  static final TugasService instance = TugasService._();
  TugasService._();
  final api = ApiService().dio;
  
  Future<Map<String, dynamic>?> getCurrentTugas() async {
    try {
      final res = await ApiService().dio.get("/tugas/current");

      if (res.data["success"] == false) return null;

      return res.data["data"];
    } on DioException {
      return null;
    }
  }
  Future<Map<String, dynamic>> fetchAllTugas() async {
    final current = await api.get("/tugas/current");
    final historyRes = await api.get("/tugas/history/preview");
    final userRes = await api.get("/user/me");

    return {
      "current": current.data["data"],
      "history": historyRes.data["data"],
      "user": userRes.data["data"],
    };
  }

  Future<List<dynamic>> searchTugas(String keyword) async {
    final res = await api.get(
      "/tugas/search",
      queryParameters: {"search": keyword},
    );

    return res.data["data"];
  }
}