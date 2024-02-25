import 'dart:collection';
import 'package:bazapp/MessagesScreen.dart';

import 'package:bazapp/app_colors.dart';
import 'package:bazapp/map/map.dart';

import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase/auth_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

          // Check if the user is authenticated
          if (user != null) {
            return HomeScreen(); // Return HomeScreen when the user is authenticated
          } else {
            return LoginPage(); // Return LoginPage when the user is not authenticated
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final user = Provider.of<AuthProvider>(context).user;
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
        return FeedScreen(); // Replace with your MapDisplay widget
      case 1:
        return MapDisplay(); // Replace with your MapDisplay widget
      case 2:
        return MessagesScreen(); // Replace with your MessagesScreen widget
      case 3:
        return CalendarScreen(); // Replace with your CalendarScreen widget
      case 4:
        return UserProfileScreen(); // Replace with your UserProfileScreen widget
      default:
        return Container(); // Fallback (you can customize this)
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type:
          BottomNavigationBarType.fixed, // Fixed type for less than four items
      selectedItemColor: AppColors.primaryColor, // Use your primary color
      unselectedItemColor: AppColors.textColor, // Use your text color
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Update the selected index
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
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

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Feed Screen'), // Example content
    );
  }
}

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendar Screen'), // Example content
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('User Profile Screen'), // Example content
    );
  }
}
