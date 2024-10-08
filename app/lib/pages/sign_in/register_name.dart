import 'package:app/pages/sign_in/register_password.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

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
    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSettings.screenHeight * 0.15),
            _buildTitleRow(context),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            _buildDescription(),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            _buildBulletPoints(),
            SizedBox(height: AppSettings.screenHeight * 0.07),
            FlexusTextField(
              hintText: "Name",
              textController: nameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: AppSettings.screenHeight * 0.345),
            _buildContinueButton(context),
            SizedBox(height: AppSettings.screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildContinueButton(BuildContext context) {
    return FlexusButton(
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
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: RegisterPasswordPage(
                username: widget.username,
                name: nameController.text,
              ),
            ),
          );
        }
      },
    );
  }

  SizedBox _buildDescription() {
    return SizedBox(
      width: AppSettings.screenWidth * 0.7,
      child: Text(
        "The name will be shown to your friendship.",
        style: TextStyle(
          color: AppSettings.font,
          decoration: TextDecoration.none,
          fontSize: AppSettings.fontSize,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Row _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSettings.screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/register_password"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeTitle,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: AppSettings.screenWidth * 0.7,
          child: Text(
            "Please enter your name.",
            style: TextStyle(
              color: AppSettings.font,
              decoration: TextDecoration.none,
              fontSize: AppSettings.fontSizeTitle,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Column _buildBulletPoints() {
    return Column(
      children: [
        FlexusBulletPoint(
          text: "At least 1 characters",
          condition: nameController.text.isNotEmpty,
        ),
        FlexusBulletPoint(
          text: "Maximum 20 characters",
          condition: nameController.text.length <= 20,
        ),
      ],
    );
  }
}
