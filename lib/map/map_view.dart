import 'package:bazapp/data/event.dart';
import 'package:bazapp/data/event_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';


class MapView extends StatefulWidget {

  MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final mapController = MapController();

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
    CustomEvent(
      const LatLng(55.509364, -0.128928),
      DateTime.now(),
      "this is epic",
      "poggers",
      EventType.service,
    )
  ];

  void addEvent(CustomEvent event) { // Invoke this function from the parent class in order to add an event to the loaded events.
    mapEventList.add(event);
  }

  @override
  Widget build(BuildContext context) {

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
        maxZoom: 20,
        onLongPress: (tapPos, point) {
          // ignore: avoid_print
          print('Long press at: ${point.latitude}, ${point.longitude}');

        },
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
          markers: mapEventList.map((mapEvent) => mapEvent.toMarker(context)).toList(), // get all of the map events as Markers
        ),
      ],
    );
  }
}
