import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:ecommerce_app_user/providers/viewed_recently_provider.dart';
import 'package:ecommerce_app_user/widgets/products/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_user/services/assets_manager.dart';
import 'package:ecommerce_app_user/widgets/empty_bag.dart';
import 'package:ecommerce_app_user/widgets/title_text.dart';

import '../../services/my_app_functions.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen({super.key});
  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return viewedProdProvider.getViewedProds.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.orderBag,
              title: "Chưa có sản phẩm nào được xem",
              subtitle:
                  "Có vẻ như giỏ hàng của bạn đang trống, hãy thêm thứ gì đó và làm tôi vui nhé",
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AssetsManager.shoppingCart,
                ),
              ),
              title: TitlesTextWidget(
                  label:
                      "Đã xem gần đây (${viewedProdProvider.getViewedProds.length})"),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      subtitle: "Xóa?",
                      fct: () {
                        viewedProdProvider.clearLocalViewedProdItems();
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: DynamicHeightGridView(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              builder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductWidget(
                      productId: viewedProdProvider.getViewedProds.values
                          .toList()[index]
                          .productId),
                );
              },
              itemCount: viewedProdProvider.getViewedProds.length,
              crossAxisCount: 2,
            ),
          );
  }
}
