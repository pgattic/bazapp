import 'package:bazapp/app_colors.dart';
import 'package:bazapp/event/event.dart';
import 'package:bazapp/event/create_event_dialog.dart';
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
  CalendarViewType selectedView = CalendarViewType.day;
  ThemeData colors = AppColors.lightMode;
  String headerText = "Calendar";

  @override
  void initState() {
    super.initState();
    _fetchEvents();

    final authProvider = Provider.of<BZAuthProvider>(context, listen: false);

    // Listen for changes in AuthProvider
    authProvider.addListener(_onAuthProviderChange);

    final userPrefs = authProvider.userPreferences;
    selectedView = userPrefs!.calendarViewType;
    colors = userPrefs.isDarkMode ? AppColors.darkMode : AppColors.lightMode;
  }

  void _onAuthProviderChange() {
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      List<CustomEvent> events = await authProvider.getCalendarEvents();
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
        appBar: AppBar(
          title: Text(headerText),
          actions: [
            SizedBox(
              child: SegmentedButton<CalendarViewType>(
                selected: <CalendarViewType>{selectedView},
                onSelectionChanged: (value) {
                  setState(() {
                    selectedView = value.first;
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
          ],
        ),
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
            switch (selectedView) {
              case CalendarViewType.day:
                return DayView(
                  onEventTap: (events, date) {
                    final CustomEvent event = events[0].event as CustomEvent;
                    event.displayBottomSheet(context);
                  },
                  heightPerMinute: 1,
                  startHour: 5,
                  backgroundColor: Colors.transparent,
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(color: colors.splashColor),
                  ),
                );
              case CalendarViewType.week:
                return WeekView(
                  onEventTap: (events, date) {
                    final CustomEvent event = events[0].event as CustomEvent;
                    event.displayBottomSheet(context);
                  },
                  heightPerMinute: 1,
                  startHour: 5,
                  backgroundColor: Colors.transparent,
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(color: colors.splashColor),
                  ),
                );
              case CalendarViewType.month:
                return MonthView(
                  onEventTap: (events, date) {
                    final CustomEvent event = events.event as CustomEvent;
                    event.displayBottomSheet(context);
                  },
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(color: colors.splashColor),
                  ),
                );
            }
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
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
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

enum CalendarViewType {
  day(
    stringName: 'Day',
  ),
  week(
    stringName: 'Week',
  ),
  month(
    stringName: 'Month',
  );

  final String stringName;

  const CalendarViewType({required this.stringName});

  @override
  String toString() {
    return stringName;
  }

  static CalendarViewType fromString(String string) {
    for (var type in CalendarViewType.values) {
      if (type.stringName.toLowerCase() == string.trim().toLowerCase()) {
        return type;
      }
    }
    return CalendarViewType.day;
  }
}
