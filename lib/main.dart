import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home.dart';
import 'utils/token_storage.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final tokenStorage = EncryptedTokenStorage();
  final token = await tokenStorage.getToken();
  runApp(
      MaterialApp(
        title: 'PrioritEase',
        theme: ThemeData(
          useMaterial3: true,
          
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue.shade300,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomeScreen(),
        },
        home: Scaffold(
            body: SafeArea(
              child: LoginPage(),
            ),
          ),
          
      )
    );
}
