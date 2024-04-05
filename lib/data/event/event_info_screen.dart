import 'package:bazapp/constants.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/data/event/event.dart';
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
        title: Text('Event Details'),
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
            Text(
              TimeFunctions.yMMMMd(event.dateTime),
              style: Constants.defaultTextStyle,
            ),
            SizedBox(height: 8),
            MapViewMini(event.location, height: 200),
            SizedBox(height: 16),
            Text("Created by:"),
            SizedBox(height: 8),
            UserProfileSmall(userId: event.userId!, viewerId: user?.uid),
            SizedBox(height: 8),
            if (event.userId != user?.uid)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => {_subscribeToEvent(context)},
                    child: const Text("Subscribe to Event"),
                  ),
                  SizedBox(width:8),
                  const Text("Subscription count:"),
                  FutureBuilder<int?>(
                    future: _getSubscriptionCount(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final subscriptionCount = snapshot.data ?? 0;
                        return Text(subscriptionCount.toString());
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  _subscribeToEvent(BuildContext context) async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      // Add event to Firebase
      await authProvider.subscribeToEvent(user!.uid, event.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Event created successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create event: $e'),
      ));
    }
  }

  Future<int?> _getSubscriptionCount(BuildContext context) async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      // Add event to Firebase
      return authProvider.getEventSubscriptionCount(event.id!);
    } catch (e) {
      0;
    }
    return null;
  }
}
