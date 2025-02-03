import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  
  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isObscured = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          constraints: const BoxConstraints(
            maxHeight: 70,
            maxWidth: 300,
          ),
          child: TextField(
            obscureText: isObscured,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              prefixIconColor: WidgetStateColor.fromMap(
                <WidgetStatesConstraint, Color>{
                  WidgetState.focused: Theme.of(context).colorScheme.primary,
                  WidgetState.any: Theme.of(context).colorScheme.secondary,
                },
              ),
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
              hintText: 'Enter your $label',
              labelText: label,
              // Solo muestra el icono de visibilidad si es un campo de contraseña
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isObscured = !isObscured;
                        });
                      },
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
