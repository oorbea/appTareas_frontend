import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                      _LoginForm(),
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
                      _LoginForm(),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    // Check if we have an small screen
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon.png',
            width: isSmallScreen ? 100 : 200,
            height: isSmallScreen ? 100 : 200),
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

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => __LoginFormState();
}

class __LoginFormState extends State<_LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 350),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TextFields(),
          Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("Remember me"),
                  RememberMeSwitch(),
                ],
              ),
              LoginButton(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  RegisterButton(),
                ],
              ),
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage()),
                  );
                },
                child: Text(
                  "Forgot my password",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RememberMeSwitch extends StatefulWidget {
  const RememberMeSwitch({super.key});

  @override
  State<RememberMeSwitch> createState() => _RememberMeSwitchState();
}

class _RememberMeSwitchState extends State<RememberMeSwitch> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: rememberMe,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          rememberMe = value;
        });
      },
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
    return FilledButton(onPressed: () => {}, child: const Text('Log In'));
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
    return TextButton(
      onPressed: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RegisterPage()))
      },
      child: Text("Sign Up",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          )),
    );
  }
}
