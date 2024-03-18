import 'package:app/resources/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      if (AppSettings.hasConnection) {
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
      }

      AppSettings.hasConnection = false;
    } else {
      if (!AppSettings.hasConnection) {
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
      }

      AppSettings.hasConnection = true;
    }
  }
}
