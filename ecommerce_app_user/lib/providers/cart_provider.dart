import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecommerce_app_user/models/cart_model.dart';
import 'package:ecommerce_app_user/providers/products_provider.dart';
import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

//lớp này Quản lý trạng thái của giỏ hàng bằng provider
class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartitems {
    return _cartItems; //_cartItems: Một Map lưu trữ các sản phẩm trong giỏ hàng
  }

  final userstDb = FirebaseFirestore.instance.collection(
      "users"); //userstDb: Tham chiếu đến bộ sưu tập "users" trong Firestore,
  final _auth = FirebaseAuth
      .instance; //_auth: Tham chiếu đến Firebase Authentication để xác thực người dùng.

//các phương thức Firebase
//Chức năng: Thêm một sản phẩm vào giỏ hàng của người dùng trong Firestore.
  Future<void> addToCartFirebase({
    required String productId,
    required int qty,
    required BuildContext context,
  }) async {
    final User? user = _auth
        .currentUser; //đầu tiên, kiểm tra xác thực xem người dùng đã đăng nhập chưa.
    if (user == null) {
      // Nếu chưa, hiển thị thông báo yêu cầu đăng nhập.
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please login first",
        fct: () {},
      );
      return;
    }
    final uid = user.uid; //Nếu người dùng đã đăng nhập, lấy uid của người dùng.
    final cartId =
        const Uuid().v4(); //Tạo một cartId mới bằng cách sử dụng Uuid().v4().
    try {
      await userstDb.doc(uid).update({
        //Sau đó, cập nhật trường userCart của người dùng trong Firestore bằng cách thêm một mục mới.//
        'userCart': FieldValue.arrayUnion([
          //sử dụng FieldValue.arrayUnion để thêm sản phẩm vào trường userCart trong Firestore.
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      await fetchCart(); //Sau khi thêm sản phẩm vào giỏ hàng của người dùng trong Firestore, gọi phương thức fetchCart để cập nhật trạng thái cục bộ.
      Fluttertoast.showToast(
          msg:
              "Item has been added"); //Hiển thị thông báo Toast để thông báo rằng sản phẩm đã được thêm vào giỏ hàng.
    } catch (e) {
      rethrow;
    }
  }

//Chức năng: Lấy dữ liệu giỏ hàng từ Firestore và cập nhật giỏ hàng cục bộ.
  Future<void> fetchCart() async {
    final User? user = _auth
        .currentUser; //đầu tiên, kiểm tra xem người dùng đã đăng nhập chưa.
    if (user == null) {
      //Nếu chưa, xóa tất cả các mục khỏi giỏ hàng cục bộ và trả về.
      _cartItems.clear();
      return;
    }
    try {
      //Nếu người dùng đã đăng nhập, lấy dữ liệu giỏ hàng của người dùng từ Firestore.
      final userDoc = await userstDb
          .doc(user.uid)
          .get(); //Lấy tài liệu người dùng từ Firestore bằng cách sử dụng uid của người dùng.
      final data = userDoc.data(); //Lấy dữ liệu từ tài liệu người dùng.
      if (data == null || !data.containsKey('userCart')) {
        //Kiểm tra xem trường userCart có tồn tại trong tài liệu người dùng không.
        return; //Nếu không, xóa tất cả các mục khỏi giỏ hàng cục bộ và trả về.
      }
      final leng = userDoc
          .get("userCart")
          .length; //Nếu có, lấy độ dài của trường userCart.
      for (int index = 0; index < leng; index++) {
        //Sau đó, lặp qua từng mục trong trường userCart và cập nhật trạng thái cục bộ bằng cách thêm mục vào _cartItems map.
        _cartItems.putIfAbsent(
          //Sử dụng phương thức putIfAbsent để thêm mục vào _cartItems map.
          userDoc.get("userCart")[index]['productId'],
          () => CartModel(
              //Đối số đầu tiên là productId của mục, đối số thứ hai là một hàm lambda trả về một đối tượng CartModel.
              cartId: userDoc.get("userCart")[index]['cartId'],
              productId: userDoc.get("userCart")[index]['productId'],
              quantity: userDoc.get("userCart")[index]['quantity']),
        );
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners(); //Cuối cùng, gọi phương thức notifyListeners để thông báo cho người nghe về sự thay đổi trong giỏ hàng.
  }

//Chức năng: Xóa một sản phẩm khỏi giỏ hàng trong Firestore.
  Future<void> removeCartItemFromFirestore({
    required String cartId,
    required String productId,
    required int qty,
  }) async {
    final User? user = _auth
        .currentUser; //đầu tiên, kiểm tra xác thực xem người dùng đã đăng nhập chưa.
    try {
      await userstDb.doc(user!.uid).update({
        //Nếu người dùng đã đăng nhập, cập nhật trường userCart của người dùng trong Firestore bằng cách xóa một mục.
        'userCart': FieldValue.arrayRemove([
          //sử dụng FieldValue.arrayRemove để xóa sản phẩm khỏi trường userCart trong Firestore.
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      // await fetchCart();
      _cartItems.remove(
          productId); //Sau khi xóa sản phẩm khỏi giỏ hàng của người dùng trong Firestore, xóa sản phẩm khỏi giỏ hàng cục bộ.
      Fluttertoast.showToast(
          msg:
              "Item has been removed"); //Hiển thị thông báo Toast để thông báo rằng sản phẩm đã được xóa khỏi giỏ hàng.
    } catch (e) {
      rethrow;
    }
  }

//Chức năng: Xóa tất cả các mục trong giỏ hàng của người dùng trong Firestore.
  Future<void> clearCartFromFirebase() async {
    final User? user = _auth
        .currentUser; //đầu tiên, kiểm tra xác thực xem người dùng đã đăng nhập chưa.
    try {
      await userstDb.doc(user!.uid).update({
        //Nếu người dùng đã đăng nhập, cập nhật trường userCart của người dùng trong Firestore bằng cách xóa tất cả các mục.
        'userCart': [],
      });
      // await fetchCart();
      _cartItems.clear();
      Fluttertoast.showToast(
          msg:
              "Cart has been cleared"); //Sau khi xóa tất cả các mục khỏi giỏ hàng của người dùng trong Firestore, xóa tất cả các mục khỏi giỏ hàng cục bộ.
    } catch (e) {
      rethrow;
    }
  }

// Các phương thức cục bộ
  //  Chức năng: Thêm một sản phẩm vào giỏ hàng cục bộ.
  void addProductToCart({required String productId}) {
    _cartItems.putIfAbsent(
      //Sử dụng phương thức putIfAbsent để thêm một sản phẩm vào giỏ hàng cục bộ.
      productId,
      () => CartModel(
          cartId: const Uuid().v4(), productId: productId, quantity: 1),
    );
    notifyListeners(); //gọi phương thức notifyListeners để thông báo cho người nghe về sự thay đổi trong giỏ hàng.
  }

  //Chức năng: Cập nhật số lượng của một sản phẩm trong giỏ hàng cục bộ.
  void updateQty({required String productId, required int qty}) {
    _cartItems.update(
      productId,
      (cartItem) => CartModel(
        cartId: cartItem.cartId,
        productId: productId,
        quantity: qty,
      ),
    );
    notifyListeners(); //gọi phương thức notifyListeners để thông báo cho người nghe về sự thay đổi trong giỏ hàng.
  }

  //Chức năng: Kiểm tra xem một sản phẩm có trong giỏ hàng cục bộ hay không
  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(
        productId); //Sử dụng phương thức containsKey để kiểm tra xem một sản phẩm có trong giỏ hàng cục bộ hay không.
  }

  //Chức năng: Tính tổng giá trị của tất cả các sản phẩm trong giỏ hàng cục bộ bằng cách lấy giá từ ProductsProvider.
  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      //Lặp qua từng mục trong giỏ hàng cục bộ và tính tổng giá trị của tất cả các sản phẩm.
      final getCurrProduct = productsProvider.findByProdId(value
          .productId); //Đầu tiên, lấy sản phẩm hiện tại từ ProductsProvider bằng cách sử dụng productId.
      if (getCurrProduct == null) {
        //Kiểm tra xem sản phẩm hiện tại có tồn tại không.
        total += 0; //Nếu không tồn tại, thêm 0 vào tổng giá trị.
      } else {
        //Nếu tồn tại, thêm giá của sản phẩm hiện tại nhân với số lượng vào tổng giá trị.
        total += double.parse(getCurrProduct.productPrice) *
            value
                .quantity; //Sử dụng phương thức double.parse để chuyển đổi giá từ String sang double.
      }
    });
    return total; //Cuối cùng, trả về tổng giá trị của tất cả các sản phẩm trong giỏ hàng cục bộ.
  }

  //Chức năng: Lấy tổng số lượng của tất cả các sản phẩm trong giỏ hàng cục bộ.
  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      //Lặp qua từng mục trong giỏ hàng cục bộ và tính tổng số lượng của tất cả các sản phẩm.
      total += value.quantity;
    });
    return total;
  }

  //Chức năng: Xóa tất cả các sản phẩm khỏi giỏ hàng cục bộ.
  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners(); //gọi phương thức notifyListeners để thông báo cho người nghe về sự thay đổi trong giỏ hàng.
  }

  //Chức năng: Xóa một sản phẩm cụ thể khỏi giỏ hàng cục bộ.
  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners(); //gọi phương thức notifyListeners để thông báo cho người nghe về sự thay đổi trong giỏ hàng.
  }
}
