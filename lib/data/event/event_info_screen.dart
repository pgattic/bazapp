import 'package:bazapp/constants.dart';
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/map/map_view_mini.dart';
import 'package:bazapp/user_profile/user_profile_small.dart';
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              event.description,
              style: Constants.defaultTextStyle,
            ),
            SizedBox(height: 16),
            Text(
              Constants.yMMMMd(event.dateTime),
              style: Constants.defaultTextStyle,
            ),
            SizedBox(height: 8),
            MapViewMini(event.location),
            SizedBox(height: 16),
            Text("Created by:"),
            SizedBox(height: 8),
            UserProfileSmall(userId: event.userId!),
            SizedBox(height: 8),
            if (event.userId != user?.uid) ElevatedButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatScreen(recipientUid: event.userId!),
                ))
              },
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
