import 'package:flutter/material.dart';

//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến các mục trong giỏ hàng,
//bao gồm id của giỏ hàng, id của sản phẩm và số lượng sản phẩm trong giỏ hàng.
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class CartModel with ChangeNotifier {
  final String cartId;
  final String productId;
  final int quantity;

  CartModel({
    required this.cartId,
    required this.productId,
    required this.quantity,
  });
}
