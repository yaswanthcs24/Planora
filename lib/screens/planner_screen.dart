import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';

class PlannerScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onAddTask;
  final Function(int, bool) onToggleTask;

  const PlannerScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTask,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {

  void _showAddTaskDialog() {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    String priority = 'Medium';
    double hours = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: "Task name"),
              ),

              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(hintText: "Subject"),
              ),

              Slider(
                value: hours,
                min: 1,
                max: 6,
                divisions: 5,
                onChanged: (v) => setModal(() => hours = v),
              ),

              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;

                  final task = Task(
                    title: nameCtrl.text,
                    subject: subjectCtrl.text.isEmpty
                        ? "General"
                        : subjectCtrl.text,
                    priority: priority,
                    hours: hours,
                    isDone: false,
                  );

                  widget.onAddTask(task); // 🔥 FIREBASE SAVE

                  Navigator.pop(context);
                },
                child: const Text("Add Task"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text("Planner")),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),

      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final task = tasks[i];

                return ListTile(
                  title: Text(task.title),
                  subtitle: Text("${task.subject} • ${task.hours}h"),
                  trailing: Checkbox(
                    value: task.isDone,
                    onChanged: (v) =>
                        widget.onToggleTask(i, v ?? false),
                  ),
                );
              },
            ),
    );
  }
}