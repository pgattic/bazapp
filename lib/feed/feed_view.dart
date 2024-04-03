
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/event_type.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  
  final List<CustomEvent> feedEventList = [ // TODO: Get events from database, not hardcoded
    CustomEvent(
      const LatLng(51.509364, -0.128928),
      DateTime.now(),
      "Party",
      "This is a test event",
      EventType.party,
      DateTime.now(),
      DateTime.now(),
    ),
    CustomEvent(
      const LatLng(52.509364, -0.128928),
      DateTime.now(),
      "Service",
      "This is a test event",
      EventType.service,
    ),
    CustomEvent(
      const LatLng(53.509364, -0.128928),
      DateTime.now(),
      "Sale",
      "This is a test event",
      EventType.sale,
    ),
    CustomEvent(
      const LatLng(54.509364, -0.128928),
      DateTime.now(),
      "Buy my stuff",
      "This is a test event",
      EventType.sale,
    ),
    CustomEvent(
      const LatLng(55.509364, -0.128928),
      DateTime.now(),
      "this is epic",
      "poggers",
      EventType.service,
    )
  ];

  FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Center(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the feed, ${user?.displayName ?? 'Guest'}!',
                  style: const TextStyle(fontSize: 20),
                ),
                Column(
                  children: feedEventList
                        .map((mapEvent) => mapEvent.toFeedThumbnail(context))
                        .toList(),
                )
                // Add your feed content here
              ],
            )],
          ),
        );
      },
    );
  }
}