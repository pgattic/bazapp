import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bazapp/data/event.dart';
import 'package:bazapp/data/event_type.dart';

class MapView extends StatefulWidget {
  MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final mapController = MapController();

  void _showMapPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        return MapPopup(
          onLocationSelected: (LatLng latLng) {
            Navigator.pop(context, latLng);
          },
          renderBox: box,
          mapController: mapController,
          details: LongPressStartDetails(
              globalPosition: box.size.center(Offset.zero)),
        );
      },
    ).then((value) {
      if (value != null && value is LatLng) {
        print('Selected location: ${value.latitude}, ${value.longitude}');
      }
    });
  }

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

  void addEvent(CustomEvent event) {
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
          print('Long press at: ${point.latitude}, ${point.longitude}');
        },
      ),
      mapController: mapController,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: mapEventList
              .map((mapEvent) => mapEvent.toMarker(context))
              .toList(),
        ),
      ],
    );
  }
}

class MapPopup extends StatelessWidget {
  final Function(LatLng) onLocationSelected;
  final RenderBox renderBox;
  final MapController mapController;

  const MapPopup({
    Key? key,
    required this.onLocationSelected,
    required this.renderBox,
    required this.mapController,
    required LongPressStartDetails details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        final Offset localPosition =
            renderBox.globalToLocal(details.globalPosition);
        final LatLngBounds? bounds = mapController.bounds;
        final double height =
            bounds!.northEast.latitude - bounds.southWest.latitude;
        final double width =
            bounds.northEast.longitude - bounds.southWest.longitude;
        final LatLng latLng = LatLng(
          bounds.northEast.latitude -
              height * localPosition.dy / MediaQuery.of(context).size.height,
          bounds.southWest.longitude +
              width * localPosition.dx / MediaQuery.of(context).size.width,
        );
        onLocationSelected(latLng);
      },
      child: Container(),
    );
  }
}
