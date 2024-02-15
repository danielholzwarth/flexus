// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class RegisterUsernamePage extends StatefulWidget {
  const RegisterUsernamePage({super.key});

  @override
  State<RegisterUsernamePage> createState() => _RegisterUsernamePageState();
}

class _RegisterUsernamePageState extends State<RegisterUsernamePage> {
  final TextEditingController usernameController = TextEditingController();

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
            _buildDescription(screenWidth),
            SizedBox(height: screenHeight * 0.02),
            _buildBulletPoints(screenWidth),
            SizedBox(height: screenHeight * 0.07),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: screenHeight * 0.3),
            _buildContinueButton(context, userAccountService),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildContinueButton(BuildContext context, UserAccountService userAccountService) {
    return FlexusButton(
      text: "CONTINUE (1/3)",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        if (usernameController.text.length < 6) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Username must be at least 6 characters long!'),
              ),
            ),
          );
        } else if (usernameController.text.length > 20) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Username must be shorter than 20 characters!'),
              ),
            ),
          );
        } else {
          final response = await userAccountService.getUsernameAvailability(usernameController.text);
          if (response.statusCode == 200) {
            final bool availability = response.body;
            if (!availability) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text('Username is already assigned!'),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pushNamed(context, "/register_name", arguments: usernameController.text);
            }
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

  SizedBox _buildDescription(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.7,
      child: Text(
        "A username can only exist once. It is used to identify you.",
        style: TextStyle(
          color: AppSettings.font,
          decoration: TextDecoration.none,
          fontSize: AppSettings.fontSizeSubDescription,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Row _buildTitleRow(double screenWidth, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeTitle,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Text(
            "Please enter your username.",
            style: TextStyle(
              color: AppSettings.font,
              decoration: TextDecoration.none,
              fontSize: AppSettings.fontSizeTitle,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Column _buildBulletPoints(double screenWidth) {
    return Column(
      children: [
        FlexusBulletPoint(
          text: "At least 6 characters",
          screenWidth: screenWidth,
          condition: usernameController.text.length >= 6,
        ),
        FlexusBulletPoint(
          text: "Maximum 20 characters",
          screenWidth: screenWidth,
          condition: usernameController.text.length <= 20,
        ),
      ],
    );
  }
}
