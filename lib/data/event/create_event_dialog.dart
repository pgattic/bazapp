import 'package:bazapp/constants.dart';
import 'package:bazapp/time_functions.dart';
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/event_type.dart';
import 'package:bazapp/map/location_selector.dart';
import 'package:bazapp/map/map_view_mini.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CreateEventDialog extends StatefulWidget {
  final LatLng? selectedLocation;
  final DateTime? selectedDateTime;

  const CreateEventDialog({super.key, this.selectedLocation, this.selectedDateTime});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  String title = '';
  String description = '';
  EventType selectedEventType = EventType.other;
  LatLng? selectedLocation;
  DateTime? selectedDateTime;
  bool isFormComplete = false;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.selectedLocation;
    selectedDateTime = widget.selectedDateTime;
    checkFormCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
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
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  description = value;
                  checkFormCompletion();
                });
              },
            ),
            Row(
              children: [
                const Text('Type: '),
                DropdownButton<EventType>(
                  value: selectedEventType,
                  onChanged: (EventType? newValue) {
                    if (newValue == null) return;
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
                          const SizedBox(width: 10),
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
                )?? selectedLocation;
                checkFormCompletion();
              },
              child: const Text('Select Location'),
            ),
            if (selectedLocation != null) MapViewMini(selectedLocation!, height: 150),
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
            Text(selectedDateTime == null ? 'None': TimeFunctions.yMMMMd(selectedDateTime!)),
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
          onPressed: isFormComplete
              ? () {
                  Navigator.pop(
                    context,
                    CustomEvent(selectedLocation!, selectedDateTime!, title,
                        description, selectedEventType),
                  );
                }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void checkFormCompletion() {
    setState(() {
      isFormComplete = title.isNotEmpty &&
          description.isNotEmpty &&
          selectedLocation != null &&
          selectedDateTime != null;
    });
  }
}
