import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class HabitViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  String get currentUserId => _auth.currentUser?.uid ?? '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<Tasks> _tasks = [];
  List<Tasks> get tasks => _tasks;

  HabitViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) loadHabits(user.uid);
    });
  }

  Future<void> loadHabits(String uid) async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _firestore.fetchHabits(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markHabitIncomplete(Tasks habit) async {
    habit.isCompleted = false;
    await _firestore.updateHabit(_auth.currentUser!.uid, habit);
    await loadHabits(_auth.currentUser!.uid);
  }

  Future<void> addHabit(String uid, String title, String description) async {
    final task = Tasks(id: '', title: title, description: description);
    final saved = await _firestore.addHabit(uid, task);
    _tasks.insert(0, saved);
    notifyListeners();
  }

  Future<void> restoreHabit(String uid, Tasks tasks) async {
    await _firestore.habitsRef(uid).doc(tasks.id).set(tasks.toMap());
    _tasks.insert(0, tasks);
    notifyListeners();
  }

  Future<void> updateHabit(String uid, Tasks habit) async {
    await _firestore.updateHabit(uid, habit);
    final idx = _tasks.indexWhere((h) => h.id == habit.id);
    if (idx != -1) _tasks[idx] = habit;
    notifyListeners();
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await _firestore.deleteHabit(uid, habitId);
    _tasks.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }

  void removeHabitLocally(String id) {
    _tasks.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> markHabitCompleted(Tasks habit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    habit.isCompleted = true;
    await _firestore.updateHabit(user.uid, habit);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  String _keyForDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> toggleProgress(String uid, Tasks habit, DateTime date) async {
    final key = _keyForDate(date);
    final current = habit.progress[key] ?? false;
    habit.progress[key] = !current;
    await updateHabit(uid, habit);
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((h) => h.isCompleted).length;

}
