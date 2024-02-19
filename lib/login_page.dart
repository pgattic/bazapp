import 'package:flutter/material.dart';
import '/firebase/auth_provider.dart';
import 'main.dart';
import 'signup_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add a variable to track the password reset message.
  String _passwordResetMessage = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      // If the user is already signed in, navigate to the main page
      return HomeScreen();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image.asset(
              //   'assets/images/logo.png',
              //   width: 150, // Adjust the size as needed
              //   height: 150, // Adjust the size as needed
              // ),
              const SizedBox(height: 16),
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform login with email and password
                    authProvider.login(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  // Navigate to the sign-up page
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
              // Display the password reset message.
              Text(_passwordResetMessage,
                  style: TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Implement password reset function
                  _resetPassword(_emailController.text);
                },
                child: const Text('Forgot Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to reset the user's password.
  void _resetPassword(String email) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.resetPassword(email).then((result) {
      // Display a message to the user.
      setState(() {
        _passwordResetMessage = 'Password reset email sent to $email';
      });
    }).catchError((error) {
      // Handle error and display an error message.
      setState(() {
        _passwordResetMessage = 'Error: $error';
      });
    });
  }
}
