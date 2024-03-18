import 'package:bazapp/data/event_type.dart';
import 'package:bazapp/map/event_info_screen.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/*

  # CustomEvent Class

  This class is used to store an event, and it is to be used across the app as
  the de facto standard, be it for getting map info from the database, or when
  trying to display events on the Calendar. A CustomEvent should be capable of
  manifesting itself appropriately for any use case.

*/

class CustomEvent {

  LatLng location;
  DateTime date;
  DateTime? startTime;
  DateTime? endTime;
  String title;
  String description;
  EventType type;

  CustomEvent(this.location, this.date, this.title, this.description, this.type);

  void displayInfoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EventInfoScreen(
            dateTime: date,
            title: title,
            description: description,
            type: type,
            // Pass other event information as needed
          );
        },
      ),
    );
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Information about the markerInformation about the marker...'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    child: const Text('Information'),
                    onPressed: () {
                      displayInfoScreen(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Marker toMarker(BuildContext context) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () { displayBottomSheet(context); },
        child: type.mapIcon,
      ),
      rotate: true,
    );
  }

  CalendarEventData toCalendarEventData() {
    return CalendarEventData(
      title: title,
      date: date,
      description: description,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
