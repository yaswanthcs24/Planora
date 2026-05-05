import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProgressScreen — shows overall completion, per-subject bars, weekly activity
// Receives the real tasks list from MainScreen (same data as HomeScreen)
// ─────────────────────────────────────────────────────────────────────────────
class ProgressScreen extends StatelessWidget {
  final List<Task> tasks;

  const ProgressScreen({super.key, required this.tasks});

  // ── Group tasks by subject and calculate per-subject stats ───────────────
  Map<String, _SubjectStats> _getSubjectStats() {
    final map = <String, _SubjectStats>{};

    for (final task in tasks) {
      final subject = task.subject.isEmpty ? 'General' : task.subject;
      map.putIfAbsent(subject, () => _SubjectStats(subject: subject));
      map[subject]!.total++;
      map[subject]!.totalHours += task.hours;
      if (task.isDone) {
        map[subject]!.done++;
        map[subject]!.doneHours += task.hours;
      }
    }

    return map;
  }

  // ── Overall completion percentage ─────────────────────────────────────────
  double _overallPercent() {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.isDone).length / tasks.length;
  }

  // ── Total study hours logged (completed tasks only) ───────────────────────
  double _totalHoursDone() {
    return tasks
        .where((t) => t.isDone)
        .fold(0.0, (sum, t) => sum + t.hours);
  }

  @override
  Widget build(BuildContext context) {
    final subjectStats = _getSubjectStats();
    final overallPct   = _overallPercent();
    final hoursDone    = _totalHoursDone();
    final totalTasks   = tasks.length;
    final doneTasks    = tasks.where((t) => t.isDone).length;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ───────────────────────────────────────────────────
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Track your study journey',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),

              // ── Big circular progress indicator ──────────────────────────
              _BigCircle(percent: overallPct),
              const SizedBox(height: 24),

              // ── Stats row ─────────────────────────────────────────────────
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'Tasks done',
                  value: '$doneTasks / $totalTasks',
                  color: AppTheme.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Hours logged',
                  value: '${hoursDone.toStringAsFixed(1)}h',
                  color: AppTheme.accent,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Subjects',
                  value: '${subjectStats.length}',
                  color: AppTheme.warning,
                )),
              ]),
              const SizedBox(height: 28),

              // ── Per-subject progress ──────────────────────────────────────
              const Text(
                'By subject',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              if (subjectStats.isEmpty)
                _EmptyState(
                  icon: Icons.bar_chart_rounded,
                  message: 'No tasks yet!\nAdd tasks in the Planner tab to see your progress here.',
                )
              else
                ...subjectStats.values.map((s) => _SubjectCard(stats: s)),

              const SizedBox(height: 28),

              // ── Weekly activity (last 7 days visual) ──────────────────────
              const Text(
                'Weekly activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _WeeklyChart(tasks: tasks),

              const SizedBox(height: 28),

              // ── Motivational card ─────────────────────────────────────────
              _MotivationCard(percent: overallPct),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Big animated circular progress ring
// ─────────────────────────────────────────────────────────────────────────────
class _BigCircle extends StatelessWidget {
  final double percent; // 0.0 to 1.0

  const _BigCircle({required this.percent});

  @override
  Widget build(BuildContext context) {
    final pctText = '${(percent * 100).toInt()}%';

    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 14,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.borderColor,
                ),
              ),
            ),
            // Foreground ring
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pctText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const Text(
                  'overall',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small stat card
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-subject progress card with animated bar
// ─────────────────────────────────────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final _SubjectStats stats;

  const _SubjectCard({required this.stats});

  Color _barColor(double pct) {
    if (pct >= 0.7) return AppTheme.success;
    if (pct >= 0.4) return AppTheme.primary;
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final pct     = stats.total == 0 ? 0.0 : stats.done / stats.total;
    final pctText = '${(pct * 100).toInt()}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stats.subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              Row(children: [
                Text(
                  '${stats.done}/${stats.total} tasks',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pctText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor(pct)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.doneHours.toStringAsFixed(1)}h done',
                style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted),
              ),
              Text(
                '${stats.totalHours.toStringAsFixed(1)}h total',
                style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly bar chart — shows tasks completed per day (last 7 days)
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final List<Task> tasks;

  const _WeeklyChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Build 7-day counts Mon→Sun
    final days    = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts  = List<int>.filled(7, 0);
    final now     = DateTime.now();

    for (final task in tasks) {
      if (task.isDone && task.dueDate != null) {
        final diff = now.difference(task.dueDate!).inDays;
        if (diff >= 0 && diff < 7) {
          // weekday: 1=Mon … 7=Sun  →  index 0–6
          final idx = task.dueDate!.weekday - 1;
          counts[idx]++;
        }
      }
    }

    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          // Bars
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heightPct = maxCount == 0
                    ? 0.0
                    : counts[i] / maxCount;
                final isToday   = i == now.weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (counts[i] > 0)
                          Text(
                            '${counts[i]}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.textMuted,
                            ),
                          ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: heightPct == 0 ? 4 : 80 * heightPct,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primary
                                  : heightPct > 0
                                      ? AppTheme.primaryLight
                                      : AppTheme.borderColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            children: days.map((d) {
              final isToday = d == days[now.weekday - 1];
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isToday
                        ? AppTheme.primary
                        : AppTheme.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Motivational banner at the bottom
// ─────────────────────────────────────────────────────────────────────────────
class _MotivationCard extends StatelessWidget {
  final double percent;

  const _MotivationCard({required this.percent});

  String _message() {
    if (percent == 0)  return "Every journey starts with a single step. Add your first task!";
    if (percent < 0.3) return "Great start! Keep adding tasks and checking them off.";
    if (percent < 0.6) return "You're making solid progress. Keep the momentum going!";
    if (percent < 0.9) return "Almost there! You're doing amazing — finish strong!";
    return "Outstanding! You've completed nearly everything. You're a star!";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message(),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String   message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data class — stats for one subject
// ─────────────────────────────────────────────────────────────────────────────
class _SubjectStats {
  final String subject;
  int    total      = 0;
  int    done       = 0;
  double totalHours = 0;
  double doneHours  = 0;

  _SubjectStats({required this.subject});
}
