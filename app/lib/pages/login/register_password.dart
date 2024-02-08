import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPasswordPage extends StatefulWidget {
  const RegisterPasswordPage({super.key});

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

    return FlexusGradientContainer(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.15),
          Row(
            children: [
              SizedBox(
                width: screenWidth * 0.15,
                child: IconButton(
                  onPressed: () => Navigator.popAndPushNamed(context, "/register_username"),
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
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: screenWidth * 0.7,
            child: Text(
              "The password must be at least 8 characters. We recommend a password with more than 16 characters, including special characters.",
              style: TextStyle(
                color: AppSettings.font,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontsizeSubDescription,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: screenHeight * 0.07),
          FlexusTextField(hintText: "Password", textController: passwordController),
          SizedBox(height: screenHeight * 0.03),
          FlexusTextField(hintText: "Confirm Password", textController: confirmPasswordController),
          const Spacer(flex: 1),
          FlexusButton(
            text: "CONTINUE (2/3)",
            route: "/register_name",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }
}
