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

  CustomEvent(
      this.location, this.dateTime, this.title, this.description, this.type,
      [this.id, this.userId]);

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

  String getFormattedDateWithYear() {
    return Constants.getFormattedDateWithYear(dateTime);
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
            event: this,
          );
        },
      ),
    );
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  type.infoScreenIcon,
                  const SizedBox(width: 8),
                  const Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                Constants.yMMMMd(dateTime),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      displayInfoScreen(context);
                    },
                    child: const Text('More Info'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
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
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: type.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getFormattedDate(),
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
