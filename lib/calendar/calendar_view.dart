import 'dart:ui';

import 'package:bazapp/data/event.dart';
import 'package:bazapp/data/event_type.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CalendarView extends StatefulWidget {

  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {

  List<CustomEvent> mapEventList = [
    CustomEvent(
      const LatLng(51.509364, -0.128928),
      DateTime.now(),
      "Party",
      "This is a test event",
      EventType.party,
    ),
    CustomEvent(
      const LatLng(52.509364, -0.128928),
      DateTime.now(),
      "Service",
      "This is a test event",
      EventType.service,
    ),
    CustomEvent(
      const LatLng(53.509364, -0.128928),
      DateTime.now(),
      "Sale",
      "This is a test event",
      EventType.sale,
    ),
    CustomEvent(
      const LatLng(54.509364, -0.128928),
      DateTime.now(),
      "Buy my stuff",
      "This is a test event",
      EventType.sale,
    ),
  ];

  void addEvent(CustomEvent event) { // Invoke this function from the parent class in order to add an event to the loaded events.
    mapEventList.add(event);
  }

  @override
  Widget build(BuildContext context) {

    return CalendarControllerProvider<CustomEvent>(
      controller: EventController<CustomEvent>()..addAll(_events),
      child: MaterialApp(
        title: 'Flutter Calendar Page Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        scrollBehavior: ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        home: ResponsiveWidget(
          mobileWidget: MobileHomePage(),
          webWidget: WebHomePage(),
        ),
      ),
    );
  }
}
