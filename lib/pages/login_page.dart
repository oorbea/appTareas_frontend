import 'package:flutter/material.dart';
import 'package:prioritease/pages/home.dart';
import '../widgets/logo.dart';
import 'forgot_password.dart';
import 'register_page.dart';
import '../services/api.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

        return Scaffold(
          body: Center(
            child: isSmallScreen
                // Small Screens: Return a column
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Logo(),
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
                        Logo(),
                        _LoginForm(),
                      ],
                    ),
                  ),
          ),
        );
      },
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TextFields(),
          Column(
            children: [
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
  // Create a global key that uniquely identifies the Form widget and allows validation of the form.
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool rememberMe = false;
  // Manage the visibility of the password
  bool isObscured = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Function to validate email
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return "Email is required";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(email)) return "Invalid email";
    return null;
  }

  /// Function to validate password
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return "Password is required";
    if (password.length < 8) return "Must be at least 8 characters";
    if (password.length > 100) return "Must be less than 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(password)) return "Must include an uppercase letter";
    return null;
  }

  /// Function to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      AuthService authService = AuthService();
      authService.login(
        _emailController.text,
        _passwordController.text,
      ).then((String? errorMessage) {
        if (errorMessage == null) {
          // Login and navigate to the home page
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login successful: Remember me$rememberMe"), backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                    builder: (context) => const HomeScreen())
            );
          }
          
        } else {
          // Show API error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
            );
          }
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                prefixIconColor: Theme.of(context).colorScheme.primary,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                hintText: 'Enter your email',
                labelText: "Email",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: isObscured,
              controller: _passwordController,
              validator: _validatePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.key),
                prefixIconColor: Theme.of(context).colorScheme.primary,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                hintText: 'Enter your password',
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isObscured = !isObscured;
                    });
                  },
                ),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            ForgotPassword(),
            Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    const Text("Remember me"),
                    Switch(
                      // This bool value toggles the switch.
                      value: rememberMe,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        setState(() {
                          rememberMe = value;
                        });
                      },
                    ),
                  ],
                ),
            FilledButton(
              onPressed: () => {
                _submitForm()
              }, 
              child: const Text('Log In')
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
