import 'dart:async';
import 'dart:ui';

import 'package:app/api/notification/notification_service.dart';
import 'package:app/hive/notification/notification.dart' as noti;
import 'package:app/main.dart';
import 'package:app/resources/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance serviceInstance) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance serviceInstance) async {
  if (serviceInstance is AndroidServiceInstance) {
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });
    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }
  serviceInstance.on('stopService').listen((event) {
    serviceInstance.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    NotificationService notificationService = NotificationService.create();

    await initializeHive();
    Box userBox = Hive.box("userBox");
    String flexusJWT = userBox.get("flexusjwt");

    final response = await notificationService.fetchData(flexusJWT);
    List<noti.Notification> notifications = [];

    if (response.isSuccessful) {
      if (response.body != "null") {
        final List<dynamic> jsonList = response.body;
        notifications = jsonList.where((json) => json['gymName'] != "null").map((json) {
          return noti.Notification(
            title: "${json['username']} sent you a notification!",
            body: "${json['username']} will be at ${json['gymName']} at ${DateFormat('hh:mm').format(DateTime.parse(json['startTime']))}!",
            payload: "payload",
          );
        }).toList();

        debugPrint("Successful fetch - ${notifications.length} notifications");

        for (var notification in notifications) {
          LocalNotifications.showNotification(
            title: notification.title,
            body: notification.body,
            payload: notification.payload,
          );
          await Future.delayed(const Duration(seconds: 6));
        }
      } else {
        debugPrint("Successful fetch - No update");
      }
    } else {
      debugPrint("Error: Unsuccessful fetch!");
    }

    serviceInstance.invoke('update');
  });
}
