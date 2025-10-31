import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> habitsRef(String uid) =>
      _db.collection('users').doc(uid).collection('habits');

  Future<List<Habit>> fetchHabits(String uid) async {
    final snap = await habitsRef(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Habit.fromDoc(d)).toList();
  }

  Future<Habit> addHabit(String uid, Habit habit) async {
    final doc = await habitsRef(uid).add(habit.toMap());
    final saved = await doc.get();
    return Habit.fromDoc(saved);
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    await habitsRef(uid).doc(habit.id).update(habit.toMap());
  }

  Future<void> markCompleted(String uid, String habitId) async {
    await habitsRef(uid).doc(habitId).update({'isCompleted': true});
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await habitsRef(uid).doc(habitId).delete();
  }
}
