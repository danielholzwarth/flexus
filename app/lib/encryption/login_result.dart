// login function will return a LoginResult
class LoginResult {
  final String publicKey;
  final String privateKey;
  final String randomSaltOne;
  final String randomSaltTwo;

  LoginResult({
    required this.publicKey,
    required this.privateKey,
    required this.randomSaltOne,
    required this.randomSaltTwo,
  });
}