import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:flutter/material.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});
  //remove later
  final isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return FlexusGradientContainer(
      topColor: AppSettings.startUp,
      bottomColor: AppSettings.primary,
      child: isLoggedIn
          ? Column(
              children: [
                const SizedBox(height: 110),
                Icon(
                  Icons.star,
                  size: 100,
                  color: AppSettings.background,
                ),
                const SizedBox(height: 20),
                Text(
                  "FLEXUS",
                  style: TextStyle(
                    color: AppSettings.fontV1,
                    decoration: TextDecoration.none,
                    fontSize: AppSettings.fontsizeMainTitle,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 250),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    "If you tap on 'Sign Up,' you agree to our Terms of Service.",
                    style: TextStyle(
                      color: AppSettings.fontV1,
                      decoration: TextDecoration.none,
                      fontSize: AppSettings.fontsizeSubDescription,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                const FlexusButton(text: "SIGN UP"),
                const SizedBox(height: 30),
                FlexusButton(
                  text: "LOGIN",
                  backgroundColor: AppSettings.backgroundV1,
                  fontColor: AppSettings.fontV1,
                ),
              ],
            )
          : Center(
              child: Icon(
                Icons.star,
                size: 200,
                color: AppSettings.background,
              ),
            ),
    );
  }
}
