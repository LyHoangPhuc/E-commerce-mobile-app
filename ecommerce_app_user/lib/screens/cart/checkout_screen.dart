// checkout_screen.dart
import 'package:ecommerce_app_user/screens/inner_screen/orders/orders_screen.dart';
import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../inner_screen/address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selectedAddress;
  String selectedPaymentMethod = 'COD'; // Mặc định là COD
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load địa chỉ khi vào màn hình
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addressProvider = context.read<AddressProvider>();
    await addressProvider.fetchAddresses();
    if (addressProvider.addresses.isNotEmpty) {
      setState(() {
        selectedAddress = addressProvider.addresses.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần địa chỉ giao hàng
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Địa chỉ giao hàng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                      context, AddressListScreen.routeName);
                                  _loadAddresses();
                                },
                                child: const Text('Thay đổi'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (selectedAddress != null) ...[
                            Text(selectedAddress!.streetAddress),
                            Text(
                              '${selectedAddress!.wardName}, ${selectedAddress!.districtName}, ${selectedAddress!.provinceName}',
                            ),
                            Text('SĐT: ${selectedAddress!.phoneNumber}'),
                          ] else
                            const Text('Vui lòng chọn địa chỉ giao hàng'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phần phương thức thanh toán
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phương thức thanh toán',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RadioListTile<String>(
                            title: const Text('Thanh toán khi nhận hàng (COD)'),
                            value: 'COD',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Chuyển khoản ngân hàng'),
                            value: 'BANK',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phần tổng tiền
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng cộng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tổng tiền hàng:'),
                              Text(
                                '${MyAppFunctions.formatPrice(cartProvider.getTotal(productsProvider: productsProvider))}VND',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: Colors.grey),
          ),
        ),
        child: ElevatedButton(
          onPressed:
              selectedAddress == null ? null : () => _processCheckout(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Đặt hàng'),
        ),
      ),
    );
  }

  Future<void> _processCheckout(BuildContext context) async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        throw Exception('Vui lòng đăng nhập để tiếp tục');
      }

      final orderId = const Uuid().v4();
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'orderDate': Timestamp.now(),
        'status': 'pending',
        'paymentMethod': selectedPaymentMethod,
        'totalAmount':
            cartProvider.getTotal(productsProvider: productsProvider),
        'shippingAddress': selectedAddress!.toMap(),
        'items': cartProvider.getCartitems.values.map((item) {
          final product = productsProvider.findByProdId(item.productId);
          return {
            'productId': item.productId,
            'quantity': item.quantity,
            'price': double.parse(product!.productPrice),
            'productTitle': product.productTitle,
            'productImage': product.productImage,
          };
        }).toList(),
      };

      // Lưu đơn hàng vào Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      // Xóa giỏ hàng
      await cartProvider.clearCartFromFirebase();

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công')),
        );
        // Đợi một chút để Firestore cập nhật
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context)
              .pushReplacementNamed(OrdersScreenFree.routeName);
        }
        // Thay vì pop hết, chỉ pop về màn hình orders
        Navigator.of(context).pushReplacementNamed(OrdersScreenFree.routeName);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
