import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final storage = GetStorage();
  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    // Retrieve stored user details from GetStorage on initialization
    final userData = storage.read('user');
    if (userData != null) {
      user.value = userData;
    }
  }

  void setUser(Map<String, dynamic> userData) {
    user.value = userData;
    // Save user details in GetStorage
    storage.write('user', userData);
  }

  void clearUserDetails() {
    user.value = {};

    // Remove user details from GetStorage
    storage.remove('user');
  }
}
