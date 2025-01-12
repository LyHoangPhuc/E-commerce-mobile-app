import 'package:flutter/material.dart';

class AppConstants {
  static const String productImageUrl =
      'https://i.ibb.co/8r1Ny2n/20-Nike-Air-Force-1-07.png';

  static List<String> categoriesList = [
    'Điện thoại',
    'Laptops',
    'Phụ kiện',
    'Đồng hồ',
    'Quần áo',
    'Giày',
    'Sách',
    'Mỹ phẩm',
  ];

  static List<DropdownMenuItem<String>>? get categoriesDropDownList {
    List<DropdownMenuItem<String>>? menuItems =
        List<DropdownMenuItem<String>>.generate(
      categoriesList.length,
      (index) => DropdownMenuItem(
        value: categoriesList[index],
        child: Text(
          categoriesList[index],
        ),
      ),
    );
    return menuItems;
  }
}
