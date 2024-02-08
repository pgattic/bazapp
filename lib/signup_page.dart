import 'package:flutter/material.dart';
import 'firebase/auth_provider.dart';
import 'login_page.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            Image.asset(
              'assets/images/logo.jpg',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text;
                if (password.length < 6) {
                  // Show a toast message for password requirements
                  Fluttertoast.showToast(
                    msg: 'Password must be at least 6 characters',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } else {
                  Provider.of<AuthProvider>(context, listen: false)
                      .signUp(
                    email: emailController.text,
                    password: password,
                    displayName: displayNameController.text,
                  )
                      .then((result) {
                    // Successfully signed up
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  }).catchError((error) {
                    // Handle the error here
                    print('Error signing up: $error');
                  });
                }
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).pop();
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
