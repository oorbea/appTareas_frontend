import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../utils/task.dart';
import '../services/api.dart';
class AddTaskButton extends StatelessWidget {
  final String defaultList;
  final Function refreshTasks;
  
  const AddTaskButton({
    required this.defaultList, 
    required this.refreshTasks, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        _showAddTaskForm(context);
      }
    );
  }

  void _showAddTaskForm(BuildContext context) async {
    // Use bottom sheet for mobile platforms, dialog for others
    if (Platform.isAndroid || Platform.isIOS) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          child: AddTaskPage(defaultList, refreshTasks),
        ),
      );
    } else {
      // For desktop or web, show in dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(16.0),
            child: AddTaskPage(defaultList, refreshTasks),
          ),
        ),
      );
    }
  }
}

class AddTaskPage extends StatefulWidget {
  final String defaultList;
  var refreshTasks;
  
  AddTaskPage(this.defaultList, this.refreshTasks, {super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  double _currentDifficulty = 1;
  double? lat;
  double? long;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Añadir tarea",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la tarea',
                      labelText: 'Nombre *',
                    ),
                    validator: (value) {
                      return (value == null || value.length > 50) 
                      ? "Debe estar entre 1 y 50 caracteres"
                      : null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Detalles de la tarea',
                      labelText: 'Detalles',
                    ),
                    validator: (value) {
                      if (value != null && value.length > 1000) {
                        return "No puede sobrepasar los 1000 caracteres";
                      }
                      return null;
                    },
                    controller: detailsController,
                    maxLines: null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Text("Dificultad",),
                      Expanded(
                        child: Slider(
                          value: _currentDifficulty,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _currentDifficulty.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentDifficulty = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () async{
                      Task task = Task(
                        title: titleController.text,
                        details: detailsController.text,
                        parent: null, // TODO: Manage logic to add subtasks
                        difficulty: _currentDifficulty.round(),
                        latitude: null,
                        longitude: null,
                        list: await TaskLists().nameToIdTaskList(widget.defaultList),
                        favorite: false,
                        done: false,
                      );
                      await TaskAPI().createTask(task);
                      widget.refreshTasks();
                    }, 
                    child: Text("Crear Tarea")
                  )
                ],
              )
            )
          ],
        ),
      )
    );
  }
}