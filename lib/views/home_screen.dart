import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitify/models/tasks.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/task_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildBody(BuildContext context, TasksViewModel vm, user) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (user == null) return const LoginScreen();

    final total = vm.totalTasks;
    final completed = vm.completedTasks;
    final progress = total == 0 ? 0.0 : completed / total;
    final scaffoldContext = context;
    Theme.of(context);
    final List<Color> gradientColors = vm.themeVariant == 0
        ? const [Color(0xFF2F2F2F), Color(0xFF4B5563), Color(0xFF9CA3AF)]
        : const [Color(0xFF1FA2FF), Color(0xFF12D8FA), Color(0xFFA6FFCB)];

    void _showAddTaskDialog(BuildContext context) {
      final titleController = TextEditingController();
      final descController = TextEditingController();
      String? selectedTimeOfDay;
      final vm = Provider.of<TasksViewModel>(context, listen: false);
      final uid = vm.currentUserId;

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              "Add New Task",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            content: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
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
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedTimeOfDay,
                        decoration: const InputDecoration(
                          labelText: 'Time of day',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'morning', child: Text('Morning')),
                          DropdownMenuItem(
                              value: 'afternoon', child: Text('Afternoon')),
                          DropdownMenuItem(
                              value: 'evening', child: Text('Evening')),
                          DropdownMenuItem(
                              value: 'night', child: Text('Night')),
                        ],
                        onChanged: (val) =>
                            setState(() => selectedTimeOfDay = val),
                      ),
                    ],
                  );
                },
              ),
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
                  final when = selectedTimeOfDay?.trim() ?? '';

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  await vm.addTask(uid, title, desc, when);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task added successfully!")),
                  );
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () async => vm.loadTasks(user.uid),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                  height:
                      kToolbarHeight + MediaQuery.of(context).padding.top + 10),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.greenAccent),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$completed / $total",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
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
                        color: Colors.white70,
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
                  confirmDismiss: (direction) async {
                    final uid = vm.currentUserId;
                    final task = h;
                    if (direction == DismissDirection.startToEnd) {
                      task.isCompleted = true;
                      await vm.updateTask(uid, task);
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text("${task.title} marked as completed"),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              task.isCompleted = false;
                              await vm.updateTask(uid, task);
                            },
                          ),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) async {
                    final uid = vm.currentUserId;
                    final task = h;
                    if (direction == DismissDirection.endToStart) {
                      await vm.deleteTask(uid, task.id);
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text("${task.title} deleted"),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              await vm.restoreTask(uid, task);
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Add Habit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => _showAddTaskDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TasksViewModel>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    if (user == null) return const LoginScreen();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        title: const Text(
          'BetterMe',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white70),
            onPressed: () async {
              final List<Tasks> oldTasks = vm.tasks
                  .map((t) => Tasks(
                        id: t.id,
                        title: t.title,
                        description: t.description,
                        isCompleted: t.isCompleted,
                      ))
                  .toList(growable: false);

              await vm.resetTasks();

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: const Text("All tasks reset to incomplete"),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () async {
                      for (final t in oldTasks) {
                        await vm.restoreTask(vm.currentUserId, t);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(context, vm, user),
    );
  }
}
