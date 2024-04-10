import 'package:bazapp/constants.dart';
import 'package:bazapp/event/subscription_dialog.dart';
import 'package:bazapp/event/event.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/map/map_view_mini.dart';
import 'package:bazapp/time_functions.dart';
import 'package:bazapp/user_profile/user_profile_small.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventInfoScreen extends StatelessWidget {
  final CustomEvent event;

  EventInfoScreen({Key? key, required this.event}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Event Details'),
            Spacer(),
            if (user?.uid == event.userId) IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool deleted = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteConfirmation();
                  },
                )?? false;
                if (deleted) {
                  Provider.of<BZAuthProvider>(context, listen: false).removeEvent(event.id!);
                  Navigator.pop(context, false);
                }
              }
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                event.type.infoScreenIcon,
                SizedBox(width: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              event.description,
              style: Constants.defaultTextStyle,
            ),
            SizedBox(height: 16),
            MapViewMini(event.location, height: 200),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.event),
                SizedBox(width: 4),
                Text(
                  TimeFunctions.yMMMMd(event.dateTime),
                  style: Constants.defaultTextStyle,
                ),
              ],
            ),
            SizedBox(height: 8),
            EventSubscriptionDialog(event, viewerId: user?.uid),
            SizedBox(height: 8),
            Text("Created by:"),
            SizedBox(height: 8),
            UserProfileSmall(userId: event.userId!, viewerId: user?.uid),
          ],
        ),
      ),
    );
  }

}

class DeleteConfirmation extends StatelessWidget {

  const DeleteConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Do you want to delete this event?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // Close the dialog without selecting
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true); // Pass selectedLocation back
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}
