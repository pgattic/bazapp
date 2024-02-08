import 'package:bazapp/map/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';


class MapDisplay extends StatelessWidget {
  final mapController = MapController();

  MapDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
        maxZoom: 20,
      ),
      mapController: mapController,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
//         RichAttributionWidget(
//           attributions: [
//             TextSourceAttribution(
//               'OpenStreetMap contributors',
// //              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
//             ),
//           ],
//         ),
        MarkerLayer(
          markers: [
            CustomMapMarker(
              context: context,
              point: const LatLng(51.509364, -0.128928),
            ),
            CustomMapMarker(
              context: context,
              point: const LatLng(52.509364, -0.128928),
            ),
            CustomMapMarker(
              context: context,
              point: const LatLng(53.509364, -0.128928),
            ),
          ],
        ),
      ],
    );
  }
}
