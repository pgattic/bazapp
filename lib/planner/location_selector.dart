import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// LocationSelector: Displays a map that allows the user to select a location, returns the selected location with Navigator.pop().
// For an example usage, see planner_view.dart.

class LocationSelector extends StatefulWidget {
  final LatLng initialLocation;

  const LocationSelector({Key? key, required this.initialLocation})
      : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  late LatLng result;

  @override
  void initState() {
    super.initState();
    result = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Location'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: result,
            initialZoom: 13.0,
            maxZoom: 20,
            onPositionChanged: (position, _) {
              var ctr = position.center;
              if (ctr != null) {
                setState(() {
                  result = ctr;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 30.0,
                  height: 30.0,
                  point: result,
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog without selecting
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, result); // Pass selectedLocation back
          },
          child: Text('Select'),
        ),
      ],
    );
  }
}
