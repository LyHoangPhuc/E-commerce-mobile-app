import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/viewed_products.dart';

//lóp này quản lý trạng thái của các sản phẩm đã xem
class ViewedProdProvider with ChangeNotifier {
  final Map<String, ViewedProdModel> _viewedProdItems = {};

  Map<String, ViewedProdModel> get getViewedProds {
    return _viewedProdItems; //trả về danh sách các sản phẩm đã xem
  }

//hàm này sẽ thêm sản phẩm đã xem vào danh sách
  void addViewedProd({required String productId}) {
    _viewedProdItems.putIfAbsent(
      //kiểm tra xem sản phẩm đã có trong danh sách chưa
      productId,
      () => ViewedProdModel(
          //nếu chưa thì thêm vào danh sách
          viewedProdId: const Uuid().v4(),
          productId: productId),
    );

    notifyListeners(); //thông báo cho các widget khác biết rằng danh sách đã thay đổi
  }

  void clearLocalViewedProdItems() {
    _viewedProdItems.clear(); //xóa danh sách yêu thích
    notifyListeners(); //thông báo cho các widget khác biết rằng danh sách đã thay đổi
  }
}
