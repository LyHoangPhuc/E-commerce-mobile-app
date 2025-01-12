import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_user/widgets/subtitle_text.dart';
import 'package:ecommerce_app_user/widgets/title_text.dart';

import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import 'checkout_screen.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget({super.key, required this.function});
  final Function function;
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                        child: TitlesTextWidget(
                            label:
                                "Tổng (${cartProvider.getCartitems.length} sản phẩm/${cartProvider.getQty()} cái)")),
                    SubtitleTextWidget(
                      label:
                          "${MyAppFunctions.formatPrice(cartProvider.getTotal(productsProvider: productsProvider))}VND", // loại bỏ phần thập phân nếu là số nguyên
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, CheckoutScreen.routeName);
                },
                child: const Text("Thanh toán"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
