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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => toggleTask(index, value),
          activeColor: Colors.indigo,
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text("Priority: ${task.priority}"),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => deleteTask(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input area with text field, priority selector, and Add button.
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        hintText: 'Enter task name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  DropdownButton<String>(
                    value: selectedPriority,
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.indigo),
                    items: ['Low', 'Medium', 'High'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority, style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: Text('Add', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            // Expanded ListView with smooth scrolling behavior.
            Expanded(
              child: ScrollConfiguration(
                behavior: BouncingScrollBehavior(),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: buildTaskItem,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom scroll behavior for a smoother scroll effect.
class BouncingScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
