import 'dart:io';

import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/best_lift.dart';
import 'package:app/hive/best_lift_overview.dart';
import 'package:app/hive/friendship.dart';
import 'package:app/hive/gym.dart';
import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_account_gym_overview.dart';
import 'package:app/hive/user_list.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/sign_in/startup.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  await initializeHive();

  await getUserSettings();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings.screenHeight = MediaQuery.of(context).size.height;
    AppSettings.screenWidth = MediaQuery.of(context).size.width;

    final userBox = Hive.box('userBox');
    final flexusjwt = userBox.get("flexusjwt");
    if (flexusjwt != null) {
      return const MaterialApp(
        home: PageViewPage(isFirst: true),
      );
    } else {
      return const MaterialApp(
        home: StartUpPage(),
      );
    }
  }
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  try {
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserAccountAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(WorkoutOverviewAdapter());
    Hive.registerAdapter(BestLiftAdapter());
    Hive.registerAdapter(BestLiftOverviewAdapter());
    Hive.registerAdapter(GymOverviewAdapter());
    Hive.registerAdapter(FriendshipAdapter());
    Hive.registerAdapter(GymAdapter());
    Hive.registerAdapter(UserAccountGymOverviewAdapter());
    Hive.registerAdapter(UserListAdapter());

    await Hive.openBox('userBox');
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Hive: $e');
    }
  }
}

Future<void> getUserSettings() async {
  UserSettingsService userSettingsService = UserSettingsService.create();
  final userBox = Hive.box('userBox');
  final flexusjwt = userBox.get("flexusjwt");

  if (flexusjwt != null) {
    Response<dynamic> response = await userSettingsService.getUserSettings(userBox.get("flexusjwt"));

    if (response.isSuccessful) {
      if (response.body != "null") {
        final Map<String, dynamic> jsonMap = response.body;

        final userSettings = UserSettings(
          id: jsonMap['id'],
          userAccountID: jsonMap['userAccountID'],
          fontSize: double.parse(jsonMap['fontSize'].toString()),
          isDarkMode: jsonMap['isDarkMode'],
          languageID: jsonMap['languageID'],
          isUnlisted: jsonMap['isUnlisted'],
          isPullFromEveryone: jsonMap['isPullFromEveryone'],
          pullUserListID: jsonMap['pullUserListID'],
          isNotifyEveryone: jsonMap['isNotifyEveryone'],
          notifyUserListID: jsonMap['notifyUserListID'],
          isQuickAccess: jsonMap['isQuickAccess'],
        );

        userBox.put("userSettings", userSettings);
        debugPrint("Settings found!");
      } else {
        debugPrint("No Settings found!");
      }
    } else {
      debugPrint("Internal Server Error");
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
