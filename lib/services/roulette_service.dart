import 'package:dio/dio.dart';
import 'api_service.dart';

class RouletteService {
  static final RouletteService instance = RouletteService._();
  RouletteService._();

  Future<Map<String, dynamic>> spin() async {
    final res = await ApiService().dio.post(
      "/roulette/spin",
      options: Options(validateStatus: (_) => true),
    );

    if (res.data["success"] == false) {
      throw Exception(res.data["message"]);
    }

    return res.data["data"];
  }
  Future<int> getRemainingSpins() async {
    final res = await ApiService().dio.get(
      "/roulette/spin",
      options: Options(validateStatus: (_) => true),
    );

    if (res.data["success"] == false) {
      throw Exception(res.data["message"]);
    }

    return res.data["data"]["spins"] ?? 0;
  }
}