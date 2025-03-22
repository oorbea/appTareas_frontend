import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/task.dart';
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
      // Build the image from the bytes
      return Image.memory(response.bodyBytes);
    } else {
      // Use AssetImage which works on all platforms
      return Image.asset("assets/default_user_icon.jpg");
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

class TaskLists{
  Future<List<String>> getEnabledTaskLists() async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/task_list");

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        final List<dynamic> taskLists = json.decode(response.body);
        final List<String> titles = taskLists.map((taskList) {
          return taskList['name'] as String;
        }).toList();
        return titles;
      } else {
        return jsonDecode(response.body)['error'];
      }
    } catch (e) {
      print("Excepción al obtener las listas de tareas: $e");
    }

    // If something fails, return an empty list
    return [];
  }

  Future<String?> createTaskList(String listName) async{
    final token = await EncryptedTokenStorage().getToken();
    // Send the credentials that the user wants to login
    var uri = Uri.parse("$baseUrl/prioritease_api/task_list");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json",
        "Authorization" : "Bearer $token" },
      body: jsonEncode({
        "name" : listName
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

  Future<int> nameToIdTaskList(String listName) async{
    final token = await EncryptedTokenStorage().getToken();
    // Send the credentials that the user wants to login
    var uri = Uri.parse("$baseUrl/prioritease_api/task_list/name/$listName");
    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json",
        "Authorization" : "Bearer $token" },
    );
    // Manage API responses
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['id'] ;
    } else {
      return -1;
    }
  }

  Future<String?> disableTaskList(String listName) async{
    final token = await EncryptedTokenStorage().getToken();
    // Send the credentials that the user wants to login
    var uri = Uri.parse("$baseUrl/prioritease_api/task_list/disable/name/$listName");
    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json",
        "Authorization" : "Bearer $token" },
      body: jsonEncode({
        "name" : listName
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

  Future<String?> changeTaskList(String listName, String newListName) async{
    final token = await EncryptedTokenStorage().getToken();
    int? id = await nameToIdTaskList(listName);
    // Send the credentials that the user wants to login
    var uri = Uri.parse("$baseUrl/prioritease_api/task_list/name/$id");
    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json",
        "Authorization" : "Bearer $token" },
      body: jsonEncode({
        "name" : newListName
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

class TaskAPI{
  Future<List<Map<String, dynamic>>> getTasksByListName(String listName) async {
    final token = await EncryptedTokenStorage().getToken();

    // Step 1: Get the task list ID using the list name
    final listId = await TaskLists().nameToIdTaskList(listName);
    if (listId == null) {
      print("No se pudo obtener el ID de la lista de tareas.");
      return [];
    }

    // Step 2: Build the URI with the `list` query parameter
    var uri = Uri.parse("$baseUrl/prioritease_api/task").replace(
      queryParameters: {
        "list": listId.toString(), // Filter tasks by the list ID
      },
    );

      // Step 3: Make the HTTP request
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      // Step 4: Handle the response
      if (response.statusCode == 200) {
        // Decode the JSON response
        final List<dynamic> tasks = json.decode(response.body);
        // Convert the dynamic list to a List<Map<String, dynamic>>
        return tasks.cast<Map<String, dynamic>>();
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        return errorMessage;
      }
  }

  Future<List<Map<String, dynamic>>> getFavoriteTasks() async {
    final token = await EncryptedTokenStorage().getToken();

    var uri = Uri.parse("$baseUrl/prioritease_api/task").replace(
      queryParameters: {
          "favourite": "true", // Filter tasks by the list ID
    });
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      // Decode the JSON response
      final List<dynamic> tasks = json.decode(response.body);
      // Convert the dynamic list to a List<Map<String, dynamic>>
      return tasks.cast<Map<String, dynamic>>();
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

  Future<String?> createTask(Task task) async {
    final token = await EncryptedTokenStorage().getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/prioritease_api/task"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "title": task.title,
        if(task.details != null) "details": task.details,
        if(task.deadline != null) "deadline": task.deadline,
        if(task.parent != null) "parent": task.parent,
        "difficulty": task.difficulty,
        if(task.latitude != null)"lat": task.latitude,
        if (task.longitude != null) "lng": task.longitude,
        "list": task.list,
        "favourite": task.favorite,
        "done": task.done,
      }),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

  Future<String?> disableTask(Task task) async {
    final token = await EncryptedTokenStorage().getToken();
    final response = await http.patch(
      Uri.parse("$baseUrl/prioritease_api/task/disable/${task.id}"),
      headers: {"Content-Type": "application/json",
        "Authorization" : "Bearer $token" },
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      return errorMessage;
    }
  }

  Future<String?> updateTask(Task newTask) async {
    final token = await EncryptedTokenStorage().getToken();
    var uri = Uri.parse("$baseUrl/prioritease_api/task/${newTask.id}");

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": newTask.title,
        if(newTask.details != null) "details": newTask.details,
        if(newTask.deadline != null) "deadline": newTask.deadline,
        if(newTask.parent != null) "parent": newTask.parent,
        "difficulty": newTask.difficulty,
        if(newTask.latitude != null)"lat": newTask.latitude,
        if (newTask.longitude != null) "lng": newTask.longitude,
        "list": newTask.list,
        "favourite": newTask.favorite,
        "done": newTask.done,
      }),
    );
    
    // Manage API responses
    if (response.statusCode == 200) {
      return null;
    } else {
      return jsonDecode(response.body)['error'];
    }
  }
}