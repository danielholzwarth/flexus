import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class RegisterNamePage extends StatefulWidget {
  const RegisterNamePage({super.key});

  @override
  State<RegisterNamePage> createState() => _RegisterNamePageState();
}

class _RegisterNamePageState extends State<RegisterNamePage> {
  final TextEditingController nameController = TextEditingController();

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
                  onPressed: () => Navigator.popAndPushNamed(context, "/register_password"),
                  icon: Icon(Icons.adaptive.arrow_back),
                  iconSize: AppSettings.fontsizeTitle,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(
                width: screenWidth * 0.7,
                child: Text(
                  "Please enter your name.",
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
              "This name will be displayed to your friends. However, you can still change it later.",
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
            hintText: "Name",
            textController: nameController,
          ),
          const Spacer(flex: 1),
          FlexusButton(
            text: "CREATE ACCOUNT",
            route: "/home",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }
}
