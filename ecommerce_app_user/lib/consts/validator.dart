
class MyValidators {
    static String? displayNamevalidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Tên hiển thị không được để trống';
    }
    if (displayName.length < 3 || displayName.length > 20) {
      return 'Tên hiển thị phải từ 3 đến 20 ký tự';
    }

    return null; // Return null if display name is valid
  }

    static String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(value)) {
      return 'Vui lòng nhập email hợp lệ';
    }
    return null;
  }

    static String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải dài ít nhất 6 ký tự';
    }
    return null;
  }

    static String? repeatPasswordValidator({String? value, String? password}) {
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

    static String? uploadProdTexts({String? value, String? toBeReturnedString}) {
    if (value!.isEmpty) {
      return toBeReturnedString;
    }
    return null;
  }
}
