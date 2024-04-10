// ignore_for_file: use_build_context_synchronously

import 'package:app/api/login_user_account/login_user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_settings/user_settings.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bullet_point.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class RegisterPasswordPage extends StatefulWidget {
  final String username;
  final String name;

  const RegisterPasswordPage({
    super.key,
    required this.username,
    required this.name,
  });

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final userBox = Hive.box('userBox');

  @override
  Widget build(BuildContext context) {
    final loginUserAccountService = LoginUserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSettings.screenHeight * 0.15),
            _buildTitleRow(context),
            SizedBox(height: AppSettings.screenHeight * 0.02),
            _buildBulletPoints(),
            SizedBox(height: AppSettings.screenHeight * 0.07),
            FlexusTextField(
              hintText: "Password",
              textController: passwordController,
              onChanged: (String newValue) {
                setState(() {});
              },
              isObscure: true,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.03),
            FlexusTextField(
              hintText: "Confirm Password",
              textController: confirmPasswordController,
              onChanged: (String newValue) {
                setState(() {});
              },
              isObscure: true,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.235),
            _buildCreateAccountButton(context, loginUserAccountService),
            SizedBox(height: AppSettings.screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  Row _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSettings.screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/register_name"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeH3,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: AppSettings.screenWidth * 0.7,
          child: CustomDefaultTextStyle(
            text: "Please enter your password.",
            decoration: TextDecoration.none,
            fontSize: AppSettings.fontSizeH3,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  FlexusButton _buildCreateAccountButton(BuildContext context, LoginUserAccountService loginUserAccountService) {
    return FlexusButton(
      text: "CREATE ACCOUNT (3/3)",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        if (passwordController.text.length < 8) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: CustomDefaultTextStyle(text: 'Password must be longer than 8 characters!'),
              ),
            ),
          );
        } else if (passwordController.text.length > 128) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: CustomDefaultTextStyle(text: 'Passwords must be shorter or equal to 128 characters!'),
              ),
            ),
          );
        } else if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: CustomDefaultTextStyle(text: 'Passwords are not equal!'),
              ),
            ),
          );
        } else {
          Response<dynamic> response = await loginUserAccountService.postUserAccount({
            "username": widget.username,
            "password": passwordController.text,
            "name": widget.name,
          });
          if (response.isSuccessful) {
            final jwt = response.headers["flexusjwt"];
            if (jwt != null) {
              userBox.put("flexusjwt", jwt);
            }

            final Map<String, dynamic> jsonMap = response.body;
            final userAccount = UserAccount(
              id: jsonMap['id'],
              username: jsonMap['username'],
              name: jsonMap['name'],
              createdAt: DateTime.parse(jsonMap['createdAt']),
              level: jsonMap['level'],
            );
            userBox.put("userAccount", userAccount);

            await getUserSettings();

            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const PageViewPage(isFirst: false),
              ),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: CustomDefaultTextStyle(text: "Statuscode ${response.statusCode}\nError: ${response.error}"),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Column _buildBulletPoints() {
    return Column(
      children: [
        FlexusBulletPoint(
          text: "At least 8 characters",
          condition: passwordController.text.length >= 8,
        ),
        FlexusBulletPoint(
          text: "Maximum 128 characters",
          condition: passwordController.text.length <= 128,
        ),
        FlexusBulletPoint(
          text: "Passwords must be equal",
          condition: passwordController.text == confirmPasswordController.text,
        ),
      ],
    );
  }

  Future<void> getUserSettings() async {
    UserSettingsService userSettingsService = UserSettingsService.create();
    final userBox = Hive.box('userBox');
    final flexusjwt = userBox.get("flexusjwt");

    if (flexusjwt != null) {
      Response<dynamic> response = await userSettingsService.getUserSettings(userBox.get("flexusjwt"));

      if (response.isSuccessful) {
        if (response.body != "null") {
          final Map<String, dynamic> jsonMap = response.body;

          final userSettings = UserSettings(
            id: jsonMap['id'],
            userAccountID: jsonMap['userAccountID'],
            fontSize: double.parse(jsonMap['fontSize'].toString()),
            isDarkMode: jsonMap['isDarkMode'],
            languageID: jsonMap['languageID'],
            isUnlisted: jsonMap['isUnlisted'],
            isPullFromEveryone: jsonMap['isPullFromEveryone'],
            pullUserListID: jsonMap['pullUserListID'],
            isNotifyEveryone: jsonMap['isNotifyEveryone'],
            notifyUserListID: jsonMap['notifyUserListID'],
            isQuickAccess: jsonMap['isQuickAccess'],
          );

          userBox.put("userSettings", userSettings);
          debugPrint("Settings found!");
        } else {
          debugPrint("No Settings found!");
        }
      } else {
        debugPrint("Internal Server Error");
      }
    }
  }
}
