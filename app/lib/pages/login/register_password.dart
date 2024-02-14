// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPasswordPage extends StatefulWidget {
  final String username;
  final String name;

  const RegisterPasswordPage({
    super.key,
    required this.username,
    required this.name,
  });

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final userAccountService = UserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.15),
            _buildTitleRow(screenWidth, context),
            SizedBox(height: screenHeight * 0.02),
            _buildBulletPoints(screenWidth),
            SizedBox(height: screenHeight * 0.07),
            FlexusTextField(
              hintText: "Password",
              textController: passwordController,
              onChanged: (String newValue) {
                setState(() {});
              },
              isObscure: true,
            ),
            SizedBox(height: screenHeight * 0.03),
            FlexusTextField(
              hintText: "Confirm Password",
              textController: confirmPasswordController,
              onChanged: (String newValue) {
                setState(() {});
              },
              isObscure: true,
            ),
            SizedBox(height: screenHeight * 0.235),
            _buildCreateAccountButton(context, userAccountService),
            FlexusBottomSizedBox(screenHeight: screenHeight),
          ],
        ),
      ),
    );
  }

  Row _buildTitleRow(double screenWidth, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/register_name"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontsizeTitle,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.7,
          child: Text(
            "Please enter your password.",
            style: TextStyle(
              color: AppSettings.font,
              decoration: TextDecoration.none,
              fontSize: AppSettings.fontsizeTitle,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  FlexusButton _buildCreateAccountButton(BuildContext context, UserAccountService userAccountService) {
    return FlexusButton(
      text: "CREATE ACCOUNT (3/3)",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        if (passwordController.text.length < 8) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Password must be longer than 8 characters!'),
              ),
            ),
          );
        } else if (passwordController.text.length > 128) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Passwords must be shorter or equal to 128 characters!'),
              ),
            ),
          );
        } else if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Passwords are not equal!'),
              ),
            ),
          );
        } else {
          final response = await userAccountService.postUserAccount({
            "username": widget.username,
            "password": passwordController.text,
            "name": widget.name,
          });
          if (response.isSuccessful) {
            //SAVE JWT from post response
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text("Statuscode ${response.statusCode}\nError: ${response.error}"),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Column _buildBulletPoints(double screenWidth) {
    return Column(
      children: [
        FlexusBulletPoint(
          text: "At least 8 characters",
          screenWidth: screenWidth,
          condition: passwordController.text.length >= 8,
        ),
        FlexusBulletPoint(
          text: "Maximum 128 characters",
          screenWidth: screenWidth,
          condition: passwordController.text.length <= 128,
        ),
        FlexusBulletPoint(
          text: "Passwords must be equal",
          screenWidth: screenWidth,
          condition: passwordController.text == confirmPasswordController.text,
        ),
      ],
    );
  }
}
