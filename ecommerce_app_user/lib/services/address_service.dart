import 'dart:convert';
import 'package:flutter/services.dart';

class AddressService {
  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  Future<void> loadAddressData() async {
    try {
      final String response = await rootBundle
          .loadString('assets/data/full_json_generated_data_vn_units.json');
      final List<dynamic> data = json.decode(response);

      // Đảm bảo chỉ lấy các province
      _provinces = data.where((item) => item['Type'] == 'province').toList();

      // Lấy districts từ trong mỗi province
      _districts = _provinces
          .expand((province) => (province['District'] as List<dynamic>? ?? []))
          .toList();

      // Lấy wards từ trong mỗi district
      _wards = _districts
          .expand((district) => (district['Ward'] as List<dynamic>? ?? []))
          .toList();
    } catch (e) {
      print('Error loading address data: $e');
      // Khởi tạo list rỗng để tránh null
      _provinces = [];
      _districts = [];
      _wards = [];
    }
  }

  List<dynamic> getProvinces() {
    return _provinces;
  }

  List<dynamic> getDistricts(String provinceCode) {
    return _districts
        .where((district) => district['ProvinceCode'] == provinceCode)
        .toList();
  }

  List<dynamic> getWards(String provinceCode, String districtCode) {
    return _wards
        .where((ward) => ward['DistrictCode'] == districtCode)
        .toList();
  }
}
