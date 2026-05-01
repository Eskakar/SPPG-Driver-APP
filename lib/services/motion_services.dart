import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class MotionService {
  static final MotionService instance = MotionService._();
  MotionService._();

  StreamSubscription<AccelerometerEvent>? _sub;

  DateTime _lastEventTime = DateTime.fromMillisecondsSinceEpoch(0);

  void startListening({
    required Function(String) onEvent,
  }) {
    _sub = accelerometerEventStream().listen((event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      // 🔥 hitung magnitude (lebih akurat)
      final total = sqrt(x * x + y * y + z * z);

      final now = DateTime.now();

      // cooldown 2 detik
      if (now.difference(_lastEventTime).inSeconds < 2) {
        return;
      }

      if (total > 25) {
        onEvent("Rem mendadak 🚨");
        _lastEventTime = now;
      } else if (total > 20) {
        onEvent("Akselerasi kasar ⚠️");
        _lastEventTime = now;
      }
      
    });
  }

  void stop() {
    _sub?.cancel();
  }
}