import 'dart:async';
import 'dart:ui';

import 'package:app/api/notification/notification_service.dart';
import 'package:app/hive/notification/notification.dart' as noti;
import 'package:app/main.dart';
import 'package:app/resources/jwt_helper.dart';
import 'package:app/resources/local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
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
    debugPrint("starting background service");
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });
    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }
  serviceInstance.on('stopService').listen((event) {
    debugPrint("stopping background service");
    serviceInstance.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    NotificationService notificationService = NotificationService.create();

    await initializeHive();
    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await notificationService.getNewWorkoutNotifications(flexusjwt);
    List<noti.Notification> notifications = [];

    Duration timeZoneOffset = DateTime.now().timeZoneOffset;

    if (!response.isSuccessful) {
      debugPrint("Error: Unsuccessful fetch!");
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body == "null") {
      debugPrint("Successful fetch - No update");
      return;
    }

    final List<dynamic> jsonList = response.body;
    notifications = jsonList.where((json) => json['gymName'] != "null").map((json) {
      return noti.Notification(
        title: "${json['username']} sent you a notification!",
        body:
            "${json['username']} will be at ${json['gymName']} at ${DateFormat('HH:mm').format(DateTime.parse(json['startTime']).add(timeZoneOffset))}!",
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

    serviceInstance.invoke('update');
  });
}
