import 'dart:async';
import 'package:bazapp/constants.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/planner/create_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:bazapp/data/event/event.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final mapController = MapController();
  LatLng? currentLocation;
  bool isLocationCentered = false;
  late loc.Location location;
  late StreamSubscription<loc.LocationData> locationSubscription;
  List<CustomEvent> mapEventList = [];

  @override
  void initState() {
    super.initState();
    location = loc.Location();
    _getLocation();
    _fetchEvents();

    // Listen for changes in AuthProvider
    Provider.of<AuthProvider>(context, listen: false).addListener(_onAuthProviderChange);
  }

  void _onAuthProviderChange() {
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<CustomEvent> events = await authProvider.getAllEvents();
      setState(() {
        mapEventList = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void _getLocation() async {
    bool serviceEnabled = false;
    loc.PermissionStatus _permissionGranted;

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

    locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        if (!isLocationCentered) {
          this.currentLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          mapController.move(this.currentLocation!, 15.0);
          isLocationCentered = true;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription.cancel();
    Provider.of<AuthProvider>(context, listen: false).removeListener(_onAuthProviderChange);
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialCenter = Constants.defaultLocation;
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
        onLongPress: (tapPos, point) async {
          final eventToUpload = await showDialog<CustomEvent>(
              context: context,
              builder: (BuildContext context) {
                return CreateEventDialog(selectedLocation: point);
              });
          if (eventToUpload == null) return;
          _createEvent(eventToUpload, context);
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
  Future<void> _createEvent(CustomEvent event, BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Add event to Firebase
      await authProvider.addEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Event created successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create event: $e'),
      ));
    }
  }
}
