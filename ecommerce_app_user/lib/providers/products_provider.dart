import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

//lớp này quản lý trạng thái liên quan đến sản phẩm
class ProductsProvider with ChangeNotifier {
  List<ProductModel> products = [];
  List<ProductModel> get getProducts {
    return products;
  }

//phương thức này chịu trách nhiệm tìm sản phẩm theo ID sản phẩm từ danh sách sản phẩm cục bộ
  ProductModel? findByProdId(String productId) {
    if (products.where((element) => element.productId == productId).isEmpty) {
      // isEmpty: trả về true nếu danh sách không chứa phần tử nào
      return null;
    }
    return products.firstWhere((element) =>
        element.productId ==
        productId); // firstWhere: trả về phần tử đầu tiên thỏa
  }

//phương thức này chịu trách nhiệm tìm sản phẩm theo danh mục từ danh sách sản phẩm cục bộ
  List<ProductModel> findByCategory({required String categoryName}) {
    List<ProductModel> categoryList =
        products // where: trả về danh sách các phần tử thỏa
            .where(
              (element) => element.productCategory.toLowerCase().contains(
                    // contains: trả về true nếu chuỗi chứa chuỗi con
                    categoryName
                        .toLowerCase(), // toLowerCase: chuyển chuỗi thành chữ thường
                  ),
            )
            .toList();
    return categoryList;
  }

//phương thức này chịu trách nhiệm tìm sản phẩm theo tên sản phẩm từ danh sách sản phẩm cục bộ
  List<ProductModel> searchQuery(
      {required String searchText, required List<ProductModel> passedList}) {
    List<ProductModel> searchList = passedList
        .where(
          (element) => element.productTitle.toLowerCase().contains(
                searchText.toLowerCase(),
              ),
        )
        .toList();
    return searchList;
  }

//phương thức này chịu trách nhiệm lấy danh sách sản phẩm từ Firestore một lần và cập nhật danh sách sản phẩm cục bộ
//Phù hợp với các tình huống cần lấy dữ liệu sản phẩm một lần, chẳng hạn như trong quá trình tải ban đầu hoặc làm mới thủ công
  final productDb = FirebaseFirestore.instance.collection("products");
  Future<List<ProductModel>> fetchProducts() async {
    try {
      // get: lấy dữ liệu từ Firestore
      await productDb
          .orderBy('createdAt',
              descending: false) // orderBy: sắp xếp dữ liệu theo trường cụ thể
          .get() // sau đó, lấy dữ liệu từ Firestore
          .then((productSnapshot) {
        // sau đó, lưu trữ dữ liệu vào danh sách sản phẩm
        products.clear(); // xóa dữ liệu cũ
        // products = []
        for (var element in productSnapshot.docs) {
          // lặp qua từng phần tử trong danh sách dữ liệu
          products.insert(
              0,
              ProductModel.fromFirestore(
                  element)); // thêm dữ liệu vào danh sách sản phẩm
        }
      });
      notifyListeners(); // thông báo cho người nghe rằng trạng thái đã thay đổi
      return products;
    } catch (e) {
      rethrow;
    }
  }

//Phương thức fetchProductsStream cho phép lắng nghe các bản cập nhật theo thời gian thực từ Firestore và cập nhật danh sách sản phẩm cục bộ
//Phù hợp với các tình huống cần giữ dữ liệu sản phẩm được đồng bộ hóa với Firestore theo thời gian thực, chẳng hạn như hiển thị các bản cập nhật trực tiếp trong UI.
  Stream<List<ProductModel>> fetchProductsStream() {
    try {
      return productDb.snapshots().map((snapshot) {
        // snapshots: trả về Stream (luồng) của dữ liệu
        products.clear(); // xóa dữ liệu cũ
        // products = []
        for (var element in snapshot.docs) {
          products.insert(0, ProductModel.fromFirestore(element));
        }
        return products;
      });
    } catch (e) {
      rethrow;
    }
  }
}
