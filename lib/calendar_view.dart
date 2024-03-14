import 'package:bazapp/data/event_type.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Object?>(
      controller: EventController<Object?>(), // Provide the controller here
      child: Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print("Add button tapped!"); // Debug print statement
                _createEvent(context);
              },
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            return MonthView();
          },
        ),
      ),
    );
  }

  Future<void> _createEvent(BuildContext context) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // Initialize variables for event fields
    String title = '';
    String description = '';
    String selectedEventType = '';
    LatLng? selectedLocation;
    DateTime? selectedDateTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: selectedEventType),
                  decoration: InputDecoration(
                    labelText: 'Event Type',
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down),
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Option 1',
                            child: Text('Option 1'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Option 2',
                            child: Text('Option 2'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Option 3',
                            child: Text('Option 3'),
                          ),
                          // Add more PopupMenuItem widgets as needed
                        ];
                      },
                      onSelected: (String value) {
                        selectedEventType = value;
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showMapPopup(context);
                  },
                  child: Text('Select Location'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Show date time picker and get selected date time
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selected != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        selectedDateTime = DateTime(
                          selected.year,
                          selected.month,
                          selected.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: Text('Select Date and Time'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate and create event
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    selectedEventType.isNotEmpty &&
                    selectedLocation != null &&
                    selectedDateTime != null) {
                  // Create event object
                  final event = Event(
                    eventId: '', // Generate event ID
                    title: title,
                    dateTime: selectedDateTime!,
                    description: description,
                    eventType: selectedEventType,
                    latitude: selectedLocation!.latitude,
                    longitude: selectedLocation!.longitude,
                    userId: user!.uid,
                    color: '', // Set color
                    createdFlag: 'Y', // Set created flag
                    followedFlag: 'N', // Set followed flag
                  );

                  try {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    // Add event to Firebase
                    await authProvider.addEvent(event);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Event created successfully'),
                    ));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to create event: $e'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill out all fields'),
                  ));
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showMapPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final dummyDetails = LongPressStartDetails(
              globalPosition: box.size.center(Offset.zero),
            );
            return MapPopup(
              onLocationSelected: (LatLng latLng) {
                Navigator.pop(context, latLng);
              },
              renderBox: box,
              mapController: mapController,
              details: dummyDetails,
            );
          },
        );
      },
    ).then((value) {
      if (value != null && value is LatLng) {
        print('Selected location: ${value.latitude}, ${value.longitude}');
      }
    });
  }
}

String _formatDateTime(DateTime dateTime) {
  final formattedDate = DateFormat.yMMMMd(dateTime);
  return formattedDate;
}

class DateFormat {
  static String yMMMMd(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    return '$month $day, $year at $hour:$minute';
  }
}

class MapPopup extends StatelessWidget {
  final Function(LatLng) onLocationSelected;
  final RenderBox renderBox;
  final MapController mapController;

  const MapPopup({
    Key? key,
    required this.onLocationSelected,
    required this.renderBox,
    required this.mapController,
    required LongPressStartDetails details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        final Offset localPosition =
            renderBox.globalToLocal(details.globalPosition);
        final LatLngBounds? bounds = mapController.bounds;
        final double height =
            bounds!.northEast.latitude - bounds.southWest.latitude;
        final double width =
            bounds.northEast.longitude - bounds.southWest.longitude;
        final LatLng latLng = LatLng(
          bounds.northEast.latitude -
              height * localPosition.dy / MediaQuery.of(context).size.height,
          bounds.southWest.longitude +
              width * localPosition.dx / MediaQuery.of(context).size.width,
        );
        onLocationSelected(latLng);
      },
      child: Container(),
    );
  }
}





//import 'dart:ui';
//
//import 'package:bazapp/data/event.dart';
//import 'package:bazapp/data/event_type.dart';
//import 'package:calendar_view/calendar_view.dart';
//import 'package:flutter/material.dart';
//import 'package:latlong2/latlong.dart';
//
//class CalendarView extends StatefulWidget {
//
//  const CalendarView({super.key});
//
//  @override
//  State<CalendarView> createState() => _CalendarViewState();
//}
//
//class _CalendarViewState extends State<CalendarView> {
//
//  List<CustomEvent> mapEventList = [
//    CustomEvent(
//      const LatLng(51.509364, -0.128928),
//      DateTime.now(),
//      "Party",
//      "This is a test event",
//      EventType.party,
//    ),
//    CustomEvent(
//      const LatLng(52.509364, -0.128928),
//      DateTime.now(),
//      "Service",
//      "This is a test event",
//      EventType.service,
//    ),
//    CustomEvent(
//      const LatLng(53.509364, -0.128928),
//      DateTime.now(),
//      "Sale",
//      "This is a test event",
//      EventType.sale,
//    ),
//    CustomEvent(
//      const LatLng(54.509364, -0.128928),
//      DateTime.now(),
//      "Buy my stuff",
//      "This is a test event",
//      EventType.sale,
//    ),
//  ];
//
//  void addEvent(CustomEvent event) { // Invoke this function from the parent class in order to add an event to the loaded events.
//    mapEventList.add(event);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return CalendarControllerProvider<CustomEvent>(
//      controller: EventController<CustomEvent>()..addAll(_events),
//      child: MaterialApp(
//        title: 'Flutter Calendar Page Demo',
//        debugShowCheckedModeBanner: false,
//        theme: ThemeData.light(),
//        scrollBehavior: ScrollBehavior().copyWith(
//          dragDevices: {
//            PointerDeviceKind.trackpad,
//            PointerDeviceKind.mouse,
//            PointerDeviceKind.touch,
//          },
//        ),
//        home: ResponsiveWidget(
//          mobileWidget: MobileHomePage(),
//          webWidget: WebHomePage(),
//        ),
//      ),
//    );
//  }
//}
//