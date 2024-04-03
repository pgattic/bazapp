
import 'package:bazapp/messages/messages_screen.dart';
import 'package:bazapp/UserProfileScreen.dart';
import 'package:bazapp/app_colors.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:bazapp/feed/feed_view.dart';
import 'package:bazapp/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:bazapp/firebase/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  final User user; // Receive user information
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
              // Handle user profile action
              // You can navigate to a profile screen or show user details here
              // Access user information using widget.user
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
        return FeedScreen(); // Pass the user to FeedScreen
      case 1:
        return MapView();
      //return MapView(user: widget.user); // Pass the user to MapView
      case 2:
        return MessagesScreen(
          user: widget.user
        ); // Pass the user to MessagesScreen
      case 3:
        return CalendarScreen(); // Pass the user to CalendarScreen
      case 4:
        return UserProfileScreen(); // Pass the user to UserProfileScreen
      default:
        return Container(); // Fallback (you can customize this)
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.textColor,
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
          icon: Icon(Icons.map_sharp),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'User',
        ),
      ],
    );
  }
}