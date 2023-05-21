import 'package:delivery_boy/model/delivery_partner_model.dart';
import '../model/base_model.dart';

class CartModel {
  final String cartId;
  final BaseModel item;

  CartModel({required this.cartId, required this.item});

  Map<String, dynamic> toJson() => {'cartId': cartId, 'item': item.toJson()};
}
