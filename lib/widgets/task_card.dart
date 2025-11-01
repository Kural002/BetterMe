import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';
import '../viewmodels/task_viewmodel.dart';
import '../services/auth_service.dart';

class TaskCard extends StatelessWidget {
  final Tasks tasks;
  const TaskCard({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;


    return Card(
      child: ListTile(
        title: Text(tasks.title),
        subtitle: Text(
          tasks.description.isNotEmpty ? tasks.description : 'No description',
        ),
        trailing: Text(
          tasks.createdAt != null
              ? TimeOfDay.fromDateTime(tasks.createdAt).format(context)
              : '',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
