
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesView extends StatefulWidget {
   PreferencesView({Key? key}) : super(key: key);

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
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
      UserPreferences prefs = await authProvider.getUserPrefs();
      setState(() {
        userPreferences = prefs;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferences"),
      ),
      body: Container(
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
