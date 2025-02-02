import 'package:flutter/material.dart';
// Include the Google Fonts package to provide more text format options
// https://pub.dev/packages/google_fonts
import 'pages/login_page.dart';
import 'api/api.dart';


void main() {
  runApp(
      MaterialApp(
        title: 'PrioritEase',
        theme: ThemeData(
          useMaterial3: true,
          
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue.shade300,
          ),
        ),

        home: Scaffold(
            body: SafeArea(
              child: LoginPage(),
            ),
          ),
          
      )
    );
}
