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

  LatLng location;
  DateTime date;
  DateTime? startTime;
  DateTime? endTime;
  String title;
  String description;
  EventType type;

  CustomEvent(this.location, this.date, this.title, this.description, this.type, [this.startTime, this.endTime]);

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
    if (startTime != null) {
      var hour = startTime!.hour % 12;
      var min = startTime!.minute;
      var minString = min < 10 ? '0$min' : min.toString();
      var sign = startTime!.hour > 11 ? 'pm' : 'am';
      return '$hour:$minString$sign';
    } else {
      return '';
    }
  }

  String getFormattedDate() {
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
      'December',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$month $day, $year';
  }

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

  Widget toFeedThumbnail(BuildContext context) {
    var timeTag = startTime == null ? '' : ' at ${getFormattedStartTime()}';
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
}
