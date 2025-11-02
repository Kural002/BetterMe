import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class TasksViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  String get currentUserId => _auth.currentUser?.uid ?? '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<Tasks> _tasks = [];
  List<Tasks> get tasks => _tasks;
  // List<String> session =  ["morning", "afternoon", "evening", "night"];

  // String getSessionForTimeOfDay(String timeOfDay) {
  //   switch (timeOfDay) {
  //     case 'Morning':
  //       return session[0];
  //     case 'Afternoon':
  //       return session[1];
  //     case 'Evening':
  //       return session[2];
  //     case 'Night':
  //       return session[3];
  //     default:
  //       return '';
  //   }
  // }

  TasksViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) loadTasks(user.uid);
    });
  }

  Future<void> loadTasks(String uid) async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _firestore.fetchTasks(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markTaskIncomplete(Tasks task) async {
    task.isCompleted = false;
    await _firestore.updateTask(_auth.currentUser!.uid, task);
    await loadTasks(_auth.currentUser!.uid);
  }

  Future<void> addTask(
      String uid, String title, String description, String timeOfDay) async {
    final task = Tasks(
        id: '', title: title, description: description, timeOfDay: timeOfDay);
    final saved = await _firestore.addTask(uid, task);
    _tasks.insert(0, saved);
    notifyListeners();
  }

  Future<void> restoreTask(String uid, Tasks tasks) async {
    await _firestore.tasksRef(uid).doc(tasks.id).set(tasks.toMap());
    _tasks.insert(0, tasks);
    notifyListeners();
  }

  Future<void> updateTask(String uid, Tasks task) async {
    await _firestore.updateTask(uid, task);
    final idx = _tasks.indexWhere((h) => h.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _firestore.deleteTask(uid, taskId);
    _tasks.removeWhere((h) => h.id == taskId);
    notifyListeners();
  }

  void removeTaskLocally(String id) {
    _tasks.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> markTaskCompleted(Tasks task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    task.isCompleted = true;
    await _firestore.updateTask(user.uid, task);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  String _keyForDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> toggleProgress(String uid, Tasks task, DateTime date) async {
    final key = _keyForDate(date);
    final current = task.progress[key] ?? false;
    task.progress[key] = !current;
    await updateTask(uid, task);
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((h) => h.isCompleted).length;
}
