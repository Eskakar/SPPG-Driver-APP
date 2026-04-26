import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final _storage = const FlutterSecureStorage();

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(
      key: "biometric_enabled",
      value: value.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: "biometric_enabled");
    return value == "true";
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}