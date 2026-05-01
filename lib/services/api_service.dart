import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  String baseUrl = dotenv.env['BASE_URL']!;
  late Dio dio;
  late PersistCookieJar cookieJar;
  bool isReady = false;

  ApiService._internal();

  Future<void> init() async {
    dio = Dio();

    final dir = await getApplicationDocumentsDirectory();

    cookieJar = PersistCookieJar(
      storage: FileStorage("${dir.path}/cookies"),
    );

    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.baseUrl = baseUrl;
    //dio.options.baseUrl = "http://10.0.2.2:3000/api";
    isReady = true;
  }
  Future<bool> checkSession() async {
    try {
      final res = await dio.get("/auth/me"); // endpoint user/me
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}