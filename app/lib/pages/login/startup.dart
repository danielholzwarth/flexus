import 'package:app/resources/app_colors.dart';
import 'package:app/resources/user_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:flutter/material.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});
  final isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return FlexusGradientContainer(
      topColor: AppColors.startUp,
      bottomColor: AppColors.primary,
      child: isLoggedIn
          ? Column(
              children: [
                const SizedBox(height: 110),
                Icon(
                  Icons.star,
                  size: 100,
                  color: AppColors.background,
                ),
                const SizedBox(height: 20),
                Text(
                  "FLEXUS",
                  style: TextStyle(
                    color: AppColors.fontV1,
                    decoration: TextDecoration.none,
                    fontSize: UserAppSettings.fontsize + 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 250),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    "If you tap on 'Sign Up,' you agree to our Terms of Service.",
                    style: TextStyle(
                      color: AppColors.fontV1,
                      decoration: TextDecoration.none,
                      fontSize: UserAppSettings.fontsize - 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                const FlexusButton(text: "SIGN UP", route: "/register_username"),
                const SizedBox(height: 30),
                FlexusButton(
                  text: "LOGIN",
                  route: "/login",
                  backgroundColor: AppColors.backgroundV2,
                  fontColor: AppColors.fontV1,
                ),
              ],
            )
          : Center(
              child: Icon(
                Icons.star,
                size: 200,
                color: AppColors.background,
              ),
            ),
    );
  }
}
