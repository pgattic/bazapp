import 'package:bazapp/data/event/event_type.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _selectedLocation;

  LatLng? get selectedLocation => _selectedLocation;

  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }
}




class CalendarScreen extends StatelessWidget {
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider<Object?>(
      controller: EventController<Object?>(), // Provide the controller here
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return MonthView();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed:  () {
            print("Add button tapped!"); // Debug print statement
            _createEvent(context);
          },
        ),
      ),
    );
  }

  Future<void> _createEvent(BuildContext context) async {
  final user = Provider.of<AuthProvider>(context, listen: false).user;
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);

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
                onPressed: () async {
                  selectedLocation = await _showMapPopup(context);
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
              if (title.isEmpty ||
                  description.isEmpty ||
                  selectedEventType.isEmpty ||
                  selectedLocation == null ||
                  selectedDateTime == null) {
                // Check which fields are missing and display a Snackbar
                List<String> missingFields = [];
                if (title.isEmpty) {
                  missingFields.add('Title');
                }
                if (description.isEmpty) {
                  missingFields.add('Description');
                }
                if (selectedEventType.isEmpty) {
                  missingFields.add('Event Type');
                }
                if (selectedLocation == null) {
                  missingFields.add('Location');
                }
                if (selectedDateTime == null) {
                  missingFields.add('Date and Time');
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please fill out the following fields: ${missingFields.join(', ')}'),
                ));
              } else {
                // Proceed to create event if all fields are filled
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
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
              }
            },
            child: Text('Create'),
          ),
        ],
      );
    },
  );
}

void _handleSelectedLocation(BuildContext context, LatLng location) {
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);
  locationProvider.setSelectedLocation(location);

  // Update UI to display the selected location
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Location selected: ${location.latitude}, ${location.longitude}'),
  ));
}

  Future<LatLng?> _showMapPopup(BuildContext context) async {
  final GlobalKey mapKey = GlobalKey();

  final RenderBox? mapBox = mapKey.currentContext?.findRenderObject() as RenderBox?;
  final Offset mapCenter = mapBox != null ? mapBox.localToGlobal(Offset(mapBox.size.width / 2, mapBox.size.height / 2)) : Offset.zero;

  final dummyDetails = LongPressStartDetails(
    globalPosition: mapCenter,
  );

  return await showDialog<LatLng?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GestureDetector(
            key: mapKey,
            child: FlutterMap(
              mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 100,
        maxZoom: 20,
              ),

              children: [], // Empty children list
            ),
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
  onPressed: () {
    final RenderBox? box = mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final localPosition = box.globalToLocal(dummyDetails.globalPosition);
      final LatLngBounds? bounds = mapController.bounds;
      final double height = bounds!.northEast.latitude - bounds.southWest.latitude;
      final double width = bounds.northEast.longitude - bounds.southWest.longitude;
      final LatLng latLng = LatLng(
        bounds.northEast.latitude - height * localPosition.dy / MediaQuery.of(context).size.height,
        bounds.southWest.longitude + width * localPosition.dx / MediaQuery.of(context).size.width,
      );

      // Call _handleSelectedLocation with the selected location
      _handleSelectedLocation(context, latLng);

      Navigator.pop(context, latLng); // Resolve the Future with Navigator.pop
    }
  },
  child: Text('Select'),
),
        ],
      );
    },
  );
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
  final LongPressStartDetails details;

  const MapPopup({
    Key? key,
    required this.onLocationSelected,
    required this.renderBox,
    required this.mapController,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        final LatLngBounds? bounds = mapController.bounds;
        final double height = bounds!.northEast.latitude - bounds.southWest.latitude;
        final double width = bounds.northEast.longitude - bounds.southWest.longitude;
        final LatLng latLng = LatLng(
          bounds.northEast.latitude - height * localPosition.dy / MediaQuery.of(context).size.height,
          bounds.southWest.longitude + width * localPosition.dx / MediaQuery.of(context).size.width,
        );
        onLocationSelected(latLng);
      },
      child: Container(),
    );
  }
}


