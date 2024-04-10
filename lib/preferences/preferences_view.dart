import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/planner/planner_view.dart';
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
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            if (userPreferences == null)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Dark Theme", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: userPreferences!.isDarkMode,
                    onChanged: (value) {
                      userPreferences!.isDarkMode = value;
                      _setUserPrefs();
                    },
                  ),
                ],
              ),
            const SizedBox(height: 8),
            const Text("Default Calendar View:",
                style: TextStyle(fontSize: 16)),
            SizedBox(
              child: SegmentedButton<CalendarViewType>(
                selected: <CalendarViewType>{userPreferences!.calendarViewType},
                onSelectionChanged: (value) {
                  setState(() {
                    userPreferences!.calendarViewType = value.first;
                    _setUserPrefs();
                  });
                },
                segments: const [
                  ButtonSegment<CalendarViewType>(
                    value: CalendarViewType.day,
                    icon: Icon(Icons.calendar_view_day),
                  ),
                  ButtonSegment<CalendarViewType>(
                    value: CalendarViewType.week,
                    icon: Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment<CalendarViewType>(
                    value: CalendarViewType.month,
                    icon: Icon(Icons.calendar_view_month),
                  ),
                ],
              ),
            ),
          ]),
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
