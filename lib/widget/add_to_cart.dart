import 'dart:convert';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:advance_notification/advance_notification.dart';
import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../model/base_model.dart';
import '../utils/constants.dart';

class AddToCart {
  // Future<void> fetchData() async {
  //   String url = '${baseUrl}/cart';
  //   final headers = {'Content-Type': 'application/json'};
  //   final payload =
  //       jsonEncode({'username': 'john_doe', 'password': 'my_password'});
  //   final response =
  //       await http.post(Uri.parse(url), headers: headers, body: payload);
  //   if (response.statusCode == 200) {
  //     print("printing");
  //     print(response.body);
  //     // final data = jsonDecode(response.body) as List<dynamic>;
  //     // final orders = data
  //     //     .map((json) => Order(
  //     //           name: json['name'],
  //     //           deliveryTime: json['deliveryTime'],
  //     //           price: json['price'].toDouble(),
  //     //           image: json['image'],
  //     //           completed: json['completed'],
  //     //           quantity: json['quantity'],
  //     //         ))
  //     //     .toList();
  //     // setState(() {

  //     // });
  //   } else {
  //     throw Exception('Failed to post to card');
  //   }
  // }

  static void addToCart(BaseModel data, BuildContext context) async {
    final userController = Get.find<UserController>();
    final userId = userController.user.value['userId'];

    String url = '$baseUrl/cart';
    final headers = {'Content-Type': 'application/json'};
    final payload = jsonEncode({"userId": userId, "data": data.toJson()});
    final response =
        await http.post(Uri.parse(url), headers: headers, body: payload);
    final responseBodyJSON = json.decode(response.body);
    String message = responseBodyJSON["message"];
    if (response.statusCode == 200) {
      // itemsOnCart.add(data);

      // ignore: use_build_context_synchronously
      AdvanceSnackBar(
        textSize: 14.0,
        message: message,
        mode: Mode.ADVANCE,
        duration: const Duration(seconds: 5),
      ).show(context);
    } else {
      // ignore: use_build_context_synchronously
      AdvanceSnackBar(
        textSize: 14.0,
        bgColor: Colors.red,
        message: message,
        mode: Mode.ADVANCE,
        duration: const Duration(seconds: 5),
      ).show(context);
    }
    // }
  }
}
