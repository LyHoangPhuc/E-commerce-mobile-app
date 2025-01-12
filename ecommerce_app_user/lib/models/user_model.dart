import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến người dùng,
//bao gồm id của người dùng, tên người dùng, hình ảnh người dùng, email người dùng, giỏ hàng của người dùng, danh sách yêu thích của người dùng và ngày tạo tài kho
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class UserModel with ChangeNotifier {
  final String userId, userName, userImage, userEmail;
  final Timestamp createdAt;
  final List userCart, userWish;
  UserModel({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.userEmail,
    required this.userCart,
    required this.userWish,
    required this.createdAt,
  });
}
