import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_admin/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrdersModelAdvanced> orders = [];
  bool _isLoading = false;

  List<OrdersModelAdvanced> get getOrders => orders;
  bool get isLoading => _isLoading;

  String _buildFullAddress(Map<String, dynamic> shippingAddress) {
    return '${shippingAddress['streetAddress']}, '
        '${shippingAddress['wardName']}, '
        '${shippingAddress['districtName']}, '
        '${shippingAddress['provinceName']}';
  }

  Future<List<OrdersModelAdvanced>> fetchOrder() async {
    try {
      _isLoading = true;
      notifyListeners();

      final orderSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .orderBy("orderDate", descending: true)
          .get();

      orders.clear();

      for (var doc in orderSnapshot.docs) {
        final items = doc.get('items') as List<dynamic>;
        final userId = doc.get('userId') as String;
        final orderId = doc.get('orderId') as String;
        final orderDate = doc.get('orderDate') as Timestamp;
        final status = doc.get('status') as String;
        final paymentMethod = doc.get('paymentMethod') as String;
        final shippingAddress =
            doc.get('shippingAddress') as Map<String, dynamic>;

        final fullAddress = _buildFullAddress(shippingAddress);
        final phoneNumber = shippingAddress['phoneNumber'] as String;

        for (var item in items) {
          orders.add(
            OrdersModelAdvanced(
              orderId: orderId,
              userId: userId,
              productId: item['productId'],
              price: item['price'].toString(),
              productTitle: item['productTitle'],
              quantity: item['quantity'].toString(),
              imageUrl: item['productImage'],
              phoneNumber: phoneNumber,
              fullAddress: fullAddress,
              status: status,
              paymentMethod: paymentMethod,
              orderDate: orderDate,
            ),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return orders;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print('Error in fetchOrder: $error');
      rethrow;
    }
  }
}
