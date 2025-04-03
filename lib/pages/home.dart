import 'package:flutter/material.dart';
import 'package:prioritease/widgets/add_task_button.dart';
import '../pages/user_page.dart';
import '../services/api.dart';
import '../utils/task.dart';
import '../widgets/task_tile.dart';
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
                Expanded(
                  child: TasksPage(),
                ),
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
  List<Task> tasks = [];

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getTitles();
  }

  void _getTitles() async {
    List<String> listReceived = await TaskLists().getEnabledTaskLists();
    setState(() { 
      titles = listReceived;
    });
    _getTasks();
  }
  void _getTasks() async {
    List<Map<String, dynamic>> listReceived = [];
    if(_value == -1){
      listReceived= await TaskAPI().getFavoriteTasks();
    }
    else if (titles.isNotEmpty){
      listReceived = await TaskAPI().getTasksByListName(titles[_value]);
    }
    
    setState(() {
      tasks = listReceived.map((taskMap) => Task.fromJson(taskMap)).toList();
    });
    
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
                    _getTasks();
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
                            _getTasks();
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
                        onSubmitted: (value) async{
                          String? error = await TaskLists().createTaskList(taskListName);
                          if(error == null){
                            Navigator.of(context).pop(value);
                            _getTitles();
                          }
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
                    tooltip: "Cambiar nombre de la lista",
                    onPressed: () async {
                      String? taskListName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                        String taskListName = titles[_value];
                        return AlertDialog(
                        title: Text('Cambiar nombre de la lista'),
                        content: TextField(
                          controller: TextEditingController(text: titles[_value]),
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
                  
                      if (taskListName != null && taskListName.isNotEmpty) {
                        await TaskLists().changeTaskList(titles[_value],taskListName);
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
                    onPressed: () async {
                      String? taskListName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                        String taskListName = titles[_value];
                        return AlertDialog(
                        title: Text('¿Borrar la lista ${titles[_value]}?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('OK'),
                            onPressed: () async {
                              await TaskLists().disableTaskList(titles[_value]);
                              _getTitles();
                              titles.isNotEmpty ? _value = 0 : _value = -1;
                              Navigator.of(context).pop(taskListName);
                            },
                          ),
                        ],
                        );
                        },
                      );
                  
                      if (taskListName != null && taskListName.isNotEmpty) {
                        await TaskLists().changeTaskList(titles[_value],taskListName);
                        _getTitles();
                      }
                  
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
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var task = tasks[index];
                return Column(
                  children: [
                    TaskTile(task, onTaskChanged: _getTasks),
                    SizedBox(height: 10),
                  ],
                );
              },
              itemCount: tasks.length,
            ),
          ),
          Divider(),
          SizedBox(
            height: 20.0,
          ),
          _value != -1 && titles.isNotEmpty ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AddTaskButton(defaultList: titles[_value], refreshTasks: _getTasks)
            ],
          ) : SizedBox(height: 20),
        ],
      );
  }
}