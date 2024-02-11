import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class RegisterNamePage extends StatefulWidget {
  final String username;

  const RegisterNamePage({
    super.key,
    required this.username,
  });

  @override
  State<RegisterNamePage> createState() => _RegisterNamePageState();
}

class _RegisterNamePageState extends State<RegisterNamePage> {
  final TextEditingController nameController = TextEditingController();

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
              "Your name . However, you can still change it later.",
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
            text: "CONTINUE (2/3)",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
            function: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text('Name must not be empty!'),
                    ),
                  ),
                );
              } else if (nameController.text.length > 20) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text('Name must not be longer than 20 characters!'),
                    ),
                  ),
                );
              } else {
                Navigator.pushNamed(context, "/register_password", arguments: [
                  widget.username,
                  nameController.text,
                ]);
              }
            },
          ),
          FlexusBottomSizedBox(screenHeight: screenHeight)
        ],
      ),
    );
  }
}
