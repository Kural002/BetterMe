import 'package:flutter/material.dart';
import 'package:habitify/viewmodels/task_viewmodel.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';

class TaskCard extends StatelessWidget {
  final Tasks tasks;
  const TaskCard({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<TasksViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = isDark
        ? (tasks.isCompleted ? Colors.green.withOpacity(0.12) : Colors.white.withOpacity(0.08))
        : (tasks.isCompleted ? Colors.green.shade50 : Colors.white);
    final Color titleColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isDark ? 0 : 2,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: tasks.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        title: Text(
          tasks.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tasks.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  tasks.description,
                  style: TextStyle(
                    color: tasks.isCompleted ? (isDark ? Colors.white60 : Colors.black45) : subtitleColor,
                  ),
                ),
              ),
          ],
        ),
        trailing: tasks.timeOfDay.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    tasks.timeOfDay[0].toUpperCase() + tasks.timeOfDay.substring(1),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
