import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

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
    dio.options.baseUrl = "http://10.0.2.2:3000/api/auth";

    isReady = true;
  }
}