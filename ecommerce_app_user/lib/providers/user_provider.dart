import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_user/models/user_model.dart';

//lớp này quản lý trạng thái người dùng
class UserProvider with ChangeNotifier {
  UserModel? userModel;
  UserModel? get getUserModel {
    return userModel;
  }

// phương thức này chịu trách nhiệm lấy thông tin người dùng từ cơ sở dữ liệu
  Future<UserModel?> fetchUserInfo() async {
    final auth = FirebaseAuth
        .instance; // tham chiếu đến Firebase Authentication dùng để xác thực người dùng
    User? user = auth.currentUser; // lấy thông tin người dùng hiện tại
    if (user == null) {
      // kiểm tra xem người dùng có tồn tại không
      return null; // nếu không tồn tại thì trả về null
    }
    String uid = user.uid; // lấy id của người dùng
    try {
      final userDoc = // lấy dữ liệu người dùng từ cơ sở dữ liệu
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      final userDocDict =
          userDoc.data(); // chuyển dữ liệu người dùng thành dạng từ điển
      userModel = UserModel(
        // khởi tạo đối tượng UserModel từ dữ liệu người dùng
        userId: userDoc.get("userId"), // lấy id người dùng
        userName: userDoc.get("userName"), // lấy tên người dùng
        userImage: userDoc.get("userImage"), // lấy ảnh người dùng
        userEmail: userDoc.get('userEmail'), // lấy email người dùng
        userCart: // lấy giỏ hàng người dùng
            userDocDict!.containsKey("userCart") ? userDoc.get("userCart") : [],
        userWish: // lấy danh sách yêu thích người dùng
            userDocDict.containsKey("userWish") ? userDoc.get("userWish") : [],
        createdAt: userDoc.get('createdAt'), // lấy thời gian tạo người dùng
      );
      return userModel; // trả về thông tin người dùng
    } on FirebaseException {
      // bắt lỗi từ Firebase
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
