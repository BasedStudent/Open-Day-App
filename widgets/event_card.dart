import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(event.description),
        trailing: Icon(Icons.location_on, color: Colors.blue),
      ),
    );
  }
}
