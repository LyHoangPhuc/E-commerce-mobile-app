import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//lớp này quản lý trạng thái liên quan đến chủ đề
class ThemeProvider with ChangeNotifier {
  static const THEME_STATUS = "THEME_STATUS"; // tên chủ đề
  bool _darkTheme = false; // chủ đề mặc định
  bool get getIsDarkTheme =>
      _darkTheme; // phương thức này trả về chủ đề hiện tại

  ThemeProvider() {
    getTheme();
  }
  // phương thức này chịu trách nhiệm cập nhật chủ đề
  setDarkTheme({required bool themeValue}) async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Dòng này khởi tạo một đối tượng SharedPreferences để lưu trữ dữ liệu cục bộ. await được sử dụng để chờ cho đến khi việc khởi tạo hoàn tất.
    prefs.setBool(THEME_STATUS,
        themeValue); // Dòng này lưu trữ giá trị themeValue vào SharedPreferences với một khóa (key) là THEME_STATUS
    _darkTheme =
        themeValue; // Dòng này cập nhật biến _darkTheme trong lớp với giá trị mới của themeValue. Biến này có thể được sử dụng để xác định chủ đề hiện tại trong ứng dụng.
    notifyListeners(); // thông báo cho người nghe về sự thay đổi
  }

// phương thức này chịu trách nhiệm lấy chủ đề từ SharedPreferences
  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); //Dòng này khởi tạo một đối tượng SharedPreferences để lưu trữ dữ liệu cục bộ. await được sử dụng để chờ cho đến khi việc khởi tạo hoàn tất.
    _darkTheme = prefs.getBool(THEME_STATUS) ?? false;
    notifyListeners();
    return _darkTheme;
  }
}
