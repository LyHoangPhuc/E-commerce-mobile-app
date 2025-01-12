import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import 'address_selection_screen.dart';

class AddressListScreen extends StatefulWidget {
  static const String routeName = '/address';
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AddressProvider>().fetchAddresses();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ của tôi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AddressProvider>(
              builder: (context, addressProvider, child) {
                final addresses = addressProvider.addresses;

                if (addresses.isEmpty) {
                  return const Center(
                    child: Text('Chưa có địa chỉ nào'),
                  );
                }

                return ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return AddressCard(
                      address: address,
                      onEdit: () => _navigateToEditAddress(context, address),
                      onDelete: () => _showDeleteDialog(context, address.id!),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddressSelectionScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddAddress(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressSelectionScreen(),
      ),
    );
  }

  Future<void> _navigateToEditAddress(
      BuildContext context, Address address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionScreen(initialAddress: address),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        // Sử dụng addressId thay vì address.id!
        context.read<AddressProvider>().removeAddress(addressId);
      }
    }
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.streetAddress,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${address.wardName}, ${address.districtName}, ${address.provinceName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'SĐT: ${address.phoneNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Sửa'),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
