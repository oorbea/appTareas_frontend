import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptedTokenStorage {
  static final EncryptedTokenStorage _instance = EncryptedTokenStorage._internal();
  factory EncryptedTokenStorage() => _instance;
  EncryptedTokenStorage._internal();

  final encrypt.Key key = encrypt.Key.fromBase64('4ECSz7d023xaK86Aqh8JuGGImBB34U+x04jAXJK0gy0=');

  String? token;

  bool isValidJwt(String token) {
    final parts = token.split('.');
    return parts.length == 3;
  }

  String encryptToken(String token) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(token, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Failed to encrypt token: $e');
    }
  }

  String decryptToken(String encryptedToken) {
    try {
      final parts = encryptedToken.split(':');
      if (parts.length != 2) return '';
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      throw Exception('Failed to decrypt token: $e');
    }
  }

  Future<void> saveToken(String newToken) async {
    if (!isValidJwt(newToken)) {
      throw Exception('Invalid JWT token');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encryptedToken = encryptToken(newToken);
    await prefs.setString('jwt_token', encryptedToken);
    token = newToken;
  }

  Future<String?> getToken() async {
    if (token == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final encryptedToken = prefs.getString('jwt_token');
      if (encryptedToken == null) return null;
      token = decryptToken(encryptedToken);
    }
    return token;
  }

  Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    token = null;
    // Sobrescribir el token en memoria (opcional)
    token = ' ' * (token?.length ?? 0);
  }
}