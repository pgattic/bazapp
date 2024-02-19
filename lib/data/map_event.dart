import 'package:bazapp/data/map_event_type.dart';
import 'package:bazapp/map/event_info_screen.dart';
//import 'package:bazapp/map/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapEvent {

  LatLng location;
  DateTime dateTime;
  String title;
  String description;
  EventType type;

  CustomMapEvent(this.location, this.dateTime, this.title, this.description, this.type);

  void displayInfoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EventInfoScreen(
            dateTime: dateTime,
            title: title,
            description: description,
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
        child: type.icon,
      ),
      rotate: true,
    );
  }
}
