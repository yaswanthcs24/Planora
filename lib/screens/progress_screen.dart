import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  final List<Task> tasks;

  const ProgressScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {

    // 🔥 CALCULATIONS
    int total = tasks.length;
    int completed = tasks.where((t) => t.isDone).length;
    double totalHours =
        tasks.fold(0, (sum, t) => sum + t.hours);

    double completionRate =
        total == 0 ? 0 : completed / total;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Progress",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              // 🔥 REAL DATA CARDS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  _card("Tasks", "$total"),
                  _card("Done", "$completed"),
                  _card("Hours", "${totalHours.toStringAsFixed(1)}h"),

                ],
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: completionRate,
                minHeight: 10,
              ),

              const SizedBox(height: 10),

              Text(
                "Completion: ${(completionRate * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}