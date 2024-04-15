// ignore_for_file: use_build_context_synchronously

import 'package:app/api/login_user_account/login_user_account_service.dart';
import 'package:app/pages/sign_in/register_name.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:app/widgets/style/flexus_get_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class RegisterUsernamePage extends StatefulWidget {
  const RegisterUsernamePage({super.key});

  @override
  State<RegisterUsernamePage> createState() => _RegisterUsernamePageState();
}

class _RegisterUsernamePageState extends State<RegisterUsernamePage> {
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginUserAccountService = LoginUserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSettings.screenHeight * 0.15),
            _buildTitleRow(context),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            _buildDescription(),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            _buildBulletPoints(),
            SizedBox(height: AppSettings.screenHeight * 0.07),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: AppSettings.screenHeight * 0.3),
            _buildContinueButton(context, loginUserAccountService),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildContinueButton(BuildContext context, LoginUserAccountService loginUserAccountService) {
    return FlexusButton(
      text: "CONTINUE (1/3)",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        if (usernameController.text.length < 6) {
          await FlexusGet.showGetSnackbar(message: "Username must be at least 6 characters long!");
        } else if (usernameController.text.length > 20) {
          await FlexusGet.showGetSnackbar(message: "Username must be shorter than 20 characters!");
        } else {
          final response = await loginUserAccountService.getUsernameAvailability(usernameController.text);
          if (response.statusCode == 200) {
            final bool availability = response.body;
            if (!availability) {
              await FlexusGet.showGetSnackbar(message: "Username is already assigned!");
              setState(() {});
            } else {
              if (!Get.isSnackbarOpen) {
                Get.closeCurrentSnackbar();
              }
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: RegisterNamePage(username: usernameController.text),
                ),
              );
            }
          } else {
            await FlexusGet.showGetSnackbar(message: "Statuscode ${response.statusCode}\nError: ${response.error}");
          }
        }
      },
    );
  }

  SizedBox _buildDescription() {
    return SizedBox(
      width: AppSettings.screenWidth * 0.7,
      child: CustomDefaultTextStyle(
        text: "A username can only exist once. It is used to identify you.",
        decoration: TextDecoration.none,
        fontSize: AppSettings.fontSize,
        textAlign: TextAlign.left,
      ),
    );
  }

  Row _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSettings.screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/"),
            icon: FlexusDefaultIcon(iconData: Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeH3,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: AppSettings.screenWidth * 0.7,
          child: CustomDefaultTextStyle(
            text: "Please enter your username.",
            decoration: TextDecoration.none,
            fontSize: AppSettings.fontSizeH3,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Column _buildBulletPoints() {
    return Column(
      children: [
        FlexusBulletPoint(
          text: "At least 6 characters",
          condition: usernameController.text.length >= 6,
        ),
        FlexusBulletPoint(
          text: "Maximum 20 characters",
          condition: usernameController.text.length <= 20,
        ),
      ],
    );
  }
}
