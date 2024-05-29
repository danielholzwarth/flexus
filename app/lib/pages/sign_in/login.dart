// ignore_for_file: use_build_context_synchronously

import 'package:app/api/login_user_account/login_user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_settings/user_settings.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final loginUserAccountService = LoginUserAccountService.create();

    return FlexusGradientScaffold(
      topColor: AppSettings.background,
      bottomColor: AppSettings.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: deviceSize.height * 0.15),
            _buildTitleRow(context, deviceSize),
            SizedBox(height: deviceSize.height * 0.08),
            FlexusTextField(
              hintText: "Username",
              textController: usernameController,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: deviceSize.height * 0.03),
            FlexusTextField(
              hintText: "Password",
              textController: passwordController,
              isObscure: true,
              onChanged: (String newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: deviceSize.height * 0.32),
            _buildLoginButton(loginUserAccountService, context),
            SizedBox(height: deviceSize.height * 0.12),
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
          JWTHelper.saveJWTsFromResponse(response);

          final Map<String, dynamic> jsonMap = response.body;
          final userAccount = UserAccount(
            id: jsonMap['id'],
            username: jsonMap['username'],
            name: jsonMap['name'],
            createdAt: DateTime.parse(jsonMap['createdAt']).add(AppSettings.timeZoneOffset),
            level: jsonMap['level'],
          );
          userBox.put("userAccount", userAccount);

          await getUserSettings();

          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const PageViewPage(isFirst: false),
            ),
            (route) => false,
          );
        } else {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Wrong username or password.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        }
      },
    );
  }

  Row _buildTitleRow(BuildContext context, Size deviceSize) {
    return Row(
      children: [
        SizedBox(
          width: deviceSize.width * 0.15,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: FlexusDefaultIcon(iconData: Icons.adaptive.arrow_back),
            iconSize: AppSettings.fontSizeH3,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.7,
          child: CustomDefaultTextStyle(
            text: "Login with username and password",
            decoration: TextDecoration.none,
            fontSize: AppSettings.fontSizeH3,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Future<void> getUserSettings() async {
    UserSettingsService userSettingsService = UserSettingsService.create();
    final userBox = Hive.box('userBox');

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    Response<dynamic> response = await userSettingsService.getUserSettings(flexusjwt);

    if (response.isSuccessful) {
      JWTHelper.saveJWTsFromResponse(response);

      if (response.body != null) {
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
