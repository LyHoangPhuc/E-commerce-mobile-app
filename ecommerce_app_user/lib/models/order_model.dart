import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến các mục trong đơn hàng,
//bao gồm id của đơn hàng, id của người dùng, id của sản phẩm, tên sản phẩm, tên người dùng, giá, hình ảnh, số lượng và ngày đặt hàng.
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class OrdersModelAdvanced with ChangeNotifier {
  final String orderId;
  final String userId;
  final String productId;
  final String productTitle;
  final String userName;
  final String price;
  final String imageUrl;
  final String quantity;
  final Timestamp orderDate;

  OrdersModelAdvanced(
      {required this.orderId,
      required this.userId,
      required this.productId,
      required this.productTitle,
      required this.userName,
      required this.price,
      required this.imageUrl,
      required this.quantity,
      required this.orderDate});
}
