import 'package:ecommerce_app_user/models/categories_model.dart';
import '../services/assets_manager.dart';

//Đây là lớp tĩnh chứa các hằng số và danh sách dùng chung cho toàn bộ ứng dụng
class AppConstants {
  static const String imageUrl =
      'https://i.ibb.co/8r1Ny2n/20-Nike-Air-Force-1-07.png';

  static List<String> bannersImages = [
    AssetsManager.banner1,
    AssetsManager.banner2
  ];

//danh sách các danh mục sản phẩm, mỗi mục là một thể hiện của CategoriesModel với các thuộc tính như id, image, và name.
  static List<CategoriesModel> categoriesList = [
    CategoriesModel(
      id: "Phones",
      image: AssetsManager.mobiles,
      name: "Điện thoại",
    ),
    CategoriesModel(
      id: "Laptops",
      image: AssetsManager.pc,
      name: "Laptops",
    ),
    CategoriesModel(
      id: "Accessory",
      image: AssetsManager.accessory,
      name: "Phụ kiện",
    ),
    CategoriesModel(
      id: "Watches",
      image: AssetsManager.watch,
      name: "Đồng hồ",
    ),
    CategoriesModel(
      id: "Clothes",
      image: AssetsManager.fashion,
      name: "Quần áo",
    ),
    CategoriesModel(
      id: "Shoes",
      image: AssetsManager.shoes,
      name: "Giày",
    ),
    CategoriesModel(
      id: "Books",
      image: AssetsManager.book,
      name: "Sách",
    ),
    CategoriesModel(
      id: "Cosmetics",
      image: AssetsManager.cosmetics,
      name: "Mỹ phẩm",
    ),
  ];
}
