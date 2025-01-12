import 'package:flutter/material.dart';

//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến các sản phẩm đã xem,
//bao gồm id của sản phẩm đã xem và id của sản phẩm.
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class ViewedProdModel with ChangeNotifier {
  final String viewedProdId;
  final String productId;

  ViewedProdModel({
    required this.viewedProdId,
    required this.productId,
  });
}
