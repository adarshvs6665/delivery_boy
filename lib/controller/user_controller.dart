import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final storage = GetStorage();
  var user = {}.obs;
  var acceptedFlag = false.obs;
  var deliveryDetails = {}.obs;

  @override
  void onInit() {
    super.onInit();
    // Retrieve stored user details from GetStorage on initialization
    final userData = storage.read('deliveryBoyUser');
    final acceptedFlagData = storage.read('acceptedFlag');
    final deliveryDetailsData = storage.read('deliveryDetails');

    if (userData != null) {
      user.value = userData;
    }

    if (acceptedFlagData != null) {
      acceptedFlag.value = acceptedFlagData;
    }

    if (deliveryDetailsData != null) {
      deliveryDetails.value = deliveryDetailsData;
    }
  }

  void setUser(Map<String, dynamic> userData) {
    user.value = userData;
    // Save user details in GetStorage
    storage.write('deliveryBoyUser', userData);
  }

  void setDeliveryDetails(Map<String, dynamic> deliveryDetailsData) {
    deliveryDetails.value = deliveryDetailsData;
    // Save user details in GetStorage
    storage.write('deliveryDetails', deliveryDetailsData);
  }

  void setAcceptedFlag(bool acceptedFlagData) {
    acceptedFlag.value = acceptedFlagData;
    // Save user details in GetStorage
    storage.write('acceptedFlag', acceptedFlagData);
  }

  void clearUserDetails() {
    user.value = {};

    // Remove user details from GetStorage
    storage.remove('deliveryBoyUser');
  }
}
