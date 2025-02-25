import 'package:flutter/material.dart';

void main() {
  runApp(TaskApp());
}

/// A simple data model for a task, including name, completion status, and priority.
class Task {
  String name;
  bool isCompleted;
  String priority;

  Task({required this.name, this.isCompleted = false, this.priority = 'Medium'});
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: TaskListScreen(),
    );
  }
}

/// A StatefulWidget that manages the list of tasks.
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // List to store tasks
  List<Task> tasks = [];
  final TextEditingController taskController = TextEditingController();
  String selectedPriority = 'Medium';

  /// Adds a new task with the selected priority.
  void addTask() {
    String taskName = taskController.text;
    if (taskName.isNotEmpty) {
      setState(() {
        tasks.add(Task(name: taskName, priority: selectedPriority));
        // Sort tasks so that high-priority tasks appear at the top
        tasks.sort((a, b) => comparePriority(a.priority, b.priority));
      });
      taskController.clear();
    }
  }

  /// Compare priorities: High comes first, then Medium, then Low.
  int comparePriority(String a, String b) {
    const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
    return priorityOrder[a]!.compareTo(priorityOrder[b]!);
  }

  /// Toggle the completion status of a task.
  void toggleTask(int index, bool? value) {
    setState(() {
      tasks[index].isCompleted = value ?? false;
    });
  }

  /// Delete a task from the list.
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  /// Builds each task item in the list view.
  Widget buildTaskItem(BuildContext context, int index) {
    final task = tasks[index];
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => toggleTask(index, value),
      ),
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text("Priority: ${task.priority}"),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => deleteTask(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row containing text input, priority selector, and Add button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter task name',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                // Dropdown for selecting task priority
                DropdownButton<String>(
                  value: selectedPriority,
                  items: ['Low', 'Medium', 'High'].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPriority = value;
                      });
                    }
                  },
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: addTask,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            // Expanded ListView that displays all tasks
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: buildTaskItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
