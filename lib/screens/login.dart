import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/main_wrapper.dart';
import 'package:delivery_boy/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_boy/screens/signup.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Future<void> loginUser() async {
    final userController = Get.find<UserController>();

    final email = emailController.text;
    final password = passwordController.text;

    const url = '$baseUrl/delivery-boy-login'; // Replace with your API endpoint

    try {
      final headers = {'Content-Type': 'application/json'};
      final payload = jsonEncode({
        'email': email,
        'password': password,
      });
      final response =
          await http.post(Uri.parse(url), headers: headers, body: payload);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // API call successful
        final userData = responseData['data'];
        // Store user info using GetX
        userController.setUser(userData);

        // Navigate to another page
        Get.to(const MainWrapper(givenIndex: 0));
      } else {
        // Handle API error
        final responseMessage = responseData['message'];
        Fluttertoast.showToast(
            msg: responseMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 6.0);
      }
    } catch (e) {
      // Handle network error
      print('Network Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Welcome,",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Delivery partner sign in...",
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade400),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email ID",
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      "Forgot Password ?",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                      height: 50,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          loginUser();
                          // Get.to(const MainWrapper());
                        },
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.all(0)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xffff5f6d)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xffff5f6d),
                                Color(0xffff5f6d),
                                Color(0xffffc371),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: double.infinity, minHeight: 50),
                            alignment: Alignment.center,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  // Container(
                  //     height: 50,
                  //     width: double.infinity,
                  //     child: TextButton(
                  //       onPressed: () {
                  //         // Action to perform when the button is pressed
                  //       },
                  //       style: ButtonStyle(
                  //         backgroundColor: MaterialStateProperty.all<Color>(
                  //             Colors.indigo.shade50),
                  //         shape:
                  //             MaterialStateProperty.all<RoundedRectangleBorder>(
                  //           RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(6),
                  //           ),
                  //         ),
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: <Widget>[
                  //           Image.asset(
                  //             "images/facebook.png",
                  //             height: 18,
                  //             width: 18,
                  //           ),
                  //           SizedBox(
                  //             width: 10,
                  //           ),
                  //           Text(
                  //             "Connect with Facebook",
                  //             style: TextStyle(
                  //               color: Colors.indigo,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     )),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "I'm a new user.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SignupPage());
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
