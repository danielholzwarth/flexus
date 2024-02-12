import 'dart:typed_data';

import 'package:app/api/user_account_service.dart';
import 'package:app/encryption/crypto_service.dart';
import 'package:app/encryption/signup_result.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_sized_box.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_scaffold.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:crypton/crypton.dart';
import 'package:flutter/material.dart';

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
                    "Please enter your password.",
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
                "The password must be at least 8 characters. We recommend a password with more than 16 characters, including special characters.",
                style: TextStyle(
                  color: AppSettings.font,
                  decoration: TextDecoration.none,
                  fontSize: AppSettings.fontsizeSubDescription,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: screenHeight * 0.07),
            FlexusTextField(hintText: "Password", textController: passwordController),
            SizedBox(height: screenHeight * 0.03),
            FlexusTextField(hintText: "Confirm Password", textController: confirmPasswordController),
            SizedBox(height: screenHeight * 0.14),
            FlexusButton(
              text: "CREATE ACCOUNT (3/3)",
              backgroundColor: AppSettings.backgroundV1,
              fontColor: AppSettings.fontV1,
              function: () async {
                if (passwordController.text.length < 8) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Password must be longer than 8 characters!'),
                      ),
                    ),
                  );
                } else if (passwordController.text.length > 128) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Passwords must be shorter or equal to 128 characters!'),
                      ),
                    ),
                  );
                } else if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Passwords are not equal!'),
                      ),
                    ),
                  );
                } else {
                  final signUpResult = signUp(passwordController.text);
                  final response = await userAccountService.postUserAccount({
                    "username": widget.username,
                    "publicKey": signUpResult.publicKey,
                    "encryptedPrivateKey": signUpResult.encryptedPrivateKey,
                    "randomSaltOne": signUpResult.randomSaltOne,
                    "randomSaltTwo": signUpResult.randomSaltTwo,
                    "name": widget.name,
                  });
                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.pushNamed(context, "/login");
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text("Statuscode ${response.statusCode}\nError: ${response.error}"),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            FlexusBottomSizedBox(screenHeight: screenHeight),
          ],
        ),
      ),
    );
  }

  SignUpResult signUp(String password) {
    // Generate PBKDF key
    final Uint8List randomSaltOne = CryptoService.generateRandomSalt();
    final Uint8List pbkdfKey = CryptoService.generatePBKDFKey(password, randomSaltOne.toString());

    // Generate RSA Key Pair
    final RSAKeypair keyPair = CryptoService.getKeyPair();

    // Encrypt Private key
    final Uint8List privateKeySalt = CryptoService.generateRandomSalt();
    final encryptedPrivateKey = CryptoService.symetricEncrypt(
      pbkdfKey,
      Uint8List.fromList(privateKeySalt.toString().codeUnits),
      Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
    );
    return SignUpResult(
      publicKey: keyPair.publicKey.toFormattedPEM(),
      encryptedPrivateKey: String.fromCharCodes(encryptedPrivateKey),
      randomSaltOne: randomSaltOne.toString(),
      randomSaltTwo: privateKeySalt.toString(),
    );
  }
}
