import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../services/auth_service.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;

    final streak = vm.streakCount(habit);

    return Card(
      child: ListTile(
        title: Text(habit.title),
        subtitle: Text('Streak: $streak days'),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () {
            if (user == null) return;
            vm.toggleProgress(user.uid, habit, DateTime.now());
          },
        ),
      ),
    );
  }
}
