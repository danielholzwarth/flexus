// ignore_for_file: use_build_context_synchronously

import 'package:app/api/login_user_account/login_user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

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
    final loginUserAccountService = LoginUserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSettings.screenHeight * 0.15),
            _buildTitleRow(context),
            SizedBox(height: AppSettings.screenHeight * 0.08),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: AppSettings.screenHeight * 0.03),
            FlexusTextField(
              hintText: "Password",
              textController: passwordController,
              isObscure: true,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: AppSettings.screenHeight * 0.32),
            _buildLoginButton(loginUserAccountService, context),
            SizedBox(height: AppSettings.screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  FlexusButton _buildLoginButton(LoginUserAccountService loginUserAccountService, BuildContext context) {
    return FlexusButton(
      text: "LOGIN",
      backgroundColor: AppSettings.backgroundV1,
      fontColor: AppSettings.fontV1,
      function: () async {
        Response<dynamic> response = await loginUserAccountService.getLogin({
          "username": usernameController.text,
          "password": passwordController.text,
        });
        if (response.isSuccessful) {
          final jwt = response.headers["flexusjwt"];
          userBox.put("flexusjwt", jwt);

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

  Row _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSettings.screenWidth * 0.15,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, "/"),
            icon: Icon(Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeTitle,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: AppSettings.screenWidth * 0.7,
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
