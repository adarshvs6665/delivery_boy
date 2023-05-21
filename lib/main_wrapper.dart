import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/screens/login.dart';
import 'package:delivery_boy/screens/order_details.dart';
import 'package:delivery_boy/widget/reuseable_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../screens/cart.dart';
import '../screens/home.dart';
import '../screens/new_map.dart';
import '../utils/constants.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

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

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    Widget appbarTitle;

    // final userController = Get.find<UserController>();

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
      bodyWidget = Column(
        children: [
          Expanded(
            child: MapWidget(isOrderActive: true),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 550),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: ReuseableButton(
                text: "Delivered",
                onTap: () {
                  // if (itemsOnCartDev.isNotEmpty) {
                  //   Get.offAll(() => ConfirmLocation(data: itemsOnCartDev));
                  // }
                },
              ),
            ),
          )
        ],
      );
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
                LineIcons.shoppingBag,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Get.to(() => Cart());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.grey,
                size: 30,
              ),
              onPressed: () {
                // userController.clearUserDetails();
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
          // BottomBarItem(iconData: Icons.settings),
          // BottomBarItem(iconData: Icons.explore),
          // BottomBarItem(iconData: Icons.mail),
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
