import 'package:app/api/user_account_service.dart';
import 'package:app/hive/user_account.dart';
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
    // Sync Data
    // userSettings
    // workoutOverviews
    final userBox = Hive.box("userBox");
    UserAccountService userAccountService = UserAccountService.create();
    // UserSettingsService userSettingsService = UserSettingsService.create();
    // WorkoutService workoutService = WorkoutService.create();

    UserAccount userAccount = userBox.get("userAccount");

    userAccountService.patchEntireUserAccount(userBox.get("flexusjwt"), {
      "username": userAccount.username,
      "name": userAccount.name,
      "level": userAccount.level,
      "profilePicture": userAccount.profilePicture,
    });
    // userSettingsService.patchEntireUserSettings(userBox.get("userSettings"));
    // workoutService.patchEntireWorkouts(userBox.get("workoutOverviews"));
  }
}
