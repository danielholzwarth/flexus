import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button_small.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusShowModalBottomSheetTextField {
  static PersistentBottomSheetController show({
    required BuildContext context,
    required String title,
    required TextEditingController textEditingController,
    String? hintText,
    Function()? onCancel,
    Function()? onConfirm,
  }) {
    Size deviceSize = MediaQuery.of(context).size;

    return showBottomSheet(
      backgroundColor: AppSettings.background,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: CustomDefaultTextStyle(
                text: title,
                fontSize: AppSettings.fontSizeH3,
              ),
            ),
            FlexusTextField(
              hintText: hintText ?? title,
              textController: textEditingController,
              onChanged: (String newValue) {},
            ),
            SizedBox(height: deviceSize.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlexusButtonSmall(
                  text: "Cancel",
                  width: deviceSize.width * 0.3,
                  fontColor: AppSettings.error,
                  onPressed: onCancel ?? () {},
                ),
                FlexusButtonSmall(
                  text: "Confirm",
                  width: deviceSize.width * 0.3,
                  onPressed: onConfirm ?? () {},
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
