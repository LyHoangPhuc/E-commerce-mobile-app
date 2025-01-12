import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm dòng này
import 'package:ecommerce_app_user/models/order_model.dart';
import 'package:ecommerce_app_user/providers/order_provider.dart'; // Thêm dòng này
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';

class OrdersWidgetFree extends StatefulWidget {
  const OrdersWidgetFree({super.key, required this.ordersModelAdvanced});
  final OrdersModelAdvanced ordersModelAdvanced;
  @override
  State<OrdersWidgetFree> createState() => _OrdersWidgetFreeState();
}

class _OrdersWidgetFreeState extends State<OrdersWidgetFree> {
  bool isLoading = false;

  Future<void> _deleteOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Hiển thị dialog xác nhận
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa đơn hàng này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        // Gọi hàm xóa từ Provider
        await Provider.of<OrderProvider>(context, listen: false).deleteOrder(
          widget.ordersModelAdvanced.orderId,
          widget.ordersModelAdvanced.productId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa đơn hàng thành công'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa đơn hàng: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FancyShimmerImage(
              height: size.width * 0.25,
              width: size.width * 0.25,
              imageUrl: widget.ordersModelAdvanced.imageUrl,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TitlesTextWidget(
                          label: widget.ordersModelAdvanced.productTitle,
                          maxLines: 2,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : _deleteOrder,
                        icon: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 22,
                              ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const TitlesTextWidget(
                        label: 'Giá:  ',
                        fontSize: 15,
                      ),
                      Flexible(
                        child: SubtitleTextWidget(
                          label:
                              "${MyAppFunctions.formatPrice(double.parse(widget.ordersModelAdvanced.price))} VND",
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SubtitleTextWidget(
                    label: "Số lượng:${widget.ordersModelAdvanced.quantity}",
                    fontSize: 15,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
