import 'package:flutter/material.dart';

enum EventType {
  party(
    stringName: "Party",
    icon: Icon(Icons.celebration, color: Colors.blue),
  ),
  service(
    stringName: "Service",
    icon: Icon(Icons.construction, color: Colors.red),
  ),
  sale(stringName: "Sale", icon: Icon(Icons.monetization_on, color: Colors.green));

  final String stringName;
  final Icon icon;

  const EventType({
    required this.stringName,
    required this.icon,
  });
}