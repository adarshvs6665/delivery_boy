import 'package:delivery_boy/model/base_model.dart';
import 'package:delivery_boy/model/delivery_partner_model.dart';
import 'package:delivery_boy/model/location_model.dart';

class Order {
  final String orderId;
  final BaseModel item; // Add variable of type BaseModel
  final String status;
  final DeliveryPartnerModel? deliveryPartner; // Make it nullable
  final Location deliveryLocation; // Remove nullability

  Order({
    required this.orderId,
    required this.item,
    required this.status,
    this.deliveryPartner, // Update the parameter
    required this.deliveryLocation, // Remove nullability
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'item': item.toJson(),
        'status': status,
        'deliveryPartner': deliveryPartner
            ?.toJson(), // Accessing toJson only if deliveryPartner is not null
        'deliveryLocation': deliveryLocation.toJson(),
      };
}
