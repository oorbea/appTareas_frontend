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
                          if (email == null || email.isEmpty) return "El correo es obligatorio";
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(email)) return "Correo inválido";
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
                          hintText: 'Introduce tu correo',
                          labelText: "Correo",
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
                        if (value == null || value.isEmpty) return "El código es obligatorio";
                        final regex = RegExp(r'^[0-9]+$');
                        if (!regex.hasMatch(value) || value.length != 8) return "Código inválido";
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
                        hintText: 'Introduce tu código',
                        labelText: "Código",
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
                        if (value == null || value.isEmpty) return "La contraseña es obligatoria";
                        if (value.length < 8) return "Debe tener al menos 8 caracteres";
                        if (value.length > 100) return "Debe tener menos de 100 caracteres";
                        if (!RegExp(r'[A-Z]').hasMatch(value)) return "Debe incluir una letra mayúscula";
                        if (!RegExp(r'[a-z]').hasMatch(value)) return "Debe incluir una letra minúscula";
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
                        hintText: 'Introduce tu nueva contraseña',
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
                  ],
                ),
              )
            ),
            const SizedBox(height: 20.0),
            codeNotSubmmited ? ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {  
                  final errorMessage = await AuthService()
                    .forgotPassword(_emailController.text);
                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: Text("Hemos enviado un código de recuperación a ${_emailController.text}"),
                      backgroundColor: Colors.green,
                      )
                    );
                    setState(() { codeNotSubmmited = false; });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      )
                    );
                  }
                }
              }, 
              child: Text("Enviar"),
            )
            : ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await AuthService()
                  .resetPassword(_emailController.text, int.parse(_resetCodeController.text), _newPasswordController.text)
                  .then(
                    (String? errorMessage) {
                      if (errorMessage == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Contraseña actualizada con éxito"),
                            backgroundColor: Colors.green,
                          )
                        );
                        _resetCodeController.clear();
                        _newPasswordController.clear();
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
              child: Text("Enviar código"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () => {
                Navigator.pop(context)
              },
        
              child: Text("Volver a Iniciar Sesión"),
            )
          ],
        ),
      ),
    );
  }
}
