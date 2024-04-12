import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlexusGet {
  static Future<void> showGetSnackbar({
    required String message,
    Color? fontColor,
    TextAlign? textAlign,
    bool? isDismissible,
    Color? backgroundColor,
    SnackStyle? snackStyle,
    Duration? duration = const Duration(seconds: 3),
  }) async {
    if (!Get.isSnackbarOpen) {
      Get.rawSnackbar(
        messageText: CustomDefaultTextStyle(
          text: message,
          color: fontColor ?? AppSettings.fontV1,
          textAlign: textAlign ?? TextAlign.center,
        ),
        isDismissible: isDismissible ?? false,
        backgroundColor: backgroundColor ?? AppSettings.primary,
        margin: EdgeInsets.zero,
        snackStyle: snackStyle ?? SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
        duration: duration,
      );
    }
    if (duration != null) {
      await Future.delayed(Duration(seconds: duration.inSeconds + 1));
    }
  }
}
