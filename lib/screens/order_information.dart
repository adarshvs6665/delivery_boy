import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:delivery_boy/main_wrapper.dart';
import 'package:delivery_boy/model/orders_model.dart';
import 'package:delivery_boy/screens/order_details.dart';
import 'package:delivery_boy/utils/constants.dart';
import 'package:delivery_boy/widget/reuseable_button.dart';
import 'package:delivery_boy/widget/reuseable_row_for_cart.dart';
import 'package:delivery_boy/widget/reuseable_text%20.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;

import '../controller/user_controller.dart';

class OrderInformation extends StatefulWidget {
  final Order order;

  const OrderInformation({Key? key, required this.order}) : super(key: key);

  @override
  _OrderInformationState createState() => _OrderInformationState();
}

class _OrderInformationState extends State<OrderInformation> {
  // List<Order> orders = [];

  String responseBody = '';

  @override
  void initState() {
    super.initState();
  }

  void acceptOrder(String orderId) async {
    String url = '${baseUrl}/delivery-boy-accept-order';
    final headers = {'Content-Type': 'application/json'};
    final userController = Get.find<UserController>();
    final deliveryBoyId = userController.user.value['deliveryBoyId'];
    final location = await Geolocator.getCurrentPosition();
    final payload = jsonEncode({
      "data": {
        "deliveryBoyId": deliveryBoyId,
        "orderId": orderId,
        "deliveryPartnerLocation": {
          "latitude": location.latitude,
          "longitude": location.longitude
        },
        "deliveryTime": "30 mins",
      }
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: payload);

    if(response.statusCode == 200) {
      Get.to(MainWrapper(givenIndex: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    Order order = widget.order;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Order Information",
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
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1.4,
                    child: Image.asset(
                      order.item.imageUrl,
                      // height: 200,
                      width: 100,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        width: size.width,
                        height: size.height * 0.36,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1.0),
                            child: Column(
                              children: [
                                FadeInUp(
                                  delay: const Duration(milliseconds: 350),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.item.name,
                                        style: textTheme.displaySmall
                                            ?.copyWith(fontSize: 16),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_sharp,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: Text(
                                    'Integer vitae arcu et eros lacinia interdumInteger vitae arcu et eros lacinia interdumInteger vitae arcu et eros lacinia interdum. ',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 450),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Status",
                                            style: textTheme.headline5
                                                ?.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 16)),
                                        Text(
                                          order.status,
                                          style: TextStyle(
                                            color: () {
                                              if (order.status == "PENDING") {
                                                return Colors
                                                    .orange; // Set color to red for PENDING status
                                              } else if (order.status ==
                                                  "DELIVERY") {
                                                return Colors
                                                    .blue; // Set color to blue for PROCESSING status
                                              } else if (order.status ==
                                                  "COMPLETED") {
                                                return Colors
                                                    .green; // Set color to black for other statuses
                                              }
                                            }(),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Quantity",
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 16)),
                                        ReuseableTextComponent(
                                          inputText: order.item.quantity,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: ReuseableRowForCart(
                                    price: order.item.price,
                                    text: 'Sub Total',
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Contact",
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 16)),
                                        ReuseableTextComponent(
                                          inputText:
                                              order.userContact,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order id",
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 16)),
                                        ReuseableTextComponent(
                                          inputText:
                                              order.orderId.substring(0, 20),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (order.status == "DELIVERY" && !order.acceptedByMe) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 550),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: ReuseableButton(
                        text: "Accept Order",
                        onTap: () {
                          acceptOrder(order.orderId);
                        }),
                  ),
                )
              ]
            ],
          )),
    );
  }
}
