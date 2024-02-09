import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app/encryption/crypto_result.dart';
import 'package:crypton/crypton.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/api.dart';

class CryptoService {
  // method to generate RSA key-pairs
  static RSAKeypair getKeyPair() {
    RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
    return rsaKeypair;
  }

  // method to encrypt a piece of text using the public key, returns a CryptoResult
  static CryptoResult assymetricEncrypt(String plainText, RSAPublicKey pubKey) {
    try {
      // Encrypt the piece of text
      String encrypted = pubKey.encrypt(plainText);
      // Return a CryptoResult
      return CryptoResult(data: encrypted, status: true);
    } catch (err) {
      // Error handelling
      return CryptoResult(data: err.toString(), status: false);
    }
  }

  // method to decrypt a piece of text using the private key, returns a CryptoResult
  static CryptoResult assymetricDecript(String encodedTxt, RSAPrivateKey pvKey) {
    try {
      // Decrypt the piece of text
      String decoded = pvKey.decrypt(encodedTxt);
      // Return a CryptoResult
      return CryptoResult(data: decoded, status: true);
    } catch (err) {
      // Error handelling
      return CryptoResult(data: err.toString(), status: false);
    }
  }

  static Uint8List generateRandomSalt({int length = 16}) {
    final random = Random.secure();
    final saltCodeUnits = List<int>.generate(length, (_) => random.nextInt(256));
    return Uint8List.fromList(saltCodeUnits);
  }

  // method to generate encryption key using user's password.
  static Uint8List generatePBKDFKey(String password, String salt, {int iterations = 10000, int derivedKeyLength = 32}) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    final params = Pbkdf2Parameters(Uint8List.fromList(saltBytes), iterations, derivedKeyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

    pbkdf2.init(params);

    return pbkdf2.process(Uint8List.fromList(passwordBytes));
  }

  // Encrypt a piece of text using symmetric algorithm, returns CryptoResult
  static Uint8List symetricEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(true, params);
    return cipher.process(plaintext);
  }

  // Decrypt a piece of text using symmetric algorithm, returns CryptoResult
  static Uint8List symetricDecrypt(Uint8List key, Uint8List iv, Uint8List ciphertext) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(false, params);
    return cipher.process(ciphertext);
  }
}
