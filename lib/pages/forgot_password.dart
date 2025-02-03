import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hemos enviado un correo de verificación a "
            ),
            TextButton(
              onPressed: () => {
                Navigator.pop(context)
              },
        
              child: Text("Back to Log In"),
            )
          ],
        ),
      ),
    );
  }
}