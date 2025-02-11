import 'package:flutter/material.dart';
import '../services/api.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _resetCodeFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  // TODO: Change this condition, unintuitive
  bool codeNotSubmmited = true;
  bool isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                child: 
                  codeNotSubmmited ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Indica el correo donde quieres enviar el código de recuperación de " 
                        "contraseña",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 30.0),
                      TextFormField(
                        focusNode: _emailFocusNode,
                        autofocus: true,
                        controller: _emailController,
                        validator: (email){
                          if (email == null || email.isEmpty) return "Email is required";
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(email)) return "Invalid email";
                          return null;
                        },
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
                    ],
                  )
                : Column(
                  children: [
                    Text(
                      "Introduce el código que hemos enviado a ${_emailController.text}",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      autofocus: true,
                      focusNode: _resetCodeFocusNode,
                      controller: _resetCodeController,
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Code is required";
                        final regex = RegExp(r'^[0-9]+$');
                        if (!regex.hasMatch(value) || value.length != 8) return "Invalid code";
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.numbers_outlined),
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
                        hintText: 'Enter your code',
                        labelText: "Code",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (value){
                        FocusScope.of(context).requestFocus(_resetCodeFocusNode);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      focusNode: _newPasswordFocusNode,
                      obscureText: isObscured,
                      controller: _newPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password is required";
                        if (value.length < 8) return "Must be at least 8 characters";
                        if (value.length > 100) return "Must be less than 8 characters";
                        if (!RegExp(r'[A-Z]').hasMatch(value)) return "Must include an uppercase letter";
                        if (!RegExp(r'[a-z]').hasMatch(value)) return "Must include a lowercase letter";
                        return null;
                      },
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
                        hintText: 'Enter your new password',
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
                  ],
                ),
              )
            ),
            const SizedBox(height: 20.0),
            codeNotSubmmited ? ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  AuthService()
                  .forgotPassword(_emailController.text)
                  .then(
                    (String? errorMessage) {
                      if (errorMessage == null){
                        // The user exists. Move to the password validation page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("We sent a reset code to ${_emailController.text}"),
                            backgroundColor: Colors.green,
                          )
                        );
                        setState(() { codeNotSubmmited = false; });
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    }
                  );                  
                }
              }, 
              child: Text("Submit"),
            )
            : ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  AuthService()
                  .resetPassword(_emailController.text, int.parse(_resetCodeController.text), _newPasswordController.text)
                  .then(
                    (String? errorMessage) {
                      if (errorMessage == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Password updated successfully"),
                            backgroundColor: Colors.green,
                          )
                        );
                        _resetCodeController.text = "";
                        _newPasswordController.text = "";
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    }
                  );                  
                }
              }, 
              child: Text("Submit code"),
            ),
            const SizedBox(height: 20.0),
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