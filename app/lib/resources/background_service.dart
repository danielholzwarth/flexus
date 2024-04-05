import 'dart:async';
import 'dart:ui';

import 'package:app/api/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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
      isForegroundMode: true,
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
  DartPluginRegistrant.ensureInitialized();
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
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    if (serviceInstance is AndroidServiceInstance) {
      if (await serviceInstance.isForegroundService()) {
        serviceInstance.setForegroundNotificationInfo(title: "Flexus", content: "Fetching content");
      }
    }

    NotificationService notificationService = NotificationService.create();
    final response = await notificationService.fetchData(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyQWNjb3VudElEIjoxLCJ1c2VybmFtZSI6ImRob2x6d2FydGgiLCJleHAiOjE3MTQ5MTIwMDl9.KjGcIj67YF0Hn5VwUnmkb8-4Lqwyw_TG4Muzk_tdkUA");
    if (response.isSuccessful) {
      print("fetched: ${response.body}");
    } else {
      print("unsuccessful fetch");
    }

    serviceInstance.invoke('update');
  });
}
