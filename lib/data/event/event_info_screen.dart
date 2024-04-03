import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/user_profile_small.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventInfoScreen extends StatelessWidget {
  final CustomEvent event;

  EventInfoScreen({Key? key, required this.event}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${event.getFormattedDateWithYear()}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Time: ${event.getFormattedStartTime()}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            UserProfileSmall(userId: event.userId!),
            if (event.userId != user?.uid) ElevatedButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatScreen(recipientUid: event.userId!),
                ))
              },
              child: const Text('Chat'),
            ) else Text("(you)"),
          ],
        ),
      ),
    );
  }
}
