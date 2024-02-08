import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
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

    return FlexusGradientContainer(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.15),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "Please enter your username.",
              style: TextStyle(
                color: AppSettings.font,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontsizeTitle,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: screenWidth * 0.8,
            child: Text(
              "The username is not the name displayed to your friends. Every username must only exist once. You can still change it later.",
              style: TextStyle(
                color: AppSettings.font,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontsizeSubDescription,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: screenHeight * 0.07),
          FlexusTextField(
            hintText: "Username",
            textController: usernameController,
          ),
          SizedBox(height: screenHeight * 0.25),
          const Spacer(flex: 1),
          FlexusButton(
            text: "CONTINUE",
            route: "/register_password",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }
}
