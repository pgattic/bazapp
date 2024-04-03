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
    color: Colors.red,
  ),
  sale(
    stringName: "Sale",
    icon: Icons.monetization_on,
    color: Colors.green
  );

  final String stringName;
  final IconData icon;
  final Color color;

  get mapIcon => Icon(icon, color: color, size: 50);
  get infoScreenIcon => Icon(icon, color: color);

  @override
  String toString() {
    return stringName;
  }

  const EventType({
    required this.stringName,
    required this.icon,
    required this.color
  });

  EventType? fromString(String name) {
    switch (name) {
      case "Party":
        return EventType.party;
      case "Service":
        return EventType.service;
      case "Sale":
        return EventType.sale;
      default:
        return null;
    }
  }
}
