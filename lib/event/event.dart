import 'package:bazapp/time_functions.dart';
import 'package:bazapp/event/event_bottom_sheet.dart';
import 'package:bazapp/event/event_type.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/event/event_info_screen.dart';
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
  String? id;
  String? userId;
  LatLng location;
  DateTime dateTime;
  String title;
  String description;
  EventType type;

  CustomEvent(
      this.location, this.dateTime, this.title, this.description, this.type,
      [this.id, this.userId]);

  Future<bool> displayInfoScreen(BuildContext context) async { // returns true if the dialog should stay open
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EventInfoScreen(event: this);
        },
      ),
    ) ?? true;
    return result;
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EventBottomSheet(event: this);
      },
    );
  }

  Marker toMarker(BuildContext context) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () {
          displayBottomSheet(context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: type.color,
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              type.icon,
              color: Colors.white,
              size: 30,
            ),
            Positioned(
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: type.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  TimeFunctions.getComfyDate(dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      rotate: true,
    );
  }

  CalendarEventData toCalendarEventData() {
    return CalendarEventData(
      title: title,
      date: dateTime,
      description: description,
      startTime: dateTime,
      endTime: dateTime
          .add(const Duration(hours: 1)), // TODO: Add user-specified duration
    );
  }

  Widget toFeedThumbnail(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: type.infoScreenIcon,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(TimeFunctions.getComfyDateTime(dateTime))
                ],
              ),
            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                const SizedBox(width: 8),
//                TextButton(
//                  child: const Text('INFO'),
//                  onPressed: () => displayInfoScreen(context),
//                ),
//                const SizedBox(width: 8),
//              ],
//            ),
          ],
        ),
      ),
      onTap: () => displayInfoScreen(context),
    );
  }

  Event toDBEvent({String userId = ''}) {
    return Event(
      title: title,
      dateTime: dateTime,
      description: description,
      eventType: type.toString(),
      latitude: location.latitude,
      longitude: location.longitude,
      userId: userId,
    );
  }
}
