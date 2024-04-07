import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewMini extends StatelessWidget {
  final LatLng location;
  final double width;
  final double height;
  final Key mapKey;

  MapViewMini(this.location, {this.width = 300, this.height = 300, Key? key})
      : mapKey = key ?? UniqueKey(), // Ensure a unique key is generated if not provided
        super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FlutterMap(
        key: mapKey,
        options: MapOptions(
          initialCenter: location,
          initialZoom: 16.0,
          interactionOptions: const InteractionOptions(flags: 0), // no interaction
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                rotate: true,
                alignment: Alignment.topCenter,
                child: const Icon(Icons.location_on, color: Colors.red, size: 32.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
