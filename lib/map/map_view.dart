import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:bazapp/data/event/event.dart';
import 'package:bazapp/data/event/event_type.dart';

class MapView extends StatefulWidget {
  MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final mapController = MapController();
  LatLng? currentLocation;
  bool isLocationCentered = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    loc.Location location = loc.Location();

    bool serviceEnabled = false;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        this.currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        if (!isLocationCentered) {
          mapController.move(this.currentLocation!, 15.0);
          isLocationCentered = true;
        }
      });
    });
  }

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
            globalPosition: box.size.center(Offset.zero),
          ),
        );
      },
    ).then((value) {
      if (value != null && value is LatLng) {
        print('Selected location: ${value.latitude}, ${value.longitude}');
      }
    });
  }

  List<CustomEvent> mapEventList = [ // TODO: Get events from database, not hardcoded
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
    LatLng initialCenter = LatLng(51.509364, -0.128928);
    double initialZoom = 9.2;

    if (currentLocation != null && !isLocationCentered) {
      initialCenter = currentLocation!;
      initialZoom = 15.0;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
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
          markers: [
            if (currentLocation != null)
              Marker(
                width: 30.0,
                height: 30.0,
                point: currentLocation!,
                child: const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 30.0,
                ),
              ),
              ...mapEventList
                .map((mapEvent) => mapEvent.toMarker(context))
                .toList(),
          ],
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
