import 'package:bazapp/constants.dart';
import 'package:bazapp/data/event/event_type.dart';
import 'package:bazapp/firebase/auth_provider.dart';
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

  String? id;
  String? userId;
  LatLng location;
  DateTime dateTime;
  String title;
  String description;
  EventType type;

  CustomEvent(this.location, this.dateTime, this.title, this.description, this.type, [this.id, this.userId]);

//  String getFormattedTimeRange() { // Get time in 12-hour format
//    if (startTime != null && endTime != null) {
//      var sHour = startTime!.hour % 12;
//      var sMin = startTime!.minute;
//      var sSign = startTime!.hour > 11 ? 'pm' : 'am';
//      var eHour = endTime!.hour % 12;
//      var eMin = endTime!.minute;
//      var eSign = endTime!.hour > 11 ? 'pm' : 'am';
//      return '$sHour:$sMin${sSign==eSign?"":sSign} - $eHour:$eMin$eSign';
//    } else {
//      return '';
//    }
//  }

  String getFormattedStartTime() {
    return Constants.getFormattedTime(dateTime);
  }

  String getFormattedDate() {
    return Constants.getFormattedDate(dateTime);
  }

  void displayInfoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EventInfoScreen(
            dateTime: dateTime,
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
        child: Column(
          // centered contents
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            type.mapIcon,
            Text(getFormattedDate(), style: const TextStyle(fontSize: 12)),
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
      endTime: dateTime.add(const Duration(hours: 1)), // TODO: Add user-specified duration
    );
  }

  Widget toFeedThumbnail(BuildContext context) {
    var timeTag = ' at ${getFormattedStartTime()}';
    return GestureDetector(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: type.infoScreenIcon,
              title: Text(title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description),
                  Text("${getFormattedDate()}$timeTag")
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
