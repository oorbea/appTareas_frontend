import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatelessWidget{
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
      
          return Center(
              child: isSmallScreen
                // Small Screens: Return a column
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _Logo(),
                        _RegisterForm(),
                      ],
                  ),
                )
                // Big Screens: Return a Row with the logo and the register form
                : Container(
                  constraints: BoxConstraints(maxWidth: 1000, maxHeight: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Logo(),
                      _RegisterForm(),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }
}


class _Logo extends StatelessWidget{
  const _Logo();

  @override
  Widget build(BuildContext context) {
    // Check if we have an small screen
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icon.png', 
          width: isSmallScreen? 100 : 200,
          height: isSmallScreen? 100: 200
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            "Welcome to PrioritEase!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black87),
          ),
        )
        
      ],
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => __RegisterFormState();
}

class __RegisterFormState extends State<_RegisterForm> {

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TextFields(),
          RegisterButton(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              const Text("Already registered?"),
              LoginButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextFields extends StatefulWidget {
  const _TextFields();

  @override
  State<_TextFields> createState() => __TextFieldsState();
}

class __TextFieldsState extends State<_TextFields> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: "Username",
          icon: Icons.person,
          controller: emailController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Email",
          icon: Icons.email_rounded,
          controller: emailController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Password",
          icon: Icons.key,
          controller: passwordController,
          isPassword: true,
        ),
      ],
    );
  }
}


class RegisterButton extends StatefulWidget {
  const RegisterButton({super.key});

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {},
      child: Text("Sign Up",
        style: TextStyle(
          fontWeight: FontWeight.w900,
        )

      ),

    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {
        Navigator.pop(context),
      },
      child: Text("Log In",
        style: TextStyle(
          fontWeight: FontWeight.w900,
        )

      ),

    );
  }
}