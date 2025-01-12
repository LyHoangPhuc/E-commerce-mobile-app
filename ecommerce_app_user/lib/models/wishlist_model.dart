import 'package:flutter/material.dart';

//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến danh sách yêu thích,
//bao gồm id của danh sách yêu thích và id của sản phẩm.
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class WishlistModel with ChangeNotifier {
  final String wishlistId;
  final String productId;

  WishlistModel({
    required this.wishlistId,
    required this.productId,
  });
}
