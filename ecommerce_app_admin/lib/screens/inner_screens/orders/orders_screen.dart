import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_admin/providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../../widgets/title_text.dart';
import 'orders_widget.dart';

class OrdersScreenFree extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrdersScreenFree({super.key});

  @override
  State<OrdersScreenFree> createState() => _OrdersScreenFreeState();
}

class _OrdersScreenFreeState extends State<OrdersScreenFree> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      Future.microtask(() {
        Provider.of<OrderProvider>(context, listen: false).fetchOrder();
      });
    }
    super.didChangeDependencies();
  }

  Future<void> _refreshOrders() async {
    await Provider.of<OrderProvider>(context, listen: false).fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(
          label: 'Đơn đặt hàng',
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (orderProvider.getOrders.isEmpty) {
            return const Center(
              child: Text('Chưa có đơn hàng nào'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.separated(
              itemCount: orderProvider.getOrders.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: OrdersWidgetFree(
                    ordersModelAdvanced: orderProvider.getOrders[index],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          );
        },
      ),
    );
  }
}
