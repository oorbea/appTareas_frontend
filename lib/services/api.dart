import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

String getServerUrl() {
  if (kIsWeb) {
    // Running on the web
    return "http://localhost:5000"; // Use localhost for web
  } else if (Platform.isAndroid) {
    // Running on Android 
    return "http://10.0.2.2:5000";
  } else {
    // Running on desktop (Windows, macOS, Linux)
    return "http://localhost:5000"; // Use localhost for desktop
  }
}

class AuthService {
  final String baseUrl = getServerUrl();

  Future<String?> register(String username, String email, String password) async{
    // Send the credentials that the user wants to register
    var uri = Uri.parse("$baseUrl/prioritease_api/user/register");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    // Manage API responses
    if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 400) {
      return "Faltan campos obligatorios";
    } else if (response.statusCode == 409) {
      return "El correo electrónico ya está registrado";
    } else {
      return "Error interno del servidor";
    }
  }

  Future<String?> login(String email, String password, bool rememberMe) async{
    // Send the credentials that the user wants to login
    var uri = Uri.parse("$baseUrl/prioritease_api/user/login");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    // Manage API responses
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      EncryptedTokenStorage().saveToken(token, rememberMe);
      return null;
    } else if (response.statusCode == 400) {
      return "Faltan campos obligatorios";
    } else if (response.statusCode == 401) {
      return "Credenciales incorrectas";
    } else {
      return "Error interno del servidor";
    }
  }

  Future<String?> forgotPassword(String email) async{
    // Send email that the user will need to check to get the code
    var uri = Uri.parse("$baseUrl/prioritease_api/user/forgot_password");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
      }),
    );
    // Manage API responses
    if (response.statusCode == 200) {
      return null;
    } else if (response.statusCode == 404) {
      return "Email $email no registrado";
    } else {
      return "Error interno del servidor";
    }
  }

  Future<String?> resetPassword(String email, int code, String newPassword) async{
    var uri = Uri.parse("$baseUrl/prioritease_api/user/reset_password");
    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
        "newPassword": newPassword,
      }),
    );
    // Manage API responses
    if (response.statusCode == 200) {
      return null;
    } else if (response.statusCode == 400) {
      return "Código inválido o expirado";
    } else {
      return "Error interno del servidor";
    }
  }

}