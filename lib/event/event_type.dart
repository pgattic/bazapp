import 'package:flutter/material.dart';

enum EventType {
  party(
    stringName: "Party",
    icon: Icons.celebration,
    color: Colors.blue,
  ),
  service(
    stringName: "Service",
    icon: Icons.construction,
    color: Colors.orange,
  ),
  sale(
    stringName: "Sale",
    icon: Icons.attach_money,
    color: Colors.green
  ),
  trip(
    stringName: "Trip",
    icon: Icons.directions_car,
    color: Colors.purple
  ),
  other(
    stringName: "Other",
    icon: Icons.question_mark,
    color: Colors.grey,
  );

  final String stringName;
  final IconData icon;
  final Color color;

  get mapIcon => Icon(icon, color: color, size: 50);
  get infoScreenIcon => Icon(icon, color: color, size: 32);

  @override
  String toString() {
    return stringName;
  }

  const EventType({
    required this.stringName,
    required this.icon,
    required this.color
  });

  static EventType fromString(String name) {
    for (var type in EventType.values) {
      if (type.stringName.toLowerCase() == name.trim().toLowerCase()) {
        return type;
      }
    }
    return EventType.other;
  }
}
