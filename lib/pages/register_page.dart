import 'package:flutter/material.dart';
import '../widgets/logo.dart';
import '../services/api.dart';

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
                        Logo(),
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
                      Logo(),
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
        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TextFields(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              const Text("¿Estás registrado?"),
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
  // Create a global key that uniquely identifies the Form widget and allows validation of the form.
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  FocusNode usernameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  // Manage the visibility of the password
  bool isObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Function to validate username
  String? _validateUsername(String? username) {
    if (username == null || username.isEmpty) return "Se requiere un nombre usuario";
    if (username.length > 30) return "El usuario debe tener máximo 30 caracteres";
    return null;
  }
  /// Function to validate email
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return "Email obligatorio";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(email)) return "Email inválido";
    return null;
  }

  /// Function to validate password
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return "Contraseña obligatoria";
    if (password.length < 8) return "Debe tener al menos 8 caracteres";
    if (password.length > 100) return "Debe tener menos de 100 caracteres";
    if (!RegExp(r'[A-Z]').hasMatch(password)) return "Debe incluir una letra mayúscula";
    if (!RegExp(r'[a-z]').hasMatch(password)) return "Debe incluir una letra minúscula";
    return null;
  }

  /// Function to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      AuthService authService = AuthService();
      authService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      ).then((String? errorMessage) {
        if (errorMessage == null) {
          // Login and navigate to the home page
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registro exitoso"), backgroundColor: Colors.green),
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
          children: [
            TextFormField(
              focusNode: usernameFocus,
              controller: _usernameController,
              validator: _validateUsername,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
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
                hintText: 'Ingresa tu nombre de usuario',
                labelText: "Nombre de usuario",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (value){
                FocusScope.of(context).requestFocus(emailFocus);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: emailFocus,
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
                hintText: 'Ingresa tu correo electrónico',
                labelText: "Correo electrónico",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (value){
                FocusScope.of(context).requestFocus(passwordFocus);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              focusNode: passwordFocus,
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
                hintText: 'Ingresa tu contraseña',
                labelText: "Contraseña",
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
            SizedBox(height: 20.0,),
            ElevatedButton(
              onPressed: () => {
                _submitForm()
              },
              child: Text("Registrarse",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                )
        
              ),
            ),
          ],
        ),
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
      child: Text("Iniciar sesión",
        style: TextStyle(
          fontWeight: FontWeight.w900,
        )

      ),

    );
  }
}