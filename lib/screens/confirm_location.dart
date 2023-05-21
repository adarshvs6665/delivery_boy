import 'dart:convert';
import 'package:delivery_boy/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:delivery_boy/model/cart_model.dart';
import 'package:delivery_boy/screens/order_success.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geolocator/geolocator.dart';
import '../widget/reuseable_button.dart';

class ConfirmLocation extends StatefulWidget {
  const ConfirmLocation({required this.data, super.key});

  final List<CartModel> data;

  @override
  State<ConfirmLocation> createState() => _ConfirmLocationState();
}

class _ConfirmLocationState extends State<ConfirmLocation> {
  Position? _currentPosition;
  GoogleMapController? _mapController;
  LatLng? _center;
  double lat = 33;
  double long = -122;
  List<CartModel> orderData = [];

  @override
  void initState() {
    super.initState();

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
      });
    }).catchError((e) {
      print(e);
    });
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final data = widget.data;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                  width: size.width,
                  height: size.height * 0.6,
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      FadeInUp(
                        child: SizedBox(
                          height: 400,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GoogleMap(
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _mapController = controller;
                                  },
                                  onTap: (LatLng location) {
                                    setState(() {
                                      _center = location;
                                    });
                                  },
                                  markers: _center != null
                                      ? {
                                          Marker(
                                            markerId: const MarkerId("pin"),
                                            position: _center!,
                                          ),
                                        }
                                      : {},
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: _center ?? const LatLng(0, 0),
                                    zoom: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                    ],
                  )),
            ),

            /// Bottom Card
            Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height * 0.36,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 1.0),
                  child: Column(
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 550),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: ReuseableButton(
                            text: "Place Order",
                            onTap: () {
                              Get.to(() => OrderSuccessPage(
                                  position: _currentPosition!, data: data));
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Confirm Location",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            LineIcons.user,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
