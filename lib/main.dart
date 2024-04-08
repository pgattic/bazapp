import 'package:bazapp/app_colors.dart';
import 'package:bazapp/firebase/firebase_options.dart';
import 'package:bazapp/home.dart';
import 'package:bazapp/login/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BZAuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Background message handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Request permission for notifications
    FirebaseMessaging.instance.requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages when the app is in the foreground
      print('Foreground Message Received: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the device token and store it in Firestore
    //_saveDeviceTokenToFirestore();
 
    return MaterialApp(
      title: 'Bazapp',
      theme: AppColors.lightMode,
      darkTheme: AppColors.darkMode,
      themeMode: ThemeMode.system,
      home: Consumer<BZAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          print('User: $user');
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

          // Check if the user is authenticated
          if (user != null) {
            _saveDeviceTokenToFirestore();
            final userPrefs = authProvider.userPreferences;
            return HomeScreen(user: user, userPreferences: userPrefs); // Pass the user to HomeScreen
          } else {
            return LoginPage(); // Return LoginPage when the user is not authenticated
          }
        },
      ),
    );
  }

  // Function to get the device token and save it to Firestore
  Future<void> _saveDeviceTokenToFirestore() async {
    final user = fire.FirebaseAuth.instance.currentUser?.uid;
    try {
      // Get the device token
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      

      // Check if the device token is available
      if (deviceToken != null) {
        // Store the device token in Firestore
        // Replace 'YOUR_COLLECTION_NAME' and 'YOUR_USER_ID_FIELD_NAME' with your actual collection and field names
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user)
            .update({'deviceToken': deviceToken});
      } else {
        print('Device token is null');
      }
    } catch (e) {
      print('Error saving device token: $e');
    }
  }
}
