import 'package:delivery_boy/model/location_model.dart';

class DeliveryPartnerModel {
  final String deliveryPartnerId;
  final String deliveryTime;
  final String deliveryPartnerMobileNumber;
  Location deliveryPartnerLocation;

  DeliveryPartnerModel({
    required this.deliveryPartnerId,
    required this.deliveryTime,
    required this.deliveryPartnerMobileNumber,
    required this.deliveryPartnerLocation,
  });

  factory DeliveryPartnerModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerModel(
      deliveryPartnerId: json['deliveryPartnerId'] as String,
      deliveryTime: json['deliveryTime'] as String,
      deliveryPartnerMobileNumber:
          json['deliveryPartnerMobileNumber'] as String,
      deliveryPartnerLocation: Location.fromJson(
          json['deliveryPartnerLocation'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'deliveryPartnerId': deliveryPartnerId,
        'deliveryTime': deliveryTime,
        'deliveryPartnerMobileNumber': deliveryPartnerMobileNumber,
        'deliveryPartnerLocation': deliveryPartnerLocation.toJson()
      };
}
