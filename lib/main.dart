import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delivery_boy/controller/user_controller.dart';
import 'package:delivery_boy/screens/login.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/app_theme.dart';
import 'main_wrapper.dart';

void main() async {
  await GetStorage.init();
  Get.put<UserController>(UserController());

  final userController = Get.find<UserController>();
  final deliveryBoyId = userController.user.value['deliveryBoyId'];

  Widget initialPage;

  if (deliveryBoyId != null) {
    initialPage = const MainWrapper(givenIndex: 1);
  } else {
    initialPage = LoginPage();
  }

  runApp(
    GetMaterialApp(
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      home: initialPage,
      // home: const MainWrapper(),
    ),
  );
}
