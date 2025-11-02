import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks {
  String id;
  String title;
  String description;
  DateTime createdAt;
  String timeOfDay;
  bool isCompleted;

  
  Map<String, bool> progress;

  Tasks({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.timeOfDay = '',
    this.isCompleted = false,
    Map<String, bool>? progress,
  })  : createdAt = createdAt ?? DateTime.now(),
        progress = progress ?? {};

  factory Tasks.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    

    final rawProgress = (data['progress'] ?? {}) as Map<String, dynamic>;

    return Tasks(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      timeOfDay: data['timeOfDay'] ?? '',
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
