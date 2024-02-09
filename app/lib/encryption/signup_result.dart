// signup function will return a SignUpResult
class SignUpResult {
  final String publicKey;
  final String encryptedPrivateKey;
  final String randomSaltOne;
  final String randomSaltTwo;

  SignUpResult({
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });
}
