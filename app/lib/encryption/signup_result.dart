// signup function will return a SignUpResult
import 'dart:typed_data';

class SignUpResult {
  final Uint8List publicKey;
  final Uint8List encryptedPrivateKey;
  final Uint8List randomSaltOne;
  final Uint8List randomSaltTwo;

  SignUpResult({
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });
}
