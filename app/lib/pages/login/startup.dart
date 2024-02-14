import 'package:app/resources/app_settings.dart';
import 'package:app/resources/user_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:flutter/material.dart';

class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}

class _StartUpPageState extends State<StartUpPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FlexusGradientScaffold(
      topColor: AppSettings.startUp,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            _buildLanguageDetector(screenWidth),
            SizedBox(height: screenHeight * 0.045),
            Icon(
              Icons.star,
              size: 100,
              color: AppSettings.background,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "FLEXUS",
              style: TextStyle(
                color: AppSettings.fontV1,
                decoration: TextDecoration.none,
                fontSize: AppSettings.fontsizeMainTitle,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.185),
            SizedBox(
              width: screenWidth * 0.7,
              child: Text(
                "This is just a demo Application. If you tap Sign up I get the right of all of your data :P",
                style: TextStyle(
                  color: AppSettings.fontV1,
                  decoration: TextDecoration.none,
                  fontSize: AppSettings.fontsizeSubDescription,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.07),
            FlexusButton(
              text: "SIGN UP",
              function: () {
                Navigator.pushNamed(context, "/register_username");
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            FlexusButton(
              text: "LOGIN",
              backgroundColor: AppSettings.backgroundV1,
              fontColor: AppSettings.fontV1,
              function: () {
                Navigator.pushNamed(context, "/login");
              },
            ),
            FlexusBottomSizedBox(screenHeight: screenHeight)
          ],
        ),
      ),
    );
  }

  GestureDetector _buildLanguageDetector(double screenWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          UserSettings.language == "DE" ? UserSettings.language = "ENG" : UserSettings.language = "DE";
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.language,
            size: AppSettings.fontsizeDescription,
            color: AppSettings.font,
          ),
          SizedBox(
            width: screenWidth * 0.02,
          ),
          Text(
            UserSettings.language,
            style: TextStyle(
              fontSize: AppSettings.fontsizeDescription,
              color: AppSettings.font,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.07,
          ),
        ],
      ),
    );
  }
}
