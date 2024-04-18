import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlexusBasicDialog {
  static Future<dynamic> showBasicFlexusDialog({
    required BuildContext context,
    Function()? onPressedLeft,
    Function()? onPressedRight,
    String? hintText,
    String? optionLeft,
    String? optionRight,
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? hintColor,
  }) {
    TextEditingController textEditingController = TextEditingController();

    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: backgroundColor ?? AppSettings.background,
              surfaceTintColor: surfaceTintColor ?? AppSettings.background,
              content: TextField(
                controller: textEditingController,
                autofocus: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: hintText ?? "",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: hintColor ?? AppSettings.font),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppSettings.background),
                        surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                        overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                        foregroundColor: MaterialStateProperty.all(AppSettings.error),
                        fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.25)),
                      ),
                      onPressed: () {
                        if (onPressedLeft != null) onPressedLeft();
                        textEditingController.dispose;
                        Navigator.pop(context);
                      },
                      child: CustomDefaultTextStyle(text: optionLeft ?? 'Cancel'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppSettings.background),
                        surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                        overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                        foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                        fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.25)),
                      ),
                      onPressed: () {
                        if (onPressedRight != null) onPressedRight();
                        textEditingController.dispose;
                        Navigator.pop(context);
                      },
                      child: CustomDefaultTextStyle(text: optionRight ?? 'Confirm'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
