// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/api/user_settings_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final userBox = Hive.box('userBox');

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final userAccountService = UserAccountService.create();
    final userSettingsService = UserSettingsService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.15),
            _buildTitleRow(screenWidth, context),
            SizedBox(height: screenHeight * 0.08),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            FlexusTextField(
              hintText: "Password",
              textController: passwordController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            FlexusButton(
              text: "get User Settings & Refresh token test",
              function: () async {
                final response = await userSettingsService.getUserSettings(userBox.get("jwtToken"));
                if (response.isSuccessful) {
                  //Refresh Token in Hive
                  final newToken = response.headers["newToken"];
                  if (newToken != null) {
                    userBox.put("jwtToken", newToken);
                  }

                  //final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

/*
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
                  );
*/
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text('Error: ${response.error}'),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: screenHeight * 0.28),
            _buildLoginButton(userAccountService, context),
            FlexusBottomSizedBox(screenHeight: screenHeight),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildLoginButton(UserAccountService userAccountService, BuildContext context) {
    return FlexusButton(
      text: "LOGIN",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        final response = await userAccountService.getLogin({
          "username": usernameController.text,
          "password": passwordController.text,
        });
        if (response.isSuccessful) {
          final jwt = jsonDecode(response.bodyString);
          userBox.put("jwtToken", jwt);

          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('Wrong username or password.'),
              ),
            ),
          );
        }
      },
    );
  }

  Row _buildTitleRow(double screenWidth, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeTitle,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.7,
          child: Text(
            "Login with username and password",
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
}
