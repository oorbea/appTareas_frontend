import 'package:flutter/material.dart';
import '../utils/token_storage.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            EncryptedTokenStorage().deleteToken();
            Navigator.pop(context);
          }, 
          child: Text("Go to Login"),
        ),
      ),
    );
  }
}