import 'dart:io';

import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/best_lift.dart';
import 'package:app/hive/best_lift_overview.dart';
import 'package:app/hive/exercise.dart';
import 'package:app/hive/friendship.dart';
import 'package:app/hive/gym.dart';
import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/notification.dart';
import 'package:app/hive/plan.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_account_gym_overview.dart';
import 'package:app/hive/user_list.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/sign_in/startup.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/dependency_injection.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await initializeHive();

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MainApp());

  DependencyInjection.init();

  if (AppSettings.hasConnection) await getUserSettings();
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
      return const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: PageViewPage(isFirst: true),
      );
    } else {
      return const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartUpPage(),
      );
    }
  }
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  try {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAccountAdapter()); //0
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserSettingsAdapter()); //1
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WorkoutAdapter()); //2
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(WorkoutOverviewAdapter()); //3
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(FriendshipAdapter()); //4
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(BestLiftAdapter()); //5
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(BestLiftOverviewAdapter()); //6
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(GymAdapter()); //7
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(GymOverviewAdapter()); //8
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(UserAccountGymOverviewAdapter()); //9
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(ExerciseAdapter()); //10
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(UserListAdapter()); //11
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(PlanAdapter()); //12
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(NotificationAdapter()); //13

    if (!Hive.isBoxOpen('userBox')) await Hive.openBox('userBox');
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
    chopper.Response<dynamic> response = await userSettingsService.getUserSettings(userBox.get("flexusjwt"));

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
