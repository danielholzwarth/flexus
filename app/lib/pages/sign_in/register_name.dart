import 'package:app/pages/sign_in/register_password.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:app/widgets/style/flexus_get_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: deviceSize.height * 0.15),
            _buildTitleRow(context, deviceSize),
            SizedBox(height: deviceSize.height * 0.02),
            _buildDescription(deviceSize),
            SizedBox(height: deviceSize.height * 0.02),
            _buildBulletPoints(),
            SizedBox(height: deviceSize.height * 0.07),
            FlexusTextField(
              hintText: "Name",
              textController: nameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: deviceSize.height * 0.345),
            _buildContinueButton(context),
            SizedBox(height: deviceSize.height * 0.12),
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
      function: () async {
        if (nameController.text.isEmpty) {
          await FlexusGet.showGetSnackbar(message: "Name must not be empty!");
        } else if (nameController.text.length > 20) {
          await FlexusGet.showGetSnackbar(message: "Name must not be longer than 20 characters!");
        } else {
          if (!Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
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

  SizedBox _buildDescription(Size deviceSize) {
    return SizedBox(
      width: deviceSize.width * 0.7,
      child: CustomDefaultTextStyle(
        text: "The name will be shown to your friendship.",
        decoration: TextDecoration.none,
        fontSize: AppSettings.fontSize,
        textAlign: TextAlign.left,
      ),
    );
  }

  Row _buildTitleRow(BuildContext context, Size deviceSize) {
    return Row(
      children: [
        SizedBox(
          width: deviceSize.width * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/register_password"),
            icon: FlexusDefaultIcon(iconData: Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeH3,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.7,
          child: CustomDefaultTextStyle(
            text: "Please enter your name.",
            decoration: TextDecoration.none,
            fontSize: AppSettings.fontSizeH3,
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
