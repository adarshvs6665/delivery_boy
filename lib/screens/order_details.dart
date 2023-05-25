import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/model/base_model.dart';
import 'package:delivery_boy/model/delivery_partner_model.dart';
import 'package:delivery_boy/model/location_model.dart';
import 'package:delivery_boy/model/orders_model.dart';
import 'package:delivery_boy/screens/order_information.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  List<Order> orders = [];
  bool acceptedFlagLocal = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<Order> parseOrders(List<dynamic> json) {
    return json.map((order) {
      final orderId = order['orderId'] as String;
      final itemJson = order['item'] as Map<String, dynamic>;
      final status = order['status'] as String;
      final deliveryLocationJson =
          order['deliveryLocation'] as Map<String, dynamic>;
      final pickupLocationJson =
          order['pickupLocation'] as Map<String, dynamic>;
      final accepted = order['accepted'] as bool;
      final acceptedByMe = order['acceptedByMe'] as bool;
      final acceptedPumpId = order['acceptedPumpId'] as String;

      final item = BaseModel.fromJson(itemJson);
      final deliveryLocation = Location.fromJson(deliveryLocationJson);
      final pickupLocation = Location.fromJson(pickupLocationJson);

      if (acceptedByMe) {
        final userController = Get.find<UserController>();
        userController.setDeliveryDetails({
          "deliveryLocation": deliveryLocation,
          "pickupLocation": pickupLocation,
          "orderId": orderId,
        });
      }

      return Order(
        orderId: orderId,
        item: item,
        status: status,
        deliveryLocation: deliveryLocation,
        accepted: accepted,
        acceptedPumpId: acceptedPumpId,
        pickupLocation: pickupLocation,
        acceptedByMe: acceptedByMe,
      );
    }).toList();
  }

  Future<void> fetchData() async {
    final userController = Get.find<UserController>();
    final userId = userController.user.value['deliveryBoyId'];
    final queryParameters = {'deliveryBoyId': userId};

    String url = '${baseUrl}/fetch-delivery-orders';
    final response = await http
        .get(Uri.parse(url).replace(queryParameters: queryParameters));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<Order> orders = parseOrders(responseData['data']);
      setState(() {
        this.orders = orders;
      });
      userController.setAcceptedFlag(responseData['acceptedFlag']);
      setState(() {
        acceptedFlagLocal = userController.acceptedFlag.value;
      });
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orders.length > 0
          ? ListView.builder(
              itemCount: orders.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      print("acceptedFlagLocal");
                      print(acceptedFlagLocal);
                      if (acceptedFlagLocal) {
                        if (orders[index].acceptedByMe) {
                          Get.to(() => OrderInformation(order: orders[index]));
                        }
                      } else if (!acceptedFlagLocal) {
                        Get.to(() => OrderInformation(order: orders[index]));
                      }
                    },
                    child: Card(
                      color: orders[index].acceptedByMe
                          ? Color.fromARGB(255, 255, 153, 0)
                          : Color.fromARGB(255, 223, 223, 223),
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: Image.asset(orders[index].item.imageUrl),
                        title: Text(orders[index].item.name,
                            style: orders[index].acceptedByMe
                                ? const TextStyle(color: Colors.white)
                                : TextStyle(color: Colors.black)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (orders[index].status == "PENDING") ...[
                              const Text('Delivery Time: Not available')
                            ] else if (orders[index].status == "DELIVERY") ...[
                              Text(
                                  'Delivery Location: ${orders[index].deliveryLocation.latitude}, ${orders[index].deliveryLocation.longitude}',
                                  style: orders[index].acceptedByMe
                                      ? const TextStyle(color: Colors.white)
                                      : TextStyle(color: Colors.black)),
                              Text(
                                  'Pickup Location: ${orders[index].pickupLocation.latitude}, ${orders[index].pickupLocation.longitude}',
                                  style: orders[index].acceptedByMe
                                      ? const TextStyle(color: Colors.white)
                                      : TextStyle(color: Colors.black))
                            ],
                            Text('Price: ${orders[index].item.price}',
                                style: orders[index].acceptedByMe
                                    ? const TextStyle(color: Colors.white)
                                    : TextStyle(color: Colors.black)),
                            Text('Payment mode: COD',
                                style: orders[index].acceptedByMe
                                    ? const TextStyle(color: Colors.white)
                                    : TextStyle(color: Colors.black)),
                          ],
                        ),
                        trailing: () {
                          if (orders[index].status == "PENDING") {
                            return const Icon(
                              Icons.watch_later,
                              color: Colors.orange,
                            );
                          } else if (orders[index].status == "DELIVERY") {
                            return const Icon(
                              Icons.share_location,
                              color: Colors.blue,
                            );
                          } else if (orders[index].status == "COMPLETED") {
                            return const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            );
                          }
                        }(),
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.thumb_down_rounded,
                  color: Colors.orange,
                  size: 80.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'No orders!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
    );
  }
}
