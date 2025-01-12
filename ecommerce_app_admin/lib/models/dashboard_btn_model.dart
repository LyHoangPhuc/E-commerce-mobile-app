import 'package:flutter/material.dart';
import 'package:ecommerce_app_admin/screens/edit_upload_product_form.dart';
import 'package:ecommerce_app_admin/screens/inner_screens/orders/orders_screen.dart';
import 'package:ecommerce_app_admin/screens/search_screen.dart';

import '../services/assets_manager.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(BuildContext context) => [
        DashboardButtonsModel(
          text: "Thêm sản phẩm mới",
          imagePath: AssetsManager.cloud,
          onPressed: () {
            Navigator.pushNamed(
              context,
              EditOrUploadProductScreen.routeName,
            );
          },
        ),
        DashboardButtonsModel(
          text: "Kiểm tra tất cả các sản phẩm",
          imagePath: AssetsManager.shoppingCart,
          onPressed: () {
            Navigator.pushNamed(
              context,
              SearchScreen.routeName,
            );
          },
        ),
        DashboardButtonsModel(
          text: "Xem đơn hàng",
          imagePath: AssetsManager.order,
          onPressed: () {
            Navigator.pushNamed(
              context,
              OrdersScreenFree.routeName,
            );
          },
        ),
      ];
}
