import 'package:app/pages/login/login.dart';
import 'package:app/pages/login/register_username.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}

class _StartUpPageState extends State<StartUpPage> {
  @override
  Widget build(BuildContext context) {
    return FlexusGradientScaffold(
      topColor: AppSettings.startUp,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSettings.screenHeight * 0.05),
            _buildLanguageDetector(),
            SizedBox(height: AppSettings.screenHeight * 0.045),
            Icon(
              Icons.star,
              size: 100,
              color: AppSettings.background,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            Text(
              "FLEXUS",
              style: TextStyle(
                color: AppSettings.fontV1,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontSizeMainTitle,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.27),
            SizedBox(
              width: AppSettings.screenWidth * 0.7,
              child: Text(
                "This is just a demo Application. If you tap Sign up I get the right of all of your data :P",
                style: TextStyle(
                  color: AppSettings.fontV1,
                  decoration: TextDecoration.none,
                  fontSize: AppSettings.fontSizeDescription,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSettings.screenHeight * 0.07),
            _buildSignUpButton(context),
            SizedBox(height: AppSettings.screenHeight * 0.03),
            _buildLoginButton(context),
            SizedBox(height: AppSettings.screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildLoginButton(BuildContext context) {
    return FlexusButton(
      text: "LOGIN",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const LoginPage(),
          ),
        );
      },
    );
  }

  FlexusButton _buildSignUpButton(BuildContext context) {
    return FlexusButton(
      text: "SIGN UP",
      function: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const RegisterUsernamePage(),
          ),
        );
      },
    );
  }

  GestureDetector _buildLanguageDetector() {
    return GestureDetector(
      onTap: () {
        setState(() {
          AppSettings.language == "DE" ? AppSettings.language = "ENG" : AppSettings.language = "DE";
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.language,
            size: AppSettings.fontSizeTitleSmall,
            color: AppSettings.fontV1,
          ),
          SizedBox(
            width: AppSettings.screenWidth * 0.02,
          ),
          Text(
            AppSettings.language,
            style: TextStyle(
              fontSize: AppSettings.fontSizeTitleSmall,
              color: AppSettings.fontV1,
            ),
          ),
          SizedBox(
            width: AppSettings.screenWidth * 0.07,
          ),
        ],
      ),
    );
  }
}
