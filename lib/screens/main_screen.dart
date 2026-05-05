import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import 'home_screen.dart';
import 'planner_screen.dart';
import 'ai_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int        _currentIndex = 0;
  List<Task> tasks         = [];
  bool       _isLoading    = true; 

  @override
  void initState() {
    super.initState();
    loadTasks();
  }
  Future<void> loadTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true); 

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .get();

    setState(() {
      tasks      = snapshot.docs
          .map((doc) => Task.fromJson(doc.data(), doc.id))
          .toList();
      _isLoading = false; // hide loading spinner
    });
  }
  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add(task.toJson());

    setState(() {
      task.id = docRef.id; 
      tasks.add(task);
    });
  }
  Future<void> toggleTask(int index, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => tasks[index].isDone = value);

    final taskId = tasks[index].id;
    if (taskId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({'isDone': value});
    }
  }

  Future<void> deleteTask(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final taskId = tasks[index].id;

    setState(() => tasks.removeAt(index));

    if (taskId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = [
      HomeScreen(tasks: tasks),
      PlannerScreen(
        tasks: tasks,
        onAddTask: addTask,
        onToggleTask: toggleTask,
        onDeleteTask: deleteTask, 
      ),
      const AiScreen(),
      ProgressScreen(tasks: tasks),
      ProfileScreen(tasks: tasks),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),           label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy),      label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart),      label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person),         label: 'Profile'),
        ],
      ),
    );
  }
}
