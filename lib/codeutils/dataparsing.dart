import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/pointycastle.dart';

String? parseData(String encrypted, String pwd) {
  try {
    List<String> parts = encrypted.split('--');
    if (parts.length != 3) return null;
    Uint8List encryptedData = base64Decode(parts[0]);
    Uint8List iv = base64Decode(parts[1]);
    Uint8List salt = base64.decode(parts[2]);
    Uint8List passwordBytes = Uint8List.fromList(utf8.encode(pwd));
    var pbkdf2 = PBKDF2KeyDerivator(HMac(SHA1Digest(), 64));
    var params = Pbkdf2Parameters(salt, 1024, 128);
    pbkdf2.init(params);
    Uint8List derivedKey = pbkdf2.process(passwordBytes);

    var cipher = PaddedBlockCipherImpl(
        PKCS7Padding(), CBCBlockCipher(AESFastEngine()));

    cipher.init(
        false,
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            ParametersWithIV<KeyParameter>(KeyParameter(derivedKey.sublist(0, 16)), iv),
            null));
    Uint8List result = cipher.process(Uint8List.fromList(encryptedData));

    return utf8.decode(result);
  } catch (e) {
    return "value$e";
  }
}
