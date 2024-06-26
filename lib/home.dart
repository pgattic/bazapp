import 'dart:async';

import 'package:bazapp/app_colors.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:bazapp/messages/messages_screen.dart';
import 'package:bazapp/preferences/preferences_view.dart';
import 'package:bazapp/user_profile/user_profile_screen.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:bazapp/feed/feed_view.dart';
import 'package:bazapp/map/map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bazapp/firebase/auth_provider.dart' as fire;
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  final fire.BZUser user; // Receive user information
  final fire.UserPreferences? userPreferences; // Receive user information
  const HomeScreen({Key? key, required this.user, required this.userPreferences}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Initialize with the default index (e.g., home)
  bool _notificationShown = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _listenForNewMessages();
  }

  @override
  Widget build(BuildContext context) {
    bool? isDarkMode = widget.userPreferences?.isDarkMode;
    return MaterialApp(
      theme: AppColors.lightMode,
      darkTheme: AppColors.darkMode,
      themeMode: isDarkMode == null ? ThemeMode.system : isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) {
           // Call _listenForNewMessages inside Builder
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('You have a new message!'),
                    duration: Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(top: 64.0),
                  ));
                },
                child: const Text('Bazapp'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:(context) {
                        return PreferencesDialog();
                      },
                    ).then((_) => setState(() {})); // Refresh the screen so the settings changes take effect
                  },
                ),
              ],
            ),
            body: _buildContent(), // Display different content based on selected icon
            bottomNavigationBar: _buildBottomNavigationBar(),
            
          );
        },
      ),
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
            user: widget.user); // Pass the user to MessagesScreen
      case 4:
        return UserProfileScreen(); // Pass the user to UserProfileScreen
      default:
        return Container(); // Fallback (you can customize this)
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: widget.userPreferences?.isDarkMode ?? false ? AppColors.darkMode.buttonTheme.colorScheme?.primary : AppColors.lightMode.buttonTheme.colorScheme?.primary, // Customize color as needed
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

    // Listen for updates to the messages and show a notification

//    Provider.of<BZAuthProvider>(context, listen: false)
//        .addListener(_onAuthProviderChange);
  

//  void _onAuthProviderChange() {
//    _getUserPrefs();
//  }
//
//  void _getUserPrefs() async {
//    try {
//      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
//      UserPreferences prefs = await authProvider.getUserPrefs();
//      print("YEET YEET YEET YEET YEET YEET ${prefs.isDarkMode}");
//      setState(() {
//        _userPreferences = prefs;
//        _darkMode = prefs.isDarkMode;
//      });
//    } catch (e) {
//      print('Error fetching events: $e');
//    }
//  }

  void _listenForNewMessages() {
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
            String senderId = querySnapshot.docs[0]['senderId'];
            showNotificationSnackBar(senderId); // Pass senderId directly
            _notificationShown = true;
            Timer(Duration(seconds: 30), () {
              setState(() {
                _notificationShown = false;
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


  void showNotificationSnackBar(String senderId) {
    _scaffoldKey.currentState?.showBottomSheet((context) {
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pop(context); // Close the bottom sheet after 5 seconds
      });
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('You have a new message!'),
            ElevatedButton(
              onPressed: () {
                _openChatWith(senderId);
              },
              child: Text('Open Chat'),
            ),
          ],
        ),
      );
    });
  }

  void _openChatWith(String otherUserId) async {
    BZUser otherUser = await Provider.of<BZAuthProvider>(context, listen: false).getUserById(otherUserId);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(recipient: otherUser),
        ),
      );
    }
  }
}
