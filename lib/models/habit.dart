import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String id;
  String title;
  String description;
  DateTime createdAt;
  bool isCompleted;
  Map<String, bool> progress;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.isCompleted = false,
    Map<String, bool>? progress,
  })  : createdAt = createdAt ?? DateTime.now(),
        progress = progress ?? {};

  factory Habit.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawProgress = (data['progress'] ?? {}) as Map<String, dynamic>;

    return Habit(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      progress: rawProgress.map((k, v) => MapEntry(k, v == true)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }
}
