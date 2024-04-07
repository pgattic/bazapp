import 'dart:async';
import 'package:bazapp/messages/messages_screen.dart';
import 'package:bazapp/user_profile/user_profile_screen.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:bazapp/feed/feed_view.dart';
import 'package:bazapp/map/map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bazapp/firebase/auth_provider.dart' as fire;

class HomeScreen extends StatefulWidget {
  final fire.User user; // Receive user information
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Initialize with the default index (e.g., home)
  bool _notificationShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Wrap title with GestureDetector
          onTap: () {
            // Trigger notification on title click
            showNotificationSnackBar(context);
            _listenForNewMessages();
          },
          child: const Text('Bazapp'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
          //_listenForNewMessages();
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
    //print("Trying to get messages");
    Timer.periodic(Duration(seconds: 15), (timer) async {
      
      print("Trying to get messages");
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null) {
        try {
          DateTime now = DateTime.now();
          DateTime fifteenSecondsAgo = now.subtract(Duration(seconds: 17));
          final querySnapshot = await FirebaseFirestore.instance
              .collection('messages')
              .where('recipientId', isEqualTo: currentUserUid)
              .where('timestamp', isGreaterThan: fifteenSecondsAgo)
              .where('timestamp', isLessThan: now)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          if (querySnapshot.docs.isNotEmpty && !_notificationShown) {
            showNotificationSnackBar(context);
            _notificationShown = true; // Set the flag to true
            Timer(Duration(seconds: 30), () {
              setState(() {
                _notificationShown = false; // Reset the flag after one minute
                //initState();
                print('bool changed');

              });
            });
          }
        } catch (e) {
          print('Error querying Firestore: $e');
        }
      }
    });
  }

  void showNotificationSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have a new message!'),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 64.0),
      ),
    );
  }
}