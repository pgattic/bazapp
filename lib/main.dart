import 'package:bazapp/MessagesScreen.dart';
import 'package:bazapp/UserProfileScreen.dart';
import 'package:bazapp/app_colors.dart';
import 'package:bazapp/calendar_view.dart';
import 'package:bazapp/firebase_options.dart';
import 'package:bazapp/login_page.dart';
import 'package:bazapp/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calendar_view/calendar_view.dart'; // Import calendar_view package

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          print('User: $user');
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

          // Check if the user is authenticated
          if (user != null) {
            return HomeScreen(user: user); // Pass the user to HomeScreen
          } else {
            return LoginPage(); // Return LoginPage when the user is not authenticated
          }
        },
      ),
    );
  }
}

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
            user: widget.user); // Pass the user to MessagesScreen
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the Feed, ${user?.displayName ?? 'Guest'}!',
                style: TextStyle(fontSize: 20),
              ),
              // Add your feed content here
            ],
          ),
        );
      },
    );
  }
}
