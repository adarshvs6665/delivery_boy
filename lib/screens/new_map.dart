import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final bool isOrderActive;

  MapWidget({required this.isOrderActive});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  // static const LatLng sourceLocation = LatLng(8.5686, 76.9620);
  static const LatLng destination = LatLng(8.5755, 76.9580);
  static const LatLng source = LatLng(8.5743, 76.9668);

  Position? _currentPosition;
  GoogleMapController? _mapController;
  LatLng? _center;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinatesSrcToDest = [];

  double calculateBearingAngle(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    double startLat = startLatitude * (math.pi / 180.0);
    double startLng = startLongitude * (math.pi / 180.0);
    double endLat = endLatitude * (math.pi / 180.0);
    double endLng = endLongitude * (math.pi / 180.0);

    double deltaLng = endLng - startLng;

    double y = math.sin(deltaLng) * math.cos(endLat);
    double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(deltaLng);

    double bearing = math.atan2(y, x);

    // Convert the bearing angle to degrees
    double bearingDegrees = bearing * (180.0 / math.pi);

    return (bearingDegrees + 360) % 360;
  }

  void getPolyPoints(_center) async {
    PolylinePoints polylinePoints = PolylinePoints();
    print("##################################");
    PolylineResult locationToSource =
        await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDE-V3UMnD4OK8SG2S-wzOUGlBF-PlJH_Y", // Your Google Map Key
      PointLatLng(_center.latitude, _center.longitude),
      PointLatLng(source.latitude, source.longitude),
    );
    if (locationToSource.points.isNotEmpty) {
      locationToSource.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }

    PolylineResult sourceToDestination =
        await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDE-V3UMnD4OK8SG2S-wzOUGlBF-PlJH_Y", // Your Google Map Key
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (sourceToDestination.points.isNotEmpty) {
      sourceToDestination.points.forEach(
        (PointLatLng point) => polylineCoordinatesSrcToDest.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }

    // Calculate the bearing angle between the current location and the destination
    double bearingAngle = calculateBearingAngle(
      _center.latitude,
      _center.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Rotate the map camera to adjust the polyline towards the top of the image
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _center!,
          zoom: 15.0,
          bearing: bearingAngle,
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void setCustomMarkerIcon() async {
    final Uint8List riderIconBytes =
        await getBytesFromAsset('assets/images/bike.png', 90);
    final Uint8List sourceIconBytes =
        await getBytesFromAsset('assets/images/source.png', 90);
    final Uint8List destinationIconBytes =
        await getBytesFromAsset('assets/images/destination.png', 90);
    currentLocationIcon = BitmapDescriptor.fromBytes(riderIconBytes);
    sourceIcon = BitmapDescriptor.fromBytes(sourceIconBytes);
    destinationIcon = BitmapDescriptor.fromBytes(destinationIconBytes);
  }

  @override
  void initState() {
    setCustomMarkerIcon();
    super.initState();
    // Load custom marker icon

    _determinePosition().then((position) async {
      setState(() {
        _currentPosition = position;
        // print("lat long");
        _center =
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _center!,
              zoom: 15.0,
            ),
          ),
        );
        getPolyPoints(_center);
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          onTap: (LatLng location) {
            setState(() {
              // _center = location;
            });
          },
          markers: _center != null
              ? {
                  // Marker(
                  //   markerId: const MarkerId("pin"),
                  //   position: _center!,
                  // ),
                  Marker(
                    markerId: const MarkerId("source"),
                    position: source,
                    icon: sourceIcon,
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    position: destination,
                    icon: destinationIcon,
                  ),
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    position: _center!,
                    icon: currentLocationIcon,
                  ),
                }
              : {},
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: _center ?? const LatLng(0, 0),
            zoom: 15,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: ui.Color.fromARGB(255, 13, 8, 39),
              width: 6,
              // Set polyline rotation to align with the image
              geodesic: true,
            ),
            Polyline(
              polylineId: const PolylineId("route1"),
              points: polylineCoordinatesSrcToDest,
              color: ui.Color.fromARGB(255, 82, 139, 16),
              width: 6,
            ),
          },
        ),
      ],
    );
  }
}
