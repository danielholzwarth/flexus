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
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class RegisterUsernamePage extends StatefulWidget {
  const RegisterUsernamePage({super.key});

  @override
  State<RegisterUsernamePage> createState() => _RegisterUsernamePageState();
}

class _RegisterUsernamePageState extends State<RegisterUsernamePage> {
  final TextEditingController usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final loginUserAccountService = LoginUserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: deviceSize.height * 0.15),
            _buildTitleRow(context, deviceSize),
            SizedBox(height: deviceSize.height * 0.02),
            _buildDescription(deviceSize),
            SizedBox(height: deviceSize.height * 0.02),
            _buildBulletPoints(),
            SizedBox(height: deviceSize.height * 0.07),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: deviceSize.height * 0.3),
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
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Username must be at least 6 characters long!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        } else if (usernameController.text.length > 20) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Username must be shorter than 20 characters!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        } else {
          final response = await loginUserAccountService.getUsernameAvailability(usernameController.text);
          if (response.statusCode == 200) {
            final bool availability = response.body;
            if (!availability) {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: "Username is already assigned!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              setState(() {});
            } else {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: RegisterNamePage(username: usernameController.text),
                ),
              );
            }
          } else {
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: "Statuscode ${response.statusCode}\nError: ${response.error}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: AppSettings.error,
              textColor: AppSettings.fontV1,
              fontSize: AppSettings.fontSize,
            );
          }
        }
      },
    );
  }

  SizedBox _buildDescription(Size deviceSize) {
    return SizedBox(
      width: deviceSize.width * 0.7,
      child: CustomDefaultTextStyle(
        text: "A username can only exist once. It is used to identify you.",
        decoration: TextDecoration.none,
        fontSize: AppSettings.fontSize,
        textAlign: TextAlign.left,
      ),
    );
  }

  Row _buildTitleRow(BuildContext context, Size deviceSize) {
    return Row(
      children: [
        SizedBox(
          width: deviceSize.width * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/"),
            icon: FlexusDefaultIcon(iconData: Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeH3,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.7,
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
