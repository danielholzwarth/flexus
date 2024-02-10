import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:flutter/material.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});
  //remove later
  final isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return FlexusGradientContainer(
      topColor: AppSettings.startUp,
      bottomColor: AppSettings.primary,
      child: isLoggedIn
          ? Column(
              children: [
                SizedBox(height: screenHeight * 0.15),
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
                const Spacer(flex: 1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
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
                  function: () => Navigator.pushNamed(context, "/register_username"),
                ),
                SizedBox(height: screenHeight * 0.03),
                FlexusButton(
                  text: "LOGIN",
                  backgroundColor: AppSettings.backgroundV1,
                  fontColor: AppSettings.fontV1,
                  function: () => Navigator.pushNamed(context, "/login"),
                ),
                FlexusBottomSizedBox(screenHeight: screenHeight)
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
