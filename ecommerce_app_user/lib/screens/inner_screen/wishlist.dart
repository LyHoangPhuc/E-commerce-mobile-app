import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:ecommerce_app_user/widgets/products/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_user/providers/wishlist_provider.dart';
import 'package:ecommerce_app_user/services/assets_manager.dart';
import 'package:ecommerce_app_user/widgets/empty_bag.dart';
import 'package:ecommerce_app_user/widgets/title_text.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = "/WishlistScreen";
  const WishlistScreen({super.key});
  final bool isEmpty = true;
  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return wishlistProvider.getWishlists.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.bagWish,
              title: "Chưa có gì trong danh sách ước của bạn",
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
                      "Danh sách ước (${wishlistProvider.getWishlists.length})"),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      subtitle: "Xóa danh sách mong muốn?",
                      fct: () async {
                        await wishlistProvider.clearWishlistFromFirebase();
                        wishlistProvider.clearLocalWishlist();
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
                    productId: wishlistProvider.getWishlists.values
                        .toList()[index]
                        .productId,
                  ),
                );
              },
              itemCount: wishlistProvider.getWishlists.length,
              crossAxisCount: 2,
            ),
          );
  }
}
