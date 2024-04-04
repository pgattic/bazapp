import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/create_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  List<CustomEvent> feedEventList = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();

    // Listen for changes in AuthProvider
    Provider.of<AuthProvider>(context, listen: false)
        .addListener(_onAuthProviderChange);
  }

  void _onAuthProviderChange() {
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<CustomEvent> events = await authProvider.getUserEvents();
      setState(() {
        feedEventList = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Object?>(
      controller: EventController<Object?>(), // Provide the controller here
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            for (final event in feedEventList) {
            final CalendarEventData<CustomEvent> calEvent = CalendarEventData(
                date: event.dateTime,
                startTime: event.dateTime,
                endTime: event.dateTime.add(const Duration(hours: 3)),
                title: event.title,
                description: event.description,
                color: event.type.color,
                event: event,
            );
            CalendarControllerProvider.of(context).controller.add(calEvent);
          }
            return DayView(
              onEventTap: (events, date) {
                final CustomEvent event = events[0].event as CustomEvent;
                event.displayBottomSheet(context);
              }
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final eventToUpload = await showDialog<CustomEvent>(
                context: context,
                builder: (BuildContext context) {
                  return CreateEventDialog(selectedDateTime: DateTime.now());
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
