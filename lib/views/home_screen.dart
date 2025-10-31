import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/habit_card.dart';
import 'habit_edit_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildBody(BuildContext context, HabitViewModel vm, user) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (user == null) return const LoginScreen();

    final total = vm.totalHabits;
    final completed = vm.completedHabits;
    final progress = total == 0 ? 0.0 : completed / total;

    return RefreshIndicator(
      onRefresh: () async => vm.loadHabits(user.uid),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Text(
                      '$completed / $total',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Habit Progress",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final h in vm.habits)
            Dismissible(
              key: Key(h.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.green,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              onDismissed: (direction) async {
                final vm = Provider.of<HabitViewModel>(context, listen: false);
                vm.habits.removeWhere((habit) => habit.id == h.id);
                vm.notifyListeners();

                await vm.markHabitCompleted(h);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${h.title} marked as completed")),
                );
              },
              child: HabitCard(habit: h),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HabitEditScreen())),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitify'),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(context, vm, user),
    );
  }
}
