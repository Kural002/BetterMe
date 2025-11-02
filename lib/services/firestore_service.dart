import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tasks.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> tasksRef(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  Future<List<Tasks>> fetchTasks(String uid) async {
    final snap = await tasksRef(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Tasks.fromDoc(d)).toList();
  }

  Future<Tasks> addTask(String uid, Tasks task) async {
    final doc = await tasksRef(uid).add(task.toMap());
    final saved = await doc.get();
    return Tasks.fromDoc(saved);
  }

  Future<void> updateTask(String uid, Tasks task) async {
    await tasksRef(uid).doc(task.id).update(task.toMap());
  }

  Future<void> markCompleted(String uid, String taskId) async {
    await tasksRef(uid).doc(taskId).update({'isCompleted': true});
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await tasksRef(uid).doc(taskId).delete();
  }
}
