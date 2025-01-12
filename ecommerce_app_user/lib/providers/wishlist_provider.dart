import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecommerce_app_user/models/wishlist_model.dart';
import 'package:uuid/uuid.dart';

import '../services/my_app_functions.dart';

//lớp này sẽ quản lý trạng thái của các sản phẩm yêu thích
class WishlistProvider with ChangeNotifier {
  final Map<String, WishlistModel> _wishlistItems = {};
  Map<String, WishlistModel> get getWishlists {
    return _wishlistItems; //trả về danh sách các sản phẩm yêu thích
  }

  final userstDb = FirebaseFirestore.instance
      .collection("users"); //tham chiếu đến bộ sưu tập "users" trong Firestore
  final _auth = FirebaseAuth
      .instance; //tham chiếu đến Firebase Authentication để xác thực người dùng
// Firebase
//hàm này sẽ thêm sản phẩm vào danh sách yêu thích trong Firestore
  Future<void> addToWishlistFirebase({
    required String productId,
    required BuildContext context,
  }) async {
    final User? user = _auth
        .currentUser; //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    if (user == null) {
      //nếu không có người dùng nào đăng nhập
      MyAppFunctions.showErrorOrWarningDialog(
        //hiển thị thông báo lỗi
        context: context,
        subtitle: "Please login first",
        fct: () {},
      );
      return;
    } //nếu có người dùng đăng nhập
    final uid = user.uid; //lấy id của người dùng
    final wishlistId = const Uuid().v4(); //tạo id cho danh sách yêu thích
    try {
      await userstDb.doc(uid).update({
        //cập nhật dữ liệu vào Firestore
        'userWish': FieldValue.arrayUnion([
          //thêm sản phẩm vào danh sách yêu thích
          {
            'wishlistId': wishlistId,
            'productId': productId,
          }
        ])
      });

      Fluttertoast.showToast(msg: "Item has been added"); //hiển thị thông báo
    } catch (e) {
      rethrow;
    }
  }

//hàm này sẽ lấy danh sách các sản phẩm yêu thích từ Firestore
  Future<void> fetchWishlist() async {
    final User? user = _auth
        .currentUser; //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    if (user == null) {
      //nếu không có người dùng nào đăng nhập
      _wishlistItems.clear(); //xóa danh sách yêu thích
      return;
    } //nếu có người dùng đăng nhập
    try {
      final userDoc = await userstDb
          .doc(user.uid)
          .get(); //lấy dữ liệu người dùng từ Firestore
      final data = userDoc.data(); //lấy dữ liệu từ userDoc
      if (data == null || !data.containsKey('userWish')) {
        //nếu không có dữ liệu hoặc không có danh sách yêu thích
        return; //thoát khỏi hàm
      }
      final leng = userDoc
          .get("userWish")
          .length; //lấy số lượng sản phẩm trong danh sách yêu thích
      for (int index = 0; index < leng; index++) {
        //duyệt qua từng sản phẩm trong danh sách yêu thích
        _wishlistItems.putIfAbsent(
            //thêm sản phẩm vào danh sách yêu thích
            userDoc.get("userWish")[index]['productId'], //lấy id của sản phẩm
            () => WishlistModel(
                  wishlistId: userDoc.get("userWish")[index]
                      ['wishlistId'], //lấy id của danh sách yêu thích
                  productId: userDoc.get("userWish")[index]
                      ['productId'], //lấy id của sản phẩm
                ));
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

//hàm này sẽ xóa sản phẩm khỏi danh sách yêu thích trong Firestore
  Future<void> removeWishlistItemFromFirestore({
    required String wishlistId,
    required String productId,
  }) async {
    final User? user = _auth
        .currentUser; //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    try {
      await userstDb.doc(user!.uid).update({
        //cập nhật dữ liệu vào Firestore
        'userWish': FieldValue.arrayRemove([
          //Sử dụng arrayRemove để xóa một đối tượng khỏi trường userWish
          {
            'wishlistId': wishlistId,
            'productId': productId,
          }
        ])
      });
      _wishlistItems.remove(productId); //xóa sản phẩm khỏi danh sách yêu thích
      Fluttertoast.showToast(msg: "Item has been removed");
    } catch (e) {
      rethrow;
    }
  }

//hàm này sẽ xóa toàn bộ danh sách yêu thích trong Firestore
  Future<void> clearWishlistFromFirebase() async {
    final User? user = _auth
        .currentUser; //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    try {
      await userstDb.doc(user!.uid).update({
        //cập nhật dữ liệu vào Firestore
        'userWish': [],
      });
      _wishlistItems.clear(); //xóa danh sách yêu thích
      Fluttertoast.showToast(msg: "Wishlist has been cleared");
    } catch (e) {
      rethrow;
    }
  }

// Local
//hàm này sẽ thêm sản phẩm vào danh sách yêu thích
  void addOrRemoveFromWishlist({required String productId}) {
    if (_wishlistItems.containsKey(productId)) {
      //kiểm tra xem sản phẩm đã có trong danh sách chưa
      _wishlistItems.remove(productId); //nếu có thì xóa sản phẩm khỏi danh sách
    } else {
      //nếu chưa có thì thêm vào danh sách
      _wishlistItems.putIfAbsent(
        //thêm sản phẩm vào danh sách yêu thích
        productId,
        () =>
            WishlistModel(wishlistId: const Uuid().v4(), productId: productId),
      );
    }

    notifyListeners(); //thông báo cho các widget khác biết rằng danh sách đã thay đổi
  }

//hàm này sẽ kiểm tra xem sản phẩm đã có trong danh sách yêu thích chưa
  bool isProdinWishlist({required String productId}) {
    return _wishlistItems.containsKey(
        productId); //trả về true nếu sản phẩm đã có trong danh sách
  }

//hàm này sẽ xóa sản phẩm khỏi danh sách yêu thích
  void clearLocalWishlist() {
    _wishlistItems.clear(); //xóa danh sách yêu thích
    notifyListeners(); //thông báo cho các widget khác biết rằng danh sách đã thay đổi
  }
}
