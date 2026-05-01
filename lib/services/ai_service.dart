import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AIService {
  static final AIService instance = AIService._();
  AIService._();

  Future<String> sendMessage(String message) async {
    try {
      final res = await ApiService().dio.post(
        "/ai/chat",
        data: {"message": message},
        options: Options(validateStatus: (_) => true),
      );

      if (res.data["success"] == false) {
        return res.data["message"];
      }

      return res.data["data"];
    } on DioException catch (e) {
      return e.response?.data["message"] ?? "AI error";
    }
  }
}