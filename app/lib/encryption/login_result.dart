// login function will return a LoginResult
import 'dart:typed_data';

class LoginResult {
  final Uint8List publicKey;
  final Uint8List privateKey;
  final Uint8List randomSaltOne;
  final Uint8List randomSaltTwo;

  LoginResult({
    required this.publicKey,
    required this.privateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });
}