import 'dart:convert';
import 'dart:typed_data';

import 'package:app/api/user_account_service.dart';
import 'package:app/encryption/crypto_service.dart';
import 'package:app/encryption/login_result.dart';
import 'package:app/encryption/signup_result.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                    onPressed: () => Navigator.popAndPushNamed(context, "/register_name"),
                    icon: Icon(Icons.adaptive.arrow_back),
                    iconSize: AppSettings.fontsizeTitle,
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
                      fontSize: AppSettings.fontsizeTitle,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.08),
            FlexusTextField(hintText: "Username", textController: usernameController),
            SizedBox(height: screenHeight * 0.03),
            FlexusTextField(hintText: "Password", textController: passwordController),
            SizedBox(height: screenHeight * 0.28),
            FlexusButton(
              text: "LOGIN",
              backgroundColor: AppSettings.backgroundV1,
              fontColor: AppSettings.fontV1,
              function: () async {
                final response = await userAccountService.getSignUpResult(usernameController.text);
                if (response.isSuccessful) {
                  //Bad performance
                  //Decode encrypted bytes from server and send back for JWT

                  final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

                  SignUpResult signUpResult = SignUpResult(
                    publicKey: base64Decode(jsonMap['publicKey']),
                    encryptedPrivateKey: base64Decode(jsonMap['encryptedPrivateKey']),
                    randomSaltOne: base64Decode(jsonMap['randomSaltOne']),
                    randomSaltTwo: base64Decode(jsonMap['randomSaltTwo']),
                  );
                  //final loginResult = login(signUpResult, passwordController.text);

                  Navigator.pushNamed(context, "/home");
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Username or password incorrect!'),
                      ),
                    ),
                  );
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

LoginResult login(SignUpResult signUpResult, String password) {
  // Generate pbkdfKey using the random salt stored in DB and user's password
  final Uint8List pbkdfKey = CryptoService.generatePBKDFKey(
    password,
    signUpResult.randomSaltOne,
  );

  // decrypt private key using the pbkdfKey generated above
  // and the second random salt stored in DB
  Uint8List decryptedPrivateKey = CryptoService.symetricDecrypt(
    pbkdfKey,
    signUpResult.randomSaltTwo,
    signUpResult.encryptedPrivateKey,
  );

  return LoginResult(
    publicKey: signUpResult.publicKey,
    privateKey: decryptedPrivateKey,
    randomSaltOne: signUpResult.randomSaltOne,
    randomSaltTwo: signUpResult.randomSaltTwo,
  );
}
