import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/model/cart_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_boy/screens/confirm_location.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../widget/reuseable_row_for_cart.dart';
import '../main_wrapper.dart';
import '../model/base_model.dart';
import '../utils/constants.dart';
import '../widget/reuseable_button.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<CartModel> itemsOnCartDev = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userController = Get.find<UserController>();
    final userId = userController.user.value['userId'];
    final queryParameters = {'userId': userId};
    String url = '${baseUrl}/cart';
    final response = await http
        .get(Uri.parse(url).replace(queryParameters: queryParameters));
    if (response.statusCode == 200) {
      // print("printing");
      // print(response.body);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final data = responseData['data'] as List<dynamic>;
      // print(responseData['status']);
      // print(data);
      final List<CartModel> cartData = data.map((json) {
        final item = BaseModel(
          id: json['item']['id'] as int,
          imageUrl: json['item']['imageUrl'] as String,
          name: json['item']['name'] as String,
          price: (json['item']['price'] as num).toDouble(),
          review: (json['item']['review'] as num).toDouble(),
          star: (json['item']['star'] as num).toDouble(),
          value: json['item']['value'] as int,
          quantity: json['item']['quantity'] as String,
        );
        return CartModel(
          cartId: json['cartId'] as String,
          item: item,
        );
      }).toList();

      setState(() {
        itemsOnCartDev = cartData;
      });
    } else {
      throw Exception('Failed to post to card');
    }
  }

  Future<void> removeCartItem(String cartId) async {
    String url = '${baseUrl}/delivery-boy-accept-order';
    final headers = {'Content-Type': 'application/json'};
    final payload = jsonEncode({
      "data": {"cartId": cartId}
    });
    final response =
        await http.delete(Uri.parse(url), headers: headers, body: payload);
    if (response.statusCode == 200) {
      print("printing");
      // print(response.body);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to remove cart');
    }
  }

  /// Calculate the Total Price
  double calculateTotalPrice() {
    double total = 0.0;
    if (itemsOnCartDev.isEmpty) {
      total = 0;
    } else {
      for (CartModel data in itemsOnCartDev) {
        total = total + data.item.price * data.item.value;
      }
    }
    total = total + itemsOnCartDev.length * deliveryCostForSingleItem;
    return total;
  }

  /// Calculate Shipping
  double calculateShipping() {
    double shipping = 0;
    if (itemsOnCartDev.isEmpty) {
      shipping = 0;
      return shipping;
    } else {
      shipping = (itemsOnCartDev.length * deliveryCostForSingleItem).toDouble();
      return shipping;
    }
  }

  /// Calculate the Sub Total Price
  double calculateSubTotalPrice() {
    double subTotal = 0;
    if (itemsOnCartDev.isEmpty) {
      subTotal = 0;
    } else {
      for (CartModel data in itemsOnCartDev) {
        subTotal = subTotal + data.item.price;
        print(subTotal);
        // subTotal = subTotal - 160;
      }
    }
    return subTotal < 0 ? 0 : subTotal;
  }

  /// delete function for cart
  void onDelete(CartModel data) {
    removeCartItem(data.cartId);
    setState(() {
      if (itemsOnCartDev.length == 1) {
        itemsOnCartDev.clear();
      } else {
        itemsOnCartDev.removeWhere((element) {
          return element.cartId == data.cartId;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

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
                child: itemsOnCartDev.isEmpty

                    /// List is Empty:
                    ? Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: const Image(
                              image: AssetImage("assets/images/empty.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 250),
                            child: const Text(
                              "Your cart is empty right now :(",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: IconButton(
                              onPressed: () {
                                Get.offAll(MainWrapper());
                              },
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )

                    /// List is Not Empty:
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: itemsOnCartDev.length,
                        itemBuilder: (context, index) {
                          var current = itemsOnCartDev[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index + 80),
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              width: size.width,
                              height: size.height * 0.26,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0, 4),
                                          blurRadius: 4,
                                          color: Color.fromARGB(61, 0, 0, 0),
                                        )
                                      ],
                                      color: Colors.pink,
                                      image: DecorationImage(
                                          image:
                                              AssetImage(current.item.imageUrl),
                                          fit: BoxFit.cover),
                                    ),
                                    width: size.width * 0.4,
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.52,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                current.item.name,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    onDelete(current);
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.grey,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        RichText(
                                            text: TextSpan(
                                                text: "€",
                                                style: textTheme.subtitle2
                                                    ?.copyWith(
                                                  fontSize: 22,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [
                                              TextSpan(
                                                text: current.item.price
                                                    .toString(),
                                                style: textTheme.subtitle2
                                                    ?.copyWith(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            ])),
                                        SizedBox(
                                          height: size.height * 0.04,
                                        ),
                                        Text(
                                          "Quantity ${current..item.quantity}",
                                          style: textTheme.subtitle2?.copyWith(
                                            fontSize: 15,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: size.height * 0.058,
                                          ),
                                          width: size.width * 0.4,
                                          height: size.height * 0.04,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                width: size.width * 0.065,
                                                height: size.height * 0.045,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  onTap: () {
                                                    // setState(() {
                                                    //   if (current.value > 1) {
                                                    //     current.value--;
                                                    //   } else {
                                                    //     onDelete(current);
                                                    //     current.value = 1;
                                                    //   }
                                                    // });
                                                  },
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.02),
                                                child: Text(
                                                  current.item.value.toString(),
                                                  style: textTheme.subtitle2
                                                      ?.copyWith(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                width: size.width * 0.065,
                                                height: size.height * 0.045,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  onTap: () {
                                                    // setState(() {
                                                    //   current.value >= 0
                                                    //       ? current.value++
                                                    //       : null;
                                                    // });
                                                  },
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
              ),
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
                        delay: const Duration(milliseconds: 400),
                        child: ReuseableRowForCart(
                          price: calculateSubTotalPrice().toDouble(),
                          text: 'Sub Total',
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 450),
                        child: ReuseableRowForCart(
                          price: calculateShipping(),
                          text: 'Delivery',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: ReuseableRowForCart(
                          price: double.parse(
                              calculateTotalPrice().toStringAsFixed(2)),
                          text: 'Total',
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 550),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: ReuseableButton(
                            text: "Checkout",
                            onTap: () {
                              if (itemsOnCartDev.isNotEmpty) {
                                Get.offAll(() =>
                                    ConfirmLocation(data: itemsOnCartDev));
                              }
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
        "My Cart",
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
