import 'package:flutter/material.dart';
import '../pages/user_page.dart';
import '../services/api.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final iconSize = 60.0;

  Future<Image>? _userImageFuture;
  Future<String>? _usernameFuture;

  @override
  void initState() {
    super.initState();
    _userImageFuture = UserAttributes().getUserImage();
    _usernameFuture = UserAttributes().getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 1500,
            maxWidth: 1000,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.timer),
                      iconSize: iconSize,
                    ),
                    Row(
                      children: [
                        FutureBuilder<String>(
                          future: _usernameFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Indicador de carga
                            } else if (snapshot.hasError) {
                              return Text("Error al cargar el nombre");
                            } else {
                              return Text(
                                snapshot.data ?? "Cargando...",
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 20.0),
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserPage()),
                            );
                          }, 
                          icon: FutureBuilder<Image>(
                            future: _userImageFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Indicador de carga
                              } else if (snapshot.hasError) {
                                return Icon(Icons.error); // Ícono de error
                              } else {
                                return ClipOval(
                                  child: Image(
                                    image: snapshot.data!.image,
                                    width: iconSize,
                                    height: iconSize,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            },
                          ),
                          iconSize: iconSize,
                        ),
                        
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                TasksPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int? _value = 1;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Task Lists', style: textTheme.labelLarge),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 5.0,
            children:
                List<Widget>.generate(3, (int index) {
                  return ChoiceChip(
                    label: Text('Item $index'),
                    selected: _value == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? index : null;
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      );
  }
}