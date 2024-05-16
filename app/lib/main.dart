import 'dart:io';

import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/hive/best_lift/best_lift.dart';
import 'package:app/hive/best_lift/best_lift_overview.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/friendship/friendship.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/gym/gym_overview.dart';
import 'package:app/hive/notification/notification.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/plan/plan_overview.dart';
import 'package:app/hive/set/workout_set.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/hive/split/split_overview.dart';
import 'package:app/hive/statistic/statistic.dart';
import 'package:app/hive/timer/timer_value.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_account_gym/user_account_gym_overview.dart';
import 'package:app/hive/user_list/user_list.dart';
import 'package:app/hive/user_settings/user_settings.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_details.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/pages/sign_in/start.dart';
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
    DateTime dateTime = DateTime.now();
    AppSettings.timeZoneOffset = dateTime.timeZoneOffset;

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
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAccountAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserSettingsAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WorkoutAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(WorkoutOverviewAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(FriendshipAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(BestLiftAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(BestLiftOverviewAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(GymAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(GymOverviewAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(UserAccountGymOverviewAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(UserListAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(PlanAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(NotificationAdapter());
    if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(PlanOverviewAdapter());
    if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(SplitAdapter());
    if (!Hive.isAdapterRegistered(16)) Hive.registerAdapter(SplitOverviewAdapter());
    if (!Hive.isAdapterRegistered(17)) Hive.registerAdapter(WorkoutDetailsAdapter());
    if (!Hive.isAdapterRegistered(18)) Hive.registerAdapter(MeasurementAdapter());
    if (!Hive.isAdapterRegistered(19)) Hive.registerAdapter(WorkoutSetAdapter());
    if (!Hive.isAdapterRegistered(20)) Hive.registerAdapter(CurrentWorkoutAdapter());
    if (!Hive.isAdapterRegistered(21)) Hive.registerAdapter(CurrentExerciseAdapter());
    if (!Hive.isAdapterRegistered(22)) Hive.registerAdapter(CurrentPlanAdapter());
    if (!Hive.isAdapterRegistered(23)) Hive.registerAdapter(TimerValueAdapter());
    if (!Hive.isAdapterRegistered(24)) Hive.registerAdapter(StatisticAdapter());

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
      if (response.body != null) {
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
