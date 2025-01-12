import 'package:ecommerce_app_admin/services/my_app_method.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_admin/models/order_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FancyShimmerImage(
                    height: size.width * 0.25,
                    width: size.width * 0.25,
                    imageUrl: widget.ordersModelAdvanced.imageUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.ordersModelAdvanced.status == 'pending'
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.ordersModelAdvanced.status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const TitlesTextWidget(
                            label: 'Giá: ',
                            fontSize: 15,
                          ),
                          Flexible(
                            child: SubtitleTextWidget(
                              label: "${MyAppMethods.formatPrice(
                                double.parse(
                                  widget.ordersModelAdvanced.price,
                                ),
                              )} VND",
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      SubtitleTextWidget(
                        label:
                            "Số lượng: ${widget.ordersModelAdvanced.quantity}",
                        fontSize: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubtitleTextWidget(
                  label: "SĐT: ${widget.ordersModelAdvanced.phoneNumber}",
                  fontSize: 15,
                ),
                const SizedBox(height: 5),
                SubtitleTextWidget(
                  label: "Địa chỉ: ${widget.ordersModelAdvanced.fullAddress}",
                  fontSize: 15,
                ),
                const SizedBox(height: 5),
                SubtitleTextWidget(
                  label:
                      "Thanh toán: ${widget.ordersModelAdvanced.paymentMethod}",
                  fontSize: 15,
                ),
                const SizedBox(height: 5),
                SubtitleTextWidget(
                  label: "Ngày đặt: ${MyAppMethods.formatDate(
                    widget.ordersModelAdvanced.orderDate.toDate(),
                  )}",
                  fontSize: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
