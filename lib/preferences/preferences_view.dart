
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesDialog extends StatefulWidget {
   PreferencesDialog({Key? key}) : super(key: key);

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  UserPreferences? userPreferences;

  @override
  void initState() {
    super.initState();
    _fetchPrefs();

    final authProvider = Provider.of<BZAuthProvider>(context, listen: false);

    // Listen for changes in AuthProvider
    authProvider.addListener(_onAuthProviderChange);

    userPreferences = authProvider.userPreferences;

  }

  void _onAuthProviderChange() {
    _fetchPrefs();
  }

  void _fetchPrefs() async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      setState(() {
        userPreferences = authProvider.userPreferences;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Preferences"),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column (
            children: [
              Row(
                children: [
                  const Text("Dark Mode:", style: TextStyle(fontSize: 16)), //Theme.of(context).textTheme.labelLarge
                  if (userPreferences == null)
                    const CircularProgressIndicator()
                  else
                    Checkbox(
                      value: userPreferences!.isDarkMode,
                      onChanged: (value) {
                        userPreferences!.isDarkMode = value!;
                        _setUserPrefs();
                      },
                    ),
                ],
              )
            ]
          ),
        ),
      ),
    );
  }

  _setUserPrefs() {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      authProvider.updateUserPrefs(userPreferences!);
    } catch (e) {
      print('Error updating user preferences: $e');
    }
    setState(() {
      userPreferences = userPreferences;
    });
  }
}
