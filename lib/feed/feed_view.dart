
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {

  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<CustomEvent> feedEventList = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();

    // Listen for changes in AuthProvider
    Provider.of<BZAuthProvider>(context, listen: false)
        .addListener(_onAuthProviderChange);
  }

  void _onAuthProviderChange() {
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      List<CustomEvent> events = await authProvider.getUserEvents();
      setState(() {
        feedEventList = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BZAuthProvider>(
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
                const SizedBox(height: 8),
                if (feedEventList.isNotEmpty) Column(
                  children: feedEventList
                        .map((mapEvent) => mapEvent.toFeedThumbnail(context))
                        .toList(),
                ) else const Column(
                  children: [
                    Text('No events to display'),
                    Text('Try adding some!'),
                  ],
                ),
                // Add your feed content here
              ],
            )],
          ),
        );
      },
    );
  }
}