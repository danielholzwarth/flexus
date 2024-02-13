// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
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
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.15,
                  child: IconButton(
                    onPressed: () => Navigator.popAndPushNamed(context, "/"),
                    icon: Icon(Icons.adaptive.arrow_back),
                    iconSize: AppSettings.fontsizeTitle,
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
                "The username must be at least 6 and maximum 20 characters long. \nEvery username can only exist once. \nYou can still change it later.",
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
            SizedBox(height: screenHeight * 0.275),
            FlexusButton(
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
            ),
            FlexusBottomSizedBox(screenHeight: screenHeight),
          ],
        ),
      ),
    );
  }
}
