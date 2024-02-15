import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/pages/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<void> main() async {
  await initializeHive();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final flexusjwt = userBox.get("flexusjwt");
    if (flexusjwt != null) {
      if (!JwtDecoder.isExpired(flexusjwt)) {
        return const MaterialApp(
          initialRoute: '/home',
          onGenerateRoute: AppRoutes.generateRoute,
        );
      } else {
        return const MaterialApp(
          initialRoute: '/login',
          onGenerateRoute: AppRoutes.generateRoute,
        );
      }
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
