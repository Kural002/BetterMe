import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/task_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildBody(BuildContext context, HabitViewModel vm, user) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (user == null) return const LoginScreen();

    final total = vm.totalTasks;
    final completed = vm.completedTasks;
    final progress = total == 0 ? 0.0 : completed / total;
    final scaffoldContext = context;

    void _showAddTaskDialog(BuildContext context) {
      final titleController = TextEditingController();
      final descController = TextEditingController();
      final vm = Provider.of<HabitViewModel>(context, listen: false);
      final uid = vm.currentUserId;

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("Add New Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Task Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();
                  if (title.isEmpty) return;

                  await vm.addHabit(uid, title, desc);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text("Habit added successfully!")),
                  );
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async => vm.loadHabits(user.uid),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        backgroundColor: vm.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$completed / $total",
                          style: TextStyle(
                            fontSize: 24,
                            color:
                                vm.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Task Progress",
                  style: TextStyle(
                    fontSize: 16,
                    color: vm.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          for (final h in List.of(vm.tasks))
            Dismissible(
              key: Key(h.id),
              background: Container(
                color: Colors.green,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                final uid = vm.currentUserId;
                final task = h;

                vm.tasks.removeWhere((item) => item.id == task.id);
                vm.notifyListeners();

                if (direction == DismissDirection.startToEnd) {
                  task.isCompleted = true;
                  await vm.updateHabit(uid, task);
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text("${task.title} marked as completed"),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          task.isCompleted = false;
                          vm.tasks.add(task);
                          vm.notifyListeners();
                          await vm.updateHabit(uid, task);
                        },
                      ),
                    ),
                  );
                } else if (direction == DismissDirection.endToStart) {
                  await vm.deleteHabit(uid, task.id);
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text("${task.title} deleted"),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          vm.tasks.add(task);
                          vm.notifyListeners();
                          await vm.restoreHabit(uid, task);
                        },
                      ),
                    ),
                  );
                }
              },
              child: TaskCard(tasks: h),
            ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
              onPressed: () => _showAddTaskDialog(context),
            ),
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
        centerTitle: true,
        title: const Text('BetterMe'),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(context, vm, user),
    );
  }
}
