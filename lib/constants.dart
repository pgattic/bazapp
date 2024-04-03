import 'package:latlong2/latlong.dart';

/*

  CONSTANTS

  This class is used to store constants that are used across the app. use these where you can!

*/

class Constants {
  static const LatLng defaultLocation = LatLng(43.8231759,-111.7924097); // Rexburg, Idaho!

  static String getFormattedTime(DateTime dateTime) {
    var hour = (dateTime.hour - 1) % 12 + 1;
    var min = dateTime.minute;
    var minString = min < 10 ? '0$min' : min.toString();
    var sign = dateTime.hour > 11 ? 'pm' : 'am';
    return '$hour:$minString $sign';
  }

  static String getFormattedDate(DateTime dateTime) {
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

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    return '$month $day, $year';
  }

  static String yMMMMd(DateTime dateTime) {
    return "${getFormattedDate(dateTime)} at ${getFormattedTime(dateTime)}";
  }
}