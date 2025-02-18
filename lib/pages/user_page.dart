import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prioritease/services/api.dart';
import 'package:prioritease/utils/token_storage.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Image userImage = Image.file(File("assets/default_user_icon.jpg"));
  String username = "Cargando...";
  String email = "Cargando...";

  TextEditingController textEditingController = TextEditingController();
  bool _showOverlay = false;
  bool _obscureText = false;
  String _overlayTitle = ""; 
  String _descriptionField = ""; 

  @override
  void initState() {
    super.initState();
    _loadUserImage();
    _loadUserName();
    _loadUserEmail();
  }

  void _loadUserImage() async {
    userImage = await UserAttributes().getUserImage();
    setState(() {});
  }

  void _loadUserName() async {
    await UserAttributes().getUsername().then((String receivedUsername) async {
      username = receivedUsername;
    });
    setState(() {});
  }

  void _loadUserEmail() async {
    await UserAttributes().getEmail().then((String? receivedEmail) async {
      email = receivedEmail!;
    });
    setState(() {});
  }

  void _showEditOverlay(String title, String descriptionField, String textContent, bool obscureText) {
    setState(() {
      _overlayTitle = title;
      _descriptionField = descriptionField;
      _showOverlay = true;
      textEditingController.text = textContent;
      _obscureText = obscureText;
    });
  }

  void _hideEditOverlay() {
    setState(() {
      _showOverlay = false;
      textEditingController.clear();
    });
  }

  
  void _handleEditConfirmation() async {
    final newValue = textEditingController.text.trim();
    if (newValue.isNotEmpty) {
      if (_overlayTitle == "Editar nombre de usuario") {
        // Update username
        await UserAttributes().updateUser(newValue, null, null);
        setState(() {
          username = newValue;
        });
      } else if (_overlayTitle == "Editar correo electrónico") {
        // Update email
        await UserAttributes().updateUser(null, newValue, null);
        setState(() {
          email = newValue;
        });
      }
      else if (_overlayTitle == "Editar contraseña") {
        // Update email
        await UserAttributes().updateUser(null, null, newValue);
      }
      _hideEditOverlay();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El campo no puede estar vacío."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxHeight: 1500, maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => {Navigator.pop(context)},
                          icon: Icon(Icons.arrow_back),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 100.0,
                          backgroundImage: userImage.image,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit),
                            color: Colors.black,
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);

                              if (pickedFile != null) {
                                final errorMessage = await UserAttributes()
                                    .updatePicture(File(pickedFile.path));

                                // Mostrar snackbar con el mensaje de error o éxito
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage ??
                                        '¡Foto de perfil actualizada con éxito!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                if (errorMessage == null) {
                                  setState(() {
                                    userImage = Image.file(File(pickedFile.path));
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(width: 20.0),
                            IconButton(
                              onPressed: () => _showEditOverlay(
                                  "Editar nombre de usuario", "Usuario", username, false),
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                SizedBox(width: 30.0),
                                IconButton(
                                  onPressed: () => _showEditOverlay(
                                      "Editar correo electrónico", "Email", email, false),
                                  icon: Icon(Icons.edit),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => _showEditOverlay(
                                  "Editar contraseña", "Contraseña", "", true),
                              child: Text(
                                "Cambiar contraseña",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await EncryptedTokenStorage().deleteToken();
                              await Navigator.pushReplacementNamed(
                                  context, '/login');
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.red),
                              minimumSize: WidgetStateProperty.all<Size>(
                                  Size.fromHeight(70.0)),
                            ),
                            child: Text(
                              "Cerrar sesión",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlay para editar nombre o email
          if (_showOverlay)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _overlayTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              labelText: _descriptionField,
                              border: OutlineInputBorder(),
                              suffixIcon: 
                              _descriptionField == "Contraseña" ? IconButton(
                                icon: Icon(Icons.show_chart),
                                onPressed: () => {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  })
                                }
                              ): 
                              null
                            ),
                            obscureText: _descriptionField == "Contraseña" ? _obscureText : false,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handleEditConfirmation,
                            child: Text("Confirmar"),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: _hideEditOverlay,
                            child: Text(
                              "Cancelar",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}