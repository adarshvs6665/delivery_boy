import 'package:delivery_boy/model/base_model.dart';
import 'package:delivery_boy/model/delivery_partner_model.dart';
import 'package:delivery_boy/model/location_model.dart';

class Order {
  final String orderId;
  final BaseModel item; // Add variable of type BaseModel
  final String status;
  final Location deliveryLocation; // Remove nullability
  final bool accepted;
  final String acceptedPumpId;
  final Location pickupLocation;
  final bool acceptedByMe;

  Order({
    required this.orderId,
    required this.item,
    required this.status,
    required this.deliveryLocation,
    required this.accepted,
    required this.acceptedPumpId,
    required this.pickupLocation,
    required this.acceptedByMe,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'item': item.toJson(),
        'status': status,
        'deliveryLocation': deliveryLocation.toJson(),
        'accepted': accepted,
        'acceptedPumpId': acceptedPumpId,
        'pickupLocation': pickupLocation.toJson(),
        'acceptedByMe': acceptedByMe
      };
}
