import 'package:flutter/material.dart';
import 'forgotPassword.dart';


class LoginPage extends StatelessWidget{
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
                      _FormContent(),
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
                    _FormContent(),
                  ],
                ),
              ),
        );
      },
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

class _FormContent extends StatefulWidget {
  const _FormContent();

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TextFields(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text("Remember me"),
              SwitchExample(),
            ],
          ),
          LoginButton(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              const Text("Don't have and account?"),
              RegisterButton(),
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
  // Create a TextController and use it to retrieve the input from the TextField
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isObscured = true;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 70,
            maxWidth: 300,
          ),
          child: Flexible(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded),
                prefixIconColor: WidgetStateColor.fromMap(
                  <WidgetStatesConstraint, Color>{
                    WidgetState.focused: Theme.of(context).colorScheme.primary,
                    WidgetState.any: Theme.of(context).colorScheme.secondary,
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder( 
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                hintText: 'Enter your email',
                labelText: 'Email',
              ),
              controller: emailController,
            )
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight:10.0, maxHeight: 40.0),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: 70,
            maxWidth: 300,
          ),
          child: Flexible(
            child: TextField(
              // Controls if the password is hidden
              obscureText: _isObscured,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.key),
                prefixIconColor: WidgetStateColor.fromMap(
                  <WidgetStatesConstraint, Color>{
                    WidgetState.focused: Theme.of(context).colorScheme.primary,
                    WidgetState.any: Theme.of(context).colorScheme.secondary,
                  },
                ),
                // Manage if the password is visible or isn't
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder( 
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                hintText: 'Enter your password',
                labelText: 'Password',
              ),
              controller: passwordController,
            )
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Align(
                alignment: Alignment.centerRight, // Lo coloca a la derecha
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
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
            )
        ),
      ],
    );
  }
}
class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Theme.of(context).colorScheme.secondary,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
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
    return FilledButton(onPressed:  () => {}, child: const Text('Log In'));
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
      onPressed: () => {},
      child: Text("Sign Up",
        style: TextStyle(
          fontWeight: FontWeight.w900,
        )

      ),

    );
  }
}