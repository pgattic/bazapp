import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/*

  CONSTANTS

  This class is used to store constants that are used across the app. use these where you can!

*/

class Constants {
  static const LatLng defaultLocation = LatLng(43.8231759,-111.7924097); // Rexburg, Idaho!
  static const TextStyle defaultTextStyle = TextStyle(fontSize: 16);

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

    return '$month $day';
  }

  static String getShortDate(DateTime dateTime) {
    final months = [
      'Jan.',
      'Feb.',
      'Mar.',
      'Apr.',
      'May',
      'Jun.',
      'Jul.',
      'Aug.',
      'Sept.',
      'Oct.',
      'Nov.',
      'Dec.',
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];

    return '$month $day';
  }

  static String getFormattedDateWithYear(DateTime dateTime) {
    return '${getFormattedDate(dateTime)} ${dateTime.year}';
  }

  static String yMMMMd(DateTime dateTime) {
    return "${getFormattedDateWithYear(dateTime)} at ${getFormattedTime(dateTime)}";
  }
  
  static String MMMMd(DateTime dateTime) {
    return "${getFormattedDate(dateTime)} at ${getFormattedTime(dateTime)}";
  }

  static String getComfyDate(DateTime dateTime) {
    if (dateTime.year == DateTime.now().year) {
      if (dateTime.day == DateTime.now().day) {
        return 'Today';
      } else if (dateTime.add(const Duration(days: 1)).day == DateTime.now().day) {
        return 'Yesterday';
      } else if (dateTime.subtract(const Duration(days: 1)).day == DateTime.now().day) {
        return 'Tomorrow';
      }
      return getShortDate(dateTime);
    }
    return '${getShortDate(dateTime)} ${dateTime.year}';
  }

  static String getComfyDateTime(DateTime dateTime) {
    return "${getComfyDate(dateTime)} at ${getFormattedTime(dateTime)}";
  }

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
}