import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrdersModelAdvanced with ChangeNotifier {
  final String orderId;
  final String userId;
  final String productId;
  final String productTitle;
  final String price;
  final String imageUrl;
  final String quantity;
  final String phoneNumber;
  final String fullAddress;
  final String status;
  final String paymentMethod;
  final Timestamp orderDate;

  OrdersModelAdvanced({
    required this.orderId,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.phoneNumber,
    required this.fullAddress,
    required this.status,
    required this.paymentMethod,
    required this.orderDate,
  });
}
