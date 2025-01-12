import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_user/models/order_model.dart';

// lớp này quản lý trạng thái liên quan đến đơn hàng, bao gồm việc lấy đơn hàng từ Firestore và lưu trữ chúng trong danh sách cục bộ
class OrderProvider with ChangeNotifier {
  final List<OrdersModelAdvanced> orders = [];
  bool _isLoading = false;

  List<OrdersModelAdvanced> get getOrders => orders;
  bool get isLoading => _isLoading;

  Future<List<OrdersModelAdvanced>> fetchOrder() async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      final orderSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('userId', isEqualTo: user.uid)
          .orderBy("orderDate", descending: true)
          .get();

      orders.clear();
      for (var doc in orderSnapshot.docs) {
        final items = doc.get('items') as List<dynamic>;
        for (var item in items) {
          orders.add(
            OrdersModelAdvanced(
              orderId: doc.get('orderId'),
              userId: doc.get('userId'),
              productId: item['productId'],
              price: item['price'].toString(),
              productTitle: item['productTitle'],
              quantity: item['quantity'].toString(),
              imageUrl: item['productImage'],
              userName: user.displayName ?? '',
              orderDate: doc.get('orderDate'),
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
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId, String productId) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Lấy reference đến document cần xóa
      final orderDoc = await FirebaseFirestore.instance
          .collection("orders")
          .where('orderId', isEqualTo: orderId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (orderDoc.docs.isEmpty) {
        throw Exception("Order not found");
      }

      final doc = orderDoc.docs.first;
      List<dynamic> items = List.from(doc.get('items'));

      // Nếu order có nhiều sản phẩm, chỉ xóa sản phẩm được chọn
      if (items.length > 1) {
        items.removeWhere((item) => item['productId'] == productId);
        await doc.reference.update({'items': items});

        // Xóa khỏi local state
        orders.removeWhere((order) =>
            order.orderId == orderId && order.productId == productId);
      } else {
        // Nếu là sản phẩm cuối cùng trong order, xóa cả document
        await doc.reference.delete();

        // Xóa khỏi local state
        orders.removeWhere((order) => order.orderId == orderId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
