import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../services/address_service.dart';

class AddressSelectionScreen extends StatefulWidget {
  final Address? initialAddress;

  const AddressSelectionScreen({super.key, this.initialAddress});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();

  String? _selectedProvinceCode;
  String? _selectedDistrictCode;
  String? _selectedWardCode;

  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _addressService.loadAddressData();

    // Load provinces first
    setState(() {
      _provinces =
          List<Map<String, dynamic>>.from(_addressService.getProvinces());
    });

    if (widget.initialAddress != null) {
      // Set initial values
      setState(() {
        _selectedProvinceCode = widget.initialAddress!.provinceCode;
        _streetController.text = widget.initialAddress!.streetAddress;
        _phoneController.text = widget.initialAddress!.phoneNumber;
      });

      // Load districts based on selected province
      if (_selectedProvinceCode != null) {
        _onProvinceChanged(_selectedProvinceCode!);

        // Wait for districts to be loaded
        await Future.delayed(Duration(milliseconds: 100));

        _selectedDistrictCode = widget.initialAddress!.districtCode;
        _onDistrictChanged(_selectedDistrictCode!);

        // Wait for wards to be loaded
        await Future.delayed(Duration(milliseconds: 100));

        setState(() {
          _selectedWardCode = widget.initialAddress!.wardCode;
        });
      }
    }
  }

  void _onProvinceChanged(String provinceCode) {
    setState(() {
      _selectedProvinceCode = provinceCode;
      _districts = List<Map<String, dynamic>>.from(
          _addressService.getDistricts(provinceCode));
      _selectedDistrictCode = null;
      _selectedWardCode = null;
      _wards = [];
    });
  }

  void _onDistrictChanged(String districtCode) {
    setState(() {
      _selectedDistrictCode = districtCode;
      _wards = List<Map<String, dynamic>>.from(
          _addressService.getWards(_selectedProvinceCode!, districtCode));
      _selectedWardCode = null;
    });
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final province =
        _provinces.firstWhere((p) => p['Code'] == _selectedProvinceCode);
    final district =
        _districts.firstWhere((d) => d['Code'] == _selectedDistrictCode);
    final ward = _wards.firstWhere((w) => w['Code'] == _selectedWardCode);

    final address = Address(
      id: widget.initialAddress?.id,
      provinceCode: _selectedProvinceCode!,
      provinceName: province['Name'].toString(),
      districtCode: _selectedDistrictCode!,
      districtName: district['Name'].toString(),
      wardCode: _selectedWardCode!,
      wardName: ward['Name'].toString(),
      streetAddress: _streetController.text,
      phoneNumber: _phoneController.text,
    );

    try {
      if (widget.initialAddress != null) {
        await context.read<AddressProvider>().updateAddress(address);
      } else {
        await context.read<AddressProvider>().addAddress(address);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialAddress != null ? 'Sửa địa chỉ' : 'Thêm địa chỉ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProvinceCode,
              decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
              items: _provinces
                  .map((province) {
                    // Kiểm tra null safety
                    return DropdownMenuItem<String>(
                      value:
                          province['Code']?.toString() ?? '', // Thêm null check
                      child: Text(province['Name']?.toString() ??
                          ''), // Thêm null check
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(), // Lọc bỏ các item null
              onChanged: (value) {
                if (value != null) _onProvinceChanged(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn Tỉnh/Thành phố';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Quận/Huyện dropdown
            DropdownButtonFormField<String>(
              value: _selectedDistrictCode,
              decoration: const InputDecoration(
                labelText: 'Quận/Huyện',
                border: OutlineInputBorder(),
              ),
              items: _districts
                  .map((district) {
                    return DropdownMenuItem<String>(
                      value: district['Code']?.toString() ?? '',
                      child: Text(district['Name']?.toString() ?? ''),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _onDistrictChanged(value); // Gọi hàm này thay vì chỉ setState
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn Quận/Huyện';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedWardCode,
              decoration: const InputDecoration(
                labelText: 'Phường/Xã',
                border: OutlineInputBorder(),
              ),
              items: _wards
                  .map((ward) {
                    return DropdownMenuItem<String>(
                      value: ward['Code']?.toString() ??
                          '', // Sửa key thành 'Code'
                      child: Text(ward['Name']?.toString() ??
                          ''), // Sửa key thành 'Name'
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedWardCode = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn Phường/Xã';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ cụ thể',
                hintText: 'Số nhà, tên đường...',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Vui lòng nhập địa chỉ cụ thể';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                hintText: 'Nhập số điện thoại',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Vui lòng nhập số điện thoại';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text(
                widget.initialAddress != null ? 'Cập nhật' : 'Thêm địa chỉ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
