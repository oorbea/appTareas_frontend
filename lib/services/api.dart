import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

class AuthService {
  final String baseUrl = "http://localhost:5000";

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

  Future<String?> login(String email, String password) async{
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
      EncryptedTokenStorage().saveToken(token);
      return null;
    } else if (response.statusCode == 400) {
      return "Faltan campos obligatorios";
    } else if (response.statusCode == 401) {
      return "Credenciales incorrectas";
    } else {
      return "Error interno del servidor";
    }
  }
}