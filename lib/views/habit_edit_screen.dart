import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../services/auth_service.dart';

class HabitEditScreen extends StatefulWidget {
  const HabitEditScreen({Key? key}) : super(key: key);

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _descCtl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (user == null) return;
                await vm.addHabit(user.uid, _titleCtl.text.trim(), _descCtl.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
