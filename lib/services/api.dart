import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
  final String baseUrl = getServerUrl();

class AuthService {
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
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
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
      await EncryptedTokenStorage().saveToken(token, rememberMe);
      return null;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
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
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
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
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

}

class UserAttributes {
  Future<Image> getUserImage() async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/user/picture");
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    // Manage API responses
    if (response.statusCode == 200) {
      return Image.network("$baseUrl/prioritease_api/user/picture",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } else {
      return Image.file(File("assets/default_user_icon.jpg"));
    }
    
  }

  Future<String> getUsername() async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/user");
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    // Manage API responses
    if (response.statusCode == 200) {
      final username = jsonDecode(response.body)['username'];
      return username;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

  Future<String> getEmail() async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/user");
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Manage API responses
    if (response.statusCode == 200) {
      final email = jsonDecode(response.body)['email'];
      return email;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

  Future<String?> updatePicture(File profilePicture) async {
    // Check if the file is of type png, gif, or jpeg
    final mimeType = lookupMimeType(profilePicture.path);
    if (mimeType != 'image/png' && mimeType != 'image/gif' && mimeType != 'image/jpeg') {
      return "El archivo debe ser una imagen de tipo PNG, GIF o JPEG";
    }

    var uri = Uri.parse("$baseUrl/prioritease_api/user/upload_picture");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'profilePicture', 
        profilePicture.path, 
        contentType: MediaType.parse(mimeType ?? 'application/octet-stream')
      )
    );
    
    // Add token
    final token = await EncryptedTokenStorage().getToken();
    request.headers['Authorization'] = "Bearer ${token!}";
    var response = await request.send();
    
    // Manage API responses
    if (response.statusCode == 200) {
      return null;
    } else {
      return "Error interno del servidor";
    }
  }

  Future<String?> updateUser(String? username, String? email, String? password) async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/user");
    Map<String, String> body = {};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    
    // Manage API responses
    if (response.statusCode == 200) {
      return null;
    } else {
      return jsonDecode(response.body)['error'];
    }
  }
}