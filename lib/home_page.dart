import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add other widgets or content here
            ElevatedButton(
              onPressed: () {
                // Sign out the user
                FirebaseAuth.instance.signOut();
                // Navigate to the Login page
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
