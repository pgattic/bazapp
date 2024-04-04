import 'package:bazapp/time_functions.dart';
import 'package:bazapp/data/event/event.dart';
import 'package:flutter/material.dart';

class EventBottomSheet extends StatelessWidget {
  final CustomEvent event;

  const EventBottomSheet({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              event.type.infoScreenIcon,
              const SizedBox(width: 8),
              const Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            TimeFunctions.yMMMMd(event.dateTime),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  event.displayInfoScreen(context);
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
  }
}
