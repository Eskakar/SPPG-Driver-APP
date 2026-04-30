import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifService {
  static final LocalNotifService instance = LocalNotifService._();
  LocalNotifService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notifDetails,
    );
  }
}