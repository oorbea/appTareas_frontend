import 'package:flutter/material.dart';
import '../pages/user_page.dart';
import '../services/api.dart';
import '../utils/task.dart';
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
  int _value = 0;
  List<String> titles = [];
  Future<List<Task>>? tasks;

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getTitles();
  }

  @override
  void didUpdateWidget(covariant TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Rebuild widget");
  }

  void _getTitles() async {
    List<String> listReceived = await TaskLists().getEnabledTaskLists();
    setState(() {
      titles = listReceived;
    });
  }

  Future<List<Task>> _getFavoriteTasks() async {
    List<Map<String, dynamic>> listReceived = await TaskAPI().getFavoriteTasks();
    return listReceived.map((taskMap) => Task.fromJson(taskMap)).toList();
  }

  Future<List<Task>> _getTasks(String listName) async {
    List<Map<String, dynamic>> listReceived = await TaskAPI().getTasksByListName(listName);
    return listReceived.map((taskMap) => Task.fromJson(taskMap)).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Task Lists', style: textTheme.headlineLarge),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10.0,
              children: [
                ChoiceChip(
                  selected: _value == -1,
                  label: Icon(
                    Icons.star,
                    color: const Color.fromARGB(255, 243, 229, 107),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if(selected) _value = -1;
                    });
                  },
                ),
                Wrap(
                  spacing: 10.0,
                  children:
                      List<Widget>.generate(titles.length, (int index) {
                        return ChoiceChip(
                          label: Text(titles[index]),
                          selected: _value == index,
                          onSelected: (bool selected) {
                            setState(() {
                              _value = selected ? index : -1;
                            });
                          },
                        );
                      }).toList(),
                ),
                ActionChip(
            label: Icon(Icons.add), 
            onPressed: () async {
              String? newTaskListName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                String taskListName = '';
                return AlertDialog(
                title: Text('Introduce el nombre de la lista de tareas'),
                content: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    taskListName = value;
                  },
                  onSubmitted: (value) {
                    Navigator.of(context).pop(value);
                  },
                  decoration: InputDecoration(hintText: "Nombre de la lista"),
                ),
                actions: <Widget>[
                  TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  ),
                  TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(taskListName);
                  },
                  ),
                ],
                );
                },
              );
          
              if (newTaskListName != null && newTaskListName.isNotEmpty) {
                await TaskLists().createTaskList(newTaskListName);
                _getTitles();
              }
          
            },
          ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _value == -1 ? "Favoritos" : titles.isNotEmpty ? titles[_value] : "",
                style: textTheme.headlineSmall,
              ),
              Row(
                
                children: [
                  IconButton(
                    tooltip: "Edit task list name",
                    onPressed: () async {
                      String? TaskListName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                        String taskListName = '';
                        return AlertDialog(
                        title: Text('Cambiar el nombre de la lista de tareas'),
                        content: TextField(
                          autofocus: true,
                          onChanged: (value) {
                            taskListName = value;
                          },
                          onSubmitted: (value) {
                            Navigator.of(context).pop(value);
                          },
                          decoration: InputDecoration(hintText: "Nombre de la lista"),
                        ),
                        actions: <Widget>[
                          TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          ),
                          TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(taskListName);
                          },
                          ),
                        ],
                        );
                        },
                      );
                  
                      if (TaskListName != null && TaskListName.isNotEmpty) {
                        await TaskLists().changeTaskList(titles[_value],TaskListName);
                        _getTitles();
                      }
                  
                    },
                    icon: Icon(Icons.edit)
                  ),
                  MenuAnchor(
                    childFocusNode: _focusNode,
                    menuChildren: <Widget>[
                      MenuItemButton(onPressed: () {}, child: const Text('Fecha')),
                      MenuItemButton(onPressed: () {}, child: const Text('Dificultad')),
                      MenuItemButton(onPressed: () {}, child: const Text('Orden Personalizado')),
                      MenuItemButton(onPressed: () {}, child: const Text('Favoritos')),
                    ],
                    builder: (_, MenuController controller, Widget? child) {
                      return IconButton(
                        tooltip: "Sort task list",
                        focusNode: _focusNode,
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon( Icons.sort )
                      );
                    },
                  ),
                  if (_value != -1) IconButton(
                    tooltip: "Delete task list name",
                    onPressed: () async  {
                      await TaskLists().disableTaskList(titles[_value]);
                      _getTitles();
                      titles.isNotEmpty ? _value = 0 : _value = -1;
                    }, 
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[300],
                    )
                  ),
                ],
              )
            ],
          ),
          FutureBuilder<List<Task>>(
            future: tasks, // a previously-obtained Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Result: ${snapshot.data}'),
                  ),
                ];
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              } else {
                children = const <Widget>[
                  SizedBox(width: 60, height: 60, child: CircularProgressIndicator()),
                  Padding(padding: EdgeInsets.only(top: 16), child: Text('Awaiting result...')),
                ];
              }
              return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: children),
              );
            },
          ),
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async{
              int? list = await TaskLists().nameToIdTaskList(titles[_value]);
              // Create a task in the list
              if(list != null) await TaskAPI().createTask(title: "Tarea de prueba", list: list );
            }
          )
        ],
      );
  }
}