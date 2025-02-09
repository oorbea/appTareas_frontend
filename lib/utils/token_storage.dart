import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptedTokenStorage {
  static final EncryptedTokenStorage _instance = EncryptedTokenStorage._internal();
  static const String _tokenKey = 'jwt_token'; // Key for SharedPreferences

  factory EncryptedTokenStorage() => _instance;
  EncryptedTokenStorage._internal();

  // WARNING: Hardcoded encryption key for demonstration purposes only.
  // In production, use a secure key management solution.
  static const String _kEncryptionKeyBase64 = 'ADFGHJKSKDHGBGHDIRHJKDLKDJKDJKDJ';
  final encrypt.Key _key = encrypt.Key.fromBase64(_kEncryptionKeyBase64);

  String? token;

  bool isTokenExpired(String token) {
    try {
      final payloadPart = token.split('.')[1];
      final normalized = base64.normalize(payloadPart); // Add padding if needed
      final payload = json.decode(utf8.decode(base64.decode(normalized)));
      final exp = payload['exp'] as int?;
      return exp == null || DateTime.now().millisecondsSinceEpoch >= exp * 1000;
    } catch (e) {
      return true; // Treat parsing errors as expired tokens
    }
  }

  String encryptToken(String token) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(token, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Failed to encrypt token: $e');
    }
  }

  String decryptToken(String encryptedToken) {
    try {
      final parts = encryptedToken.split(':');
      if (parts.length != 2) throw FormatException('Invalid token format');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      throw Exception('Failed to decrypt token: $e');
    }
  }

  Future<void> saveToken(String newToken, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    token = newToken; // Keep in memory regardless of rememberMe
    
    if (rememberMe) {
      final encryptedToken = encryptToken(newToken);
      await prefs.setString(_tokenKey, encryptedToken);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Future<String?> getToken() async {
    if (token != null) return token;

    final prefs = await SharedPreferences.getInstance();
    final encryptedToken = prefs.getString(_tokenKey);
    
    if (encryptedToken != null) {
      try {
        token = decryptToken(encryptedToken);
        if (isTokenExpired(token!)) {
          await deleteToken();
          return null;
        }
      } catch (e) {
        await deleteToken(); // Auto-clean invalid tokens
      }
    }
    return token;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    token = null;
  }
}