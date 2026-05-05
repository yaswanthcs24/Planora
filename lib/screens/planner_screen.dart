import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';


class PlannerScreen extends StatefulWidget {
  final List<Task>         tasks;
  final Function(Task)     onAddTask;
  final Function(int, bool) onToggleTask;
  final Function(int)      onDeleteTask; 

  const PlannerScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {


  String _filter = 'All';
  List<MapEntry<int, Task>> get _filteredTasks {
    final indexed = widget.tasks.asMap().entries.toList();
    if (_filter == 'Pending') return indexed.where((e) => !e.value.isDone).toList();
    if (_filter == 'Done')    return indexed.where((e) =>  e.value.isDone).toList();
    return indexed;
  }


  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':   return AppTheme.accent;
      case 'medium': return AppTheme.warning;
      case 'low':    return AppTheme.success;
      default:       return AppTheme.textMuted;
    }
  }

 
  Color _subjectColor(String subject) {
    final colors = [
      AppTheme.subjectMath,
      AppTheme.subjectPhysics,
      AppTheme.subjectChem,
      AppTheme.subjectBio,
      AppTheme.subjectEng,
    ];
    return colors[subject.hashCode.abs() % colors.length];
  }


  void _showAddTaskSheet() {
    final nameCtrl    = TextEditingController();
    final subjectCtrl = TextEditingController();
    String   priority  = 'Medium';
    double   hours     = 1;
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Add new task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Task name e.g. Study Arrays',
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 12),

         
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(
                  hintText: 'Subject e.g. Data Structures',
                  prefixIcon: Icon(Icons.menu_book_rounded,
                      color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Priority',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: ['High', 'Medium', 'Low'].map((p) {
                  final selected = priority == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? _priorityColor(p).withOpacity(0.15)
                              : AppTheme.bgPage,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? _priorityColor(p)
                                : AppTheme.borderColor,
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? _priorityColor(p)
                                : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Hours slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Study hours',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textMuted)),
                  Text(
                    '${hours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: hours,
                min: 0.5,
                max: 8,
                divisions: 15,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.borderColor,
                onChanged: (v) => setModal(() => hours = v),
              ),

              // Due date picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(
                        const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                        const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primary,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setModal(() => dueDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTheme.bgPage,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 10),
                      Text(
                        dueDate == null
                            ? 'Pick a due date (optional)'
                            : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: dueDate == null
                              ? AppTheme.textMuted
                              : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    widget.onAddTask(Task(
                      title:   nameCtrl.text.trim(),
                      subject: subjectCtrl.text.trim().isEmpty
                          ? 'General'
                          : subjectCtrl.text.trim(),
                      priority: priority,
                      hours:    hours,
                      isDone:   false,
                      dueDate:  dueDate,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

         
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planner',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          )),
                      Text('Manage your tasks',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          )),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.tasks.length} tasks',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter tabs ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Pending', 'Done'].map((f) {
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primary
                            : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppTheme.primary
                              : AppTheme.borderColor,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Task list ─────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'Done'
                                ? 'No completed tasks yet'
                                : 'No tasks yet — tap + to add one!',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final idx  = filtered[i].key;
                        final task = filtered[i].value;

                        // 🔥 Swipe left to delete
                        return Dismissible(
                          key: Key(task.id ?? task.title + i.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => widget.onDeleteTask(idx),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: AppTheme.accent,
                            ),
                          ),
                          child: _TaskCard(
                            task:            task,
                            onToggle:        (v) =>
                                widget.onToggleTask(idx, v),
                            priorityColor:   _priorityColor(task.priority),
                            subjectColor:    _subjectColor(task.subject),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── FAB: add task ──────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single task card widget
// ─────────────────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task     task;
  final Function(bool) onToggle;
  final Color    priorityColor;
  final Color    subjectColor;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.priorityColor,
    required this.subjectColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [

          // Checkbox
          GestureDetector(
            onTap: () => onToggle(!task.isDone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppTheme.success : Colors.transparent,
                border: Border.all(
                  color: task.isDone
                      ? AppTheme.success
                      : AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.isDone
                        ? AppTheme.textMuted
                        : AppTheme.textDark,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  // Subject badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.subject,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: subjectColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Hours
                  Text(
                    '${task.hours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  // Due date
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_today_rounded,
                        size: 10, color: AppTheme.textMuted),
                    const SizedBox(width: 2),
                    Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // Priority dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priorityColor,
            ),
          ),
        ],
      ),
    );
  }
}
