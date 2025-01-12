import 'package:ecommerce_app_user/widgets/title_text.dart';
import 'package:flutter/material.dart';
import '../widgets/subtitle_text.dart';
import 'assets_manager.dart';

class MyAppFunctions {
  static Future<void> showErrorOrWarningDialog({
    required BuildContext context,
    required String subtitle,
    bool isError = true,
    required Function fct,
  }) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  isError ? AssetsManager.error : AssetsManager.warning,
                  height: 60,
                  width: 60,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                SubtitleTextWidget(
                  label: subtitle,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !isError,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const SubtitleTextWidget(
                          label: "Hủy bỏ",
                          color: Colors.green,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        fct();
                        Navigator.pop(context);
                      },
                      child: const SubtitleTextWidget(
                        label: "OK",
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  static String formatPrice(double price) {
    // Chuyển số thành string và bỏ .0 ở cuối
    String priceStr = price.toString().replaceAll(RegExp(r'\.0+$'), '');

    // Thêm dấu chấm phân cách mỗi 3 số
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    priceStr = priceStr.replaceAllMapped(regex, (Match m) => '${m[1]}.');

    return priceStr;
  }

  static Future<void> imagePickerDialog({
    required BuildContext context,
    required Function cameraFCT,
    required Function galleryFCT,
    required Function removeFCT,
  }) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: TitlesTextWidget(
                label: "Chọn tùy chọn",
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      cameraFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("Máy ảnh"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      galleryFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.browse_gallery,
                    ),
                    label: const Text("Thư viện"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      removeFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                    label: const Text("Loại bỏ"),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
