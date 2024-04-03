import 'package:bazapp/constants.dart';
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/event_type.dart';
import 'package:bazapp/planner/location_selector.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CreateEventDialog extends StatefulWidget {
  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  String title = '';
  String description = '';
  EventType? selectedEventType;
  LatLng? selectedLocation;
  DateTime? selectedDateTime;
  bool isFormComplete = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  title = value;
                  checkFormCompletion();
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  description = value;
                  checkFormCompletion();
                });
              },
            ),
            Row(
              children: [
                Text('Type: '),
                DropdownButton<EventType>(
                  value: selectedEventType,
                  onChanged: (EventType? newValue) {
                    setState(() {
                      selectedEventType = newValue;
                      checkFormCompletion();
                    });
                  },
                  items: EventType.values.map((EventType type) {
                    return DropdownMenuItem<EventType>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(type.icon), // Display icon next to the option
                          SizedBox(width: 10),
                          Text(type.stringName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                selectedLocation = await showDialog<LatLng>(
                  context: context,
                  builder: (BuildContext context) {
                    return LocationSelector(
                      initialLocation:
                          selectedLocation ?? Constants.defaultLocation,
                    );
                  },
                );
                checkFormCompletion();
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
                    checkFormCompletion();
                  }
                }
              },
              child: const Text('Select Date and Time'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('Create'),
          onPressed: isFormComplete
              ? () {
                  Navigator.pop(
                    context,
                    CustomEvent(selectedLocation!, selectedDateTime!, title,
                        description, selectedEventType!),
                  );
                }
              : null,
        ),
      ],
    );
  }

  void checkFormCompletion() {
    setState(() {
      isFormComplete = title.isNotEmpty &&
          description.isNotEmpty &&
          selectedEventType != null &&
          selectedLocation != null &&
          selectedDateTime != null;
    });
  }
}
