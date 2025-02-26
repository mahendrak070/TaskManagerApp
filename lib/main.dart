import 'package:flutter/material.dart';

void main() {
  runApp(TaskApp());
}

/// Updated Task model including an optional deadline.
class Task {
  String name;
  bool isCompleted;
  String priority;
  DateTime? deadline;
  Task({
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.deadline,
  });
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
        // Updated textTheme keys to new Material 3 naming conventions.
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
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
  DateTime? selectedDeadline;

  /// Adds a new task with the selected priority and deadline.
  void addTask() {
    String taskName = taskController.text;
    if (taskName.isNotEmpty) {
      setState(() {
        tasks.add(Task(
          name: taskName,
          priority: selectedPriority,
          deadline: selectedDeadline,
        ));
        // Sort tasks so that high-priority tasks appear at the top.
        tasks.sort((a, b) => comparePriority(a.priority, b.priority));
      });
      taskController.clear();
      selectedDeadline = null;
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

  /// Opens a date and time picker to set a deadline.
  Future<void> _pickDeadline() async {
    DateTime now = DateTime.now();
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (time != null) {
        final DateTime deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          selectedDeadline = deadline;
        });
      }
    }
  }

  /// Formats the deadline date and time.
  String _formatDeadline(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "${dt.month}/${dt.day}/${dt.year} $hour:$minute $period";
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => toggleTask(index, value),
          activeColor: Colors.blueGrey,
        ),
        title: Text(
          task.name,
          style: TextStyle(
            color: task.isCompleted ? Colors.black45 : Colors.black87,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Priority: ${task.priority}", style: TextStyle(color: Colors.black54)),
            if (task.deadline != null)
              Text("Deadline: ${_formatDeadline(task.deadline!)}", style: TextStyle(color: Colors.black54)),
          ],
        ),
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
              colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueGrey.shade50],
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
                    color: Colors.black12,
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
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter task name',
                        hintStyle: TextStyle(color: Colors.black45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blueGrey.shade50,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  DropdownButton<String>(
                    value: selectedPriority,
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                    items: ['Low', 'Medium', 'High'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                      backgroundColor: Colors.blueGrey,
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
            SizedBox(height: 12.0),
            // Deadline selection row.
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDeadline != null
                        ? "Deadline: ${_formatDeadline(selectedDeadline!)}"
                        : "No deadline selected",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDeadline,
                  icon: Icon(Icons.calendar_today, color: Colors.blueGrey),
                  label: Text("Pick Deadline", style: TextStyle(color: Colors.blueGrey)),
                ),
              ],
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

/// Custom scroll behavior for a smoother scroll effect using the new buildOverscrollIndicator.
class BouncingScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
