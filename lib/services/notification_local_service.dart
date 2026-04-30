import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifService {
  static final LocalNotifService instance = LocalNotifService._();
  LocalNotifService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings, 
    );
  }

  Future<void> showNotif({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'notif_channel',
      'Notifikasi Driver',
      channelDescription: 'Notifikasi tugas driver',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
    );
    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    await flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notifDetails,
    );
  }
}