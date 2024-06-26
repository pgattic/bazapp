import 'package:flutter/material.dart';
import '/firebase/auth_provider.dart';
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
    final authProvider = Provider.of<BZAuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0), // Adjust the radius as needed
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
                      ),
                  ),
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
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                      }
                    },
                    child: const Text('Log In'),
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
        ),
      ),
    );
  }

  // Function to reset the user's password.
  void _resetPassword(String email) {
    final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
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
