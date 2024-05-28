import 'package:app/api/plan/plan_service.dart';
import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/api/workout/workout_service.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/workout/pending_workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    print("status: $connectivityResult");
    if (connectivityResult == ConnectivityResult.none) {
      if (AppSettings.hasConnection == true) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: "Internet disconnected!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppSettings.error,
          textColor: AppSettings.fontV1,
          fontSize: AppSettings.fontSize,
        );
      }

      AppSettings.hasConnection = false;
    } else {
      synchronizeData();

      if (AppSettings.hasConnection == false) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: "Internet reconnected!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppSettings.confirm,
          textColor: AppSettings.fontV1,
          fontSize: AppSettings.fontSize,
        );
      }

      AppSettings.hasConnection = true;
    }
  }

  Future<void> synchronizeData() async {
    final userBox = Hive.box("userBox");
    await syncUserAccount(userBox);
    await syncUserSettings(userBox);
    await syncWorkouts(userBox);
    await syncPlans(userBox);
  }
}

Future<void> syncUserAccount(Box userBox) async {
  UserAccountService userAccountService = UserAccountService.create();
  final userAccount = userBox.get("userAccount");
  if (userAccount != null) {
    userAccountService.patchEntireUserAccount(userBox.get("flexusjwt"), {
      "username": userAccount.username,
      "name": userAccount.name,
      "level": userAccount.level,
      "profilePicture": userAccount.profilePicture,
    });
  }
}

Future<void> syncUserSettings(Box userBox) async {
  UserSettingsService userSettingsService = UserSettingsService.create();
  final userSettings = userBox.get("userSettings");
  if (userSettings != null) {
    userSettingsService.patchEntireUserSettings(userBox.get("flexusjwt"), {
      "fontSize": userSettings.fontSize,
      "isDarkMode": userSettings.isDarkMode,
      "isUnlisted": userSettings.isUnlisted,
      "isPullFromEveryone": userSettings.isPullFromEveryone,
      "isNotifyEveryone": userSettings.isNotifyEveryone,
      "isQuickAccess": userSettings.isQuickAccess,
    });
  }
}

Future<void> syncWorkouts(Box userBox) async {
  WorkoutService workoutService = WorkoutService.create();

  List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews")?.cast<WorkoutOverview>() ?? [];
  List<PendingWorkout> pendingWorkouts = userBox.get("pendingWorkouts")?.cast<PendingWorkout>() ?? [];

  List<WorkoutOverview> nonPendingWorkoutOverviews = workoutOverviews
      .where((wO) =>
          pendingWorkouts.firstWhereOrNull(
            (pend) => pend.id == wO.workout.id,
          ) ==
          null)
      .toList();

  List<WorkoutOverview> pendingWorkoutOverviews = workoutOverviews
      .where((wO) =>
          pendingWorkouts.firstWhereOrNull(
            (pend) => pend.id == wO.workout.id,
          ) !=
          null)
      .toList();

  print("checkpoint");

  if (nonPendingWorkoutOverviews.isNotEmpty) {
    workoutService.patchEntireWorkouts(
      userBox.get("flexusjwt"),
      {"workouts": nonPendingWorkoutOverviews.map((overview) => overview.workout.toJson()).toList()},
    );
  }
  // else {
  //   workoutService.deleteAllWorkouts(userBox.get("flexusjwt"));
  // }

  final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');

  for (var pendingWorkout in pendingWorkouts) {
    WorkoutOverview? pendingWorkoutOverview = pendingWorkoutOverviews.firstWhereOrNull((element) => element.workout.id == pendingWorkout.workoutID);

    if (pendingWorkout.workoutID < 0) {
      final String formattedStartTime = "${formatter.format(pendingWorkoutOverview!.workout.starttime.subtract(AppSettings.timeZoneOffset))}Z";

      await workoutService.postWorkout(userBox.get("flexusjwt"), {
        "gymID": pendingWorkout.gymID,
        "splitID": pendingWorkout.splitID,
        "starttime": formattedStartTime,
        "isActive": true,
      });
    }

    if (pendingWorkout.exercisesJSON.isNotEmpty) {
      await workoutService.patchFinishWorkout(userBox.get("flexusjwt"), {
        "planID": pendingWorkout.planID,
        "splitID": pendingWorkout.splitID,
        "gymID": pendingWorkout.gymID,
        "exercises": pendingWorkout.exercisesJSON,
      });
    }

    if (pendingWorkoutOverview?.workout.isActive == false && pendingWorkout.exercisesJSON.isEmpty) {
      await workoutService.patchFinishWorkout(userBox.get("flexusjwt"), {
        "planID": pendingWorkout.planID,
        "splitID": pendingWorkout.splitID,
        "gymID": pendingWorkout.gymID,
        "exercises": pendingWorkout.exercisesJSON,
      });
    }
  }

  //GetWorkouts from Server

  userBox.delete("workoutOverviews");
  userBox.delete("pendingWorkouts");
}

Future<void> syncPlans(Box userBox) async {
  PlanService planService = PlanService.create();
  List<Plan> plans = userBox.get("plans")?.cast<Plan>() ?? [];
  if (plans.isNotEmpty) {
    planService.patchEntirePlans(userBox.get("flexusjwt"), {"plans": plans.map((plan) => plan.toJson()).toList()});
  }
  // else {
  //   planService.deleteAllPlans(userBox.get("flexusjwt"));
  // }
  // if (plans)
}
