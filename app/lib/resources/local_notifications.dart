import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {});
  }

  static Future showNotification({required String title, required String body, required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'Load gym attendance',
      channelDescription: 'Sends a notification whenever a friends starts working out',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      timeoutAfter: 5000,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(Random().nextInt(1000), title, body, notificationDetails, payload: payload);
  }
}
