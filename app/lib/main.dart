import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/pages/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await initializeHive();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Check if user has an jwt or not --> logged in
    final userBox = Hive.box('userBox');
    if (userBox.get("jwtToken") != null) {
      return const MaterialApp(
        initialRoute: '/home',
        onGenerateRoute: AppRoutes.generateRoute,
      );
    } else {
      return const MaterialApp(
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
      );
    }
  }
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  try {
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserAccountAdapter());

    var userBox = await Hive.openBox('userBox');
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Hive: $e');
    }
  }
}
