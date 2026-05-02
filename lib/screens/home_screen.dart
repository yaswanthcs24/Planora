import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final List<Task> tasks;

  const HomeScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // 🔥 REAL DATA CALCULATION
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((t) => t.isDone).length;
    double totalHours =
        tasks.fold(0, (sum, task) => sum + task.hours);

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Welcome back 👋',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    SizedBox(height: 2),
                    Text('Stay consistent!',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ]),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryLight,
                    child: const Text('U',
                        style: TextStyle(color: AppTheme.primary,
                            fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats row (REAL DATA)
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'Total Tasks',
                  value: '$totalTasks',
                  change: 'All tasks',
                  valueColor: AppTheme.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Completed',
                  value: '$completedTasks',
                  change: 'Done',
                  valueColor: AppTheme.accent,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Study Hrs',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  change: 'Total',
                  valueColor: AppTheme.warning,
                )),
              ]),

              const SizedBox(height: 20),

              // Remaining UI same
              const Text('Keep going 🚀',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
            ],
          ),
        ),
      ),
    );
  }
}

// SAME STAT CARD (no change)
class _StatCard extends StatelessWidget {
  final String label, value, change;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.borderColor, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      const SizedBox(height: 6),
      Text(value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: valueColor)),
      const SizedBox(height: 4),
      Text(change, style: const TextStyle(fontSize: 9, color: AppTheme.success)),
    ]),
  );
}