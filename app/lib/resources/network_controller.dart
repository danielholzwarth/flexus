import 'package:app/api/plan/plan_service.dart';
import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/api/workout/workout_service.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
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

  void synchronizeData() {
    final userBox = Hive.box("userBox");

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

    WorkoutService workoutService = WorkoutService.create();
    List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews")?.cast<WorkoutOverview>() ?? [];
    if (workoutOverviews.isNotEmpty) {
      workoutService
          .patchEntireWorkouts(userBox.get("flexusjwt"), {"workouts": workoutOverviews.map((overview) => overview.workout.toJson()).toList()});
    }
    // else {
    //   workoutService.deleteAllWorkouts(userBox.get("flexusjwt"));
    // }

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
}
