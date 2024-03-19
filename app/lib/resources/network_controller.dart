import 'package:app/api/user_account_service.dart';
import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/resources/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
      Get.rawSnackbar(
        messageText: Text(
          'Internet disconnected',
          style: TextStyle(
            color: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
        isDismissible: false,
        backgroundColor: AppSettings.error,
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );

      AppSettings.hasConnection = false;
    } else {
      synchronizeData();

      Get.rawSnackbar(
        messageText: Text(
          'Internet reconnected',
          style: TextStyle(
            color: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
        isDismissible: false,
        backgroundColor: AppSettings.confirm,
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );

      AppSettings.hasConnection = true;
    }
  }

  void synchronizeData() {
    final userBox = Hive.box("userBox");

    UserAccountService userAccountService = UserAccountService.create();
    UserAccount userAccount = userBox.get("userAccount");
    userAccountService.patchEntireUserAccount(userBox.get("flexusjwt"), {
      "username": userAccount.username,
      "name": userAccount.name,
      "level": userAccount.level,
      "profilePicture": userAccount.profilePicture,
    });

    UserSettingsService userSettingsService = UserSettingsService.create();
    UserSettings userSettings = userBox.get("userSettings");
    userSettingsService.patchEntireUserSettings(userBox.get("flexusjwt"), {
      "fontSize": userSettings.fontSize,
      "isDarkMode": userSettings.isDarkMode,
      "isUnlisted": userSettings.isUnlisted,
      "isPullFromEveryone": userSettings.isPullFromEveryone,
      "isNotifyEveryone": userSettings.isNotifyEveryone,
      "isQuickAccess": userSettings.isQuickAccess,
    });

    // WorkoutService workoutService = WorkoutService.create();
    // workoutService.patchEntireWorkouts(userBox.get("workoutOverviews"));
  }
}
