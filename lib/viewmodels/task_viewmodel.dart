import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
 

class TasksViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  String get currentUserId => _auth.currentUser?.uid ?? '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _themeVariant = 0; 
  int get themeVariant => _themeVariant;

  List<Tasks> _tasks = [];
  List<Tasks> get tasks => _tasks;


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

  Future<void> resetTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    for (var task in List.from(_tasks)) {
      await _firestore.deleteTask(user.uid, task.id);
    }

    _tasks.clear();
    notifyListeners();
  }

  Future<void> markTaskCompleted(Tasks task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    task.isCompleted = true;
    await _firestore.updateTask(user.uid, task);
    notifyListeners();
  }

  void toggleThemeVariant() {
    _themeVariant = (_themeVariant + 1) % 2;
    notifyListeners();
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((h) => h.isCompleted).length;
}
