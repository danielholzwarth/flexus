import 'dart:typed_data';

import 'package:app/api/user_account_service.dart';
import 'package:app/encryption/crypto_service.dart';
import 'package:app/encryption/signup_result.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
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
                  onPressed: () => Navigator.popAndPushNamed(context, "/register_username"),
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
          const Spacer(flex: 1),
          FlexusButton(
            text: "CREATE ACCOUNT (3/3)",
            backgroundColor: AppSettings.backgroundV1,
            fontColor: AppSettings.fontV1,
            function: () async {
              final signUpResult = signUp(passwordController.text);
              userAccountService.postUserAccount({
                "username": widget.username,
                "publicKey": signUpResult.publicKey,
                "encryptedPrivateKey": signUpResult.encryptedPrivateKey,
                "randomSaltOne": signUpResult.randomSaltOne,
                "randomSaltTwo": signUpResult.randomSaltTwo,
                "name": widget.name,
              });
              Navigator.pushNamed(context, "/login");
            },
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
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
