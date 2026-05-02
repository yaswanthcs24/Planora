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
  int _currentIndex = 0;

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  /// 🔥 LOAD TASKS FROM FIRESTORE
  Future<void> loadTasks() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('tasks')
      .get();

  setState(() {
    tasks = snapshot.docs
        .map((doc) => Task.fromJson(doc.data(), doc.id)) // 🔥 FIX
        .toList();
  });
}

  /// 🔥 ADD TASK TO FIRESTORE
  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add(task.toJson());

    setState(() {
      tasks.add(task);
    });
  }

  /// 🔥 TOGGLE TASK
  void toggleTask(int index, bool value) {
    setState(() {
      tasks[index].isDone = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
    HomeScreen(tasks: tasks),
    PlannerScreen(
      tasks: tasks,
      onAddTask: addTask,
      onToggleTask: toggleTask,
    ),
    AiScreen(),
    ProgressScreen(tasks: tasks),
    const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Planner"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}