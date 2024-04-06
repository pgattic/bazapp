
import 'dart:async';

import 'package:bazapp/messages/messages_screen.dart';
import 'package:bazapp/user_profile/user_profile_screen.dart';
import 'package:bazapp/app_colors.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:bazapp/feed/feed_view.dart';
import 'package:bazapp/map/map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/feed/feed_view.dart';
import 'package:bazapp/messages/messages_screen.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:bazapp/user_profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bazapp/firebase/auth_provider.dart' as fire;
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  final fire.User user; // Receive user information
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Initialize with the default index (e.g., home)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazapp'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              setState(() {
                _currentIndex = 4;
              });
            },
          ),
        ],
      ),
      body: _buildContent(), // Display different content based on selected icon
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return const FeedScreen(); // Pass the user to FeedScreen
      case 1:
        return const CalendarScreen(); // Pass the user to CalendarScreen
      case 2:
        return MapView();
      case 3:
        return MessagesScreen(
          user: widget.user
        ); // Pass the user to MessagesScreen
      case 4:
        return UserProfileScreen(); // Pass the user to UserProfileScreen
      default:
        return Container(); // Fallback (you can customize this)
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue, // Customize color as needed
      unselectedItemColor: Colors.grey, // Customize color as needed
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'User',
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen for updates to the messages and show a notification
    _listenForNewMessages();
  }

  void _listenForNewMessages() {
  // Query Firebase every 15 seconds to check for new messages
  Timer.periodic(Duration(seconds: 15), (timer) async {
    // Get the current user's UID
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      try {
        // Query Firestore for new messages
        final querySnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('recipientId', isEqualTo: currentUserUid)
            .orderBy('timestamp', descending: true) // Order by timestamp to get the latest message first
            .limit(1) // Limit to 1 message
            .get();

        // Check if there are any new messages
        if (querySnapshot.docs.isNotEmpty) {
          // Show a toast notification
          Fluttertoast.showToast(
            msg: 'You have a new message!',
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } catch (e) {
        print('Error querying Firestore: $e');
      }
    }
  });
}

}
