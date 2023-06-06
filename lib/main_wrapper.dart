import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/screens/login.dart';
import 'package:delivery_boy/screens/order_details.dart';
import 'package:delivery_boy/widget/reuseable_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../screens/new_map.dart';
import '../utils/constants.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key, required this.givenIndex});

  final int givenIndex;
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _index = 0;
  bool isOrdersActive = false;

  List<Widget> screens = [
    MapWidget(isOrderActive: true),
    const OrderDetails(),
  ];

  void completeOrder(String orderId) async {
    String url = '${baseUrl}/delivery-boy-complete-order';
    final headers = {'Content-Type': 'application/json'};
    final userController = Get.find<UserController>();
    final payload = jsonEncode({
      "data": {
        "orderId": orderId,
      }
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: payload);

    if (response.statusCode == 200) {
      setState(() {
        _index = 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _index = widget.givenIndex;
    });
  if(widget.givenIndex == 1) {
    setState(() {
      isOrdersActive = true;
    });
  }

  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    Widget appbarTitle;

    final userController = Get.find<UserController>();
    var acceptedFlagLocal = userController.acceptedFlag.value;

    if (isOrdersActive) {
      bodyWidget = const OrderDetails();
      appbarTitle = FadeIn(
        delay: const Duration(milliseconds: 300),
        child: const Text(
          "Orders",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      );
    } else {
      bodyWidget = acceptedFlagLocal
          ? Column(
              children: [
                Expanded(child: MapWidget(isOrderActive: true)),
                if (acceptedFlagLocal) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 550),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: ReuseableButton(
                        text: "Deliver Order",
                        onTap: () {
                          completeOrder(
                              userController.deliveryDetails.value['orderId']);
                        },
                      ),
                    ),
                  )
                ]
              ],
            )
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.arrow_circle_right_rounded,
                  color: Colors.orange,
                  size: 80.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Accept an order first!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ));
      appbarTitle = FadeIn(
        delay: const Duration(milliseconds: 300),
        child: const Text(
          "Home",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: appbarTitle,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
            size: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.grey,
                size: 30,
              ),
              onPressed: () {
                userController.clearUserDetails();
                Get.to(LoginPage());
              },
            ),
          ),
        ],
      ),
      body: bodyWidget,
      bottomNavigationBar: BottomBarBubble(
        color: primaryColor,
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          BottomBarItem(iconData: Icons.list_alt),
        ],
        onSelect: (index) {
          if (index == 0) {
            setState(() {
              isOrdersActive = false;
              _index = 0;
            });
          } else if (index == 1) {
            setState(() {
              isOrdersActive = true;
              _index = 1;
            });
          }
        },
      ),
    );
  }
}
