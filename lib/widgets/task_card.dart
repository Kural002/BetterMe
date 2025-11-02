import 'package:flutter/material.dart';
import '../models/tasks.dart';

class TaskCard extends StatelessWidget {
  final Tasks tasks;
  const TaskCard({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color timeColor;

    switch (tasks.timeOfDay.toLowerCase()) {
      case 'morning':
        timeColor = Colors.amber;
        break;
      case 'afternoon':
        timeColor = Colors.orangeAccent;
        break;
      case 'evening':
        timeColor = Colors.deepPurpleAccent;
        break;
      case 'night':
        timeColor = Colors.indigoAccent;
        break;
      default:
        timeColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          tasks.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tasks.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  tasks.description,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
        trailing: Text(
          tasks.timeOfDay,
          style: TextStyle(
            color: timeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
