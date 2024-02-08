
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapMarker extends Marker {

  CustomMapMarker({
    required BuildContext context,
    required LatLng point,
//    required MapController mapController,
  }) : super(
      point: point,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () {
          // ignore: avoid_print
          print("tapped!");
//          mapController.moveAndRotate(point, 15.0, 0);
          showBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Information about the markerInformation about the marker...'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            child: const Text('Information'),
                            onPressed: () {

                            },
                          ),
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const FlutterLogo(),
      ),
      rotate: true,
  );
}
