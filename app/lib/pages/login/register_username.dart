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

    return FlexusGradientScaffold(
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
              "The username must be at least 6 characters and maximum 20 long. Every username can only exist once. You can still change it later.",
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
            text: "CONTINUE (1/3)",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
            function: () {
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
              }
              //Make check with db
              else if (usernameController.text == "assigned") {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text('Username is already assigned!'),
                    ),
                  ),
                );
              } else {
                Navigator.pushNamed(context, "/register_name", arguments: usernameController.text);
              }
            },
          ),
          FlexusBottomSizedBox(screenHeight: screenHeight)
        ],
      ),
    );
  }
}
