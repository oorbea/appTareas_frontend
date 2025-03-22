import 'package:flutter/material.dart';
import '../utils/task.dart';
import '../services/api.dart';
class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskChanged;
  const TaskTile(this.task, {super.key, required this.onTaskChanged});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final difficultyList = ["Muy Fácil", "Fácil", "Medio", "Difícil", "Muy difícil"];
  final difficultyColor = [Colors.lightGreen, Colors.green, Colors.amber, 
                        Colors.orange, Colors.red];
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.task.done,
        onChanged: (bool? value) {
          setState(() {
            widget.task.done = value ?? false;
          });
        },
      ),
      title: Text(widget.task.title),
      subtitle: Text(widget.task.details ?? "No details" ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            difficultyList[widget.task.difficulty -1 ],
            style: TextStyle(
              color: difficultyColor[widget.task.difficulty -1 ],
            )
          ),
          SizedBox(width: 20),
          IconButton(
            onPressed: () async {
              setState(() {
                widget.task.favorite = !widget.task.favorite;
              });
              await TaskAPI().updateTask(widget.task);
            }, 
            disabledColor: Colors.grey,
            icon: Icon(
              widget.task.favorite 
                ? Icons.star
                : Icons.star_border, 
              color: Colors.yellow
            )
          ),
          IconButton(
            onPressed: () async {
              String? error = await TaskAPI().disableTask(widget.task);
              if(error != null){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              
              widget.onTaskChanged(); // Notify Father
            }, 
            icon: Icon(Icons.delete, color: Colors.red)
          ),
        ],
      )
    );
  }
}