//Lớp này để lưu trữ và quản lý dữ liệu liên quan đến các danh mục sản phẩm
//bao gồm id của danh mục, tên của danh mục và hình ảnh của danh mục.
//sử dụng ChangeNotifier để cung cấp khả năng thông báo thay đổi cho việc quản lý trạng thái
class CategoriesModel {
  final String id, name, image;

  CategoriesModel({
    required this.id,
    required this.name,
    required this.image,
  });
}
