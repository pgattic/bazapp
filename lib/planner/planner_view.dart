import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/create_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Object?>(
      controller: EventController<Object?>(), // Provide the controller here
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return const DayView();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final eventToUpload = await showDialog<CustomEvent>(
                context: context,
                builder: (BuildContext context) {
                  return CreateEventDialog();
                });
            if (eventToUpload == null) return;
            _createEvent(eventToUpload, context);
          },
        ),
      ),
    );
  }

  Future<void> _createEvent(CustomEvent event, BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Add event to Firebase
      await authProvider.addEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Event created successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create event: $e'),
      ));
    }
  }
}
