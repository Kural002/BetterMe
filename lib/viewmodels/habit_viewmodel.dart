import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class HabitViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  HabitViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) loadHabits(user.uid);
    });
  }

  Future<void> loadHabits(String uid) async {
    _isLoading = true;
    notifyListeners();
    _habits = await _firestore.fetchHabits(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(String uid, String title, String description) async {
    final habit = Habit(id: '', title: title, description: description);
    final saved = await _firestore.addHabit(uid, habit);
    _habits.insert(0, saved);
    notifyListeners();
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    await _firestore.updateHabit(uid, habit);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) _habits[idx] = habit;
    notifyListeners();
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await _firestore.deleteHabit(uid, habitId);
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }

  Future<void> markHabitCompleted(Habit habit) async {
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

  Future<void> toggleProgress(String uid, Habit habit, DateTime date) async {
    final key = _keyForDate(date);
    final current = habit.progress[key] ?? false;
    habit.progress[key] = !current;
    await updateHabit(uid, habit);
  }

  int get totalHabits => _habits.length;
  int get completedHabits => _habits.where((h) => h.isCompleted).length;

  int streakCount(Habit habit) {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key = _keyForDate(day);
      if (habit.progress[key] == true) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
