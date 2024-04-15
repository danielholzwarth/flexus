import 'package:app/pages/sign_in/login.dart';
import 'package:app/pages/sign_in/register_username.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
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
            // _buildLanguageDetector(),
            SizedBox(height: AppSettings.screenHeight * 0.045),
            FlexusDefaultIcon(
              iconData: Icons.star,
              iconSize: AppSettings.screenHeight * 0.17,
              iconColor: AppSettings.background,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            CustomDefaultTextStyle(
              text: "FLEXUS",
              color: AppSettings.fontV1,
              decoration: TextDecoration.none,
              fontSize: AppSettings.fontSizeH1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.2),
            SizedBox(
              width: AppSettings.screenWidth * 0.7,
              child: CustomDefaultTextStyle(
                text: "This is just a demo Application. If you tap Sign up I get the right of all of your data :P",
                color: AppSettings.fontV1,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontSizeT2,
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
          FlexusDefaultIcon(
            iconData: Icons.language,
            iconSize: AppSettings.fontSizeH4,
            iconColor: AppSettings.fontV1,
          ),
          SizedBox(
            width: AppSettings.screenWidth * 0.02,
          ),
          CustomDefaultTextStyle(
            text: AppSettings.language,
            fontSize: AppSettings.fontSizeH4,
            color: AppSettings.fontV1,
          ),
          SizedBox(
            width: AppSettings.screenWidth * 0.07,
          ),
        ],
      ),
    );
  }
}
