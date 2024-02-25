import 'package:flutter/material.dart';

class EventInfoScreen extends StatelessWidget {
  final DateTime dateTime;
  final String title;
  final String description;

  const EventInfoScreen({super.key, required this.dateTime, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Information - $title'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Date: ${dateTime.toString()}'),
              const SizedBox(height: 8),
              Text('Description: $description'),
              // Add more information as needed
            ],
          ),
        ),
      ),
    );
  }
}
