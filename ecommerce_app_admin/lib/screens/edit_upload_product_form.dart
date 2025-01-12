// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app_admin/consts/app_constants.dart';
import 'package:ecommerce_app_admin/models/product_model.dart';
import 'package:ecommerce_app_admin/services/my_app_method.dart';
import 'package:ecommerce_app_admin/widgets/subtitle_text.dart';
import 'package:uuid/uuid.dart';

import '../consts/my_validators.dart';
import '../widgets/title_text.dart';
import 'loading_manager.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({
    super.key,
    this.productModel,
  });
  final ProductModel? productModel;
  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? productNetworkImage;

  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController;
  String? _categoryValue;
  bool _isLoading = false;
  String? productImageUrl;
  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _categoryValue = widget.productModel!.productCategory;
    }
    _titleController =
        TextEditingController(text: widget.productModel?.productTitle);
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Hãy chắc chắn để chọn một hình ảnh",
        fct: () {},
      );
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Thể loại đang trống",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final productID = const Uuid().v4();
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child('$productID.jpg');
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .set({
          'productId': productID,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Sản phẩm đã được thêm vào",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Xóa mẫu?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Đã xảy ra lỗi ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Đã xảy ra lỗi $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Xin hãy chọn một hình ảnh",
        fct: () {},
      );
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Thể loại đang trống",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child('${widget.productModel!.productId}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': widget.productModel!.createdAt,
        });
        Fluttertoast.showToast(
          msg: "Sản phẩm đã được chỉnh sửa",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Xóa mẫu?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Đã xảy ra lỗi ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Đã xảy ra lỗi $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage = null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          productNetworkImage = null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  Future<void> _deleteProduct() async {
    final confirm = await MyAppMethods.showErrorORWarningDialog(
      context: context,
      subtitle: "Bạn có chắc chắn muốn xóa sản phẩm này không?",
      isError: true,
      fct: () async {
        // Nếu người dùng xác nhận, xóa sản phẩm
        try {
          setState(() {
            _isLoading = true;
          });
          await FirebaseFirestore.instance
              .collection("products")
              .doc(widget.productModel!.productId)
              .delete();
          Fluttertoast.showToast(
            msg: "Sản phẩm đã bị xóa",
            toastLength: Toast.LENGTH_SHORT,
            textColor: Colors.white,
          );
          Navigator.of(context).pop(); // Quay lại màn hình trước đó
        } on FirebaseException catch (error) {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "Đã xảy ra lỗi: ${error.message}",
            fct: () {},
          );
        } catch (error) {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "Đã xảy ra lỗi: $error",
            fct: () {},
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      "Xóa",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      clearForm();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      // backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Chỉnh sửa" : "Tải lên sản phẩm",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                  ),
                  if (isEditing) // Hiển thị nút xóa chỉ khi đang chỉnh sửa
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text(
                        "Xóa",
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        _deleteProduct();
                      },
                    ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const TitlesTextWidget(
              label: "Tải lên một sản phẩm mới",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                          color: Colors.blue,
                          radius: const Radius.circular(12),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.blue,
                                ),
                                TextButton(
                                  onPressed: () {
                                    localImagePicker();
                                  },
                                  child: const Text("Chọn hình ảnh sản phẩm"),
                                ),
                              ],
                            ),
                          )),
                    )
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        // width: size.width * 0.7,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                  if (_pickedImage != null || productNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: const Text("Chọn một hình ảnh khác"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Xóa hình ảnh",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint: Text(_categoryValue ?? "Chọn danh mục"),
                    value: _categoryValue,
                    items: AppConstants.categoriesDropDownList,
                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Tiêu đề sản phẩm',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Vui lòng nhập tiêu đề hợp lệ",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey('Price VND'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Giá',
                                      prefix: SubtitleTextWidget(
                                        label: "VND ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Giá bị thiếu",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    hintText: 'Số lượng',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString:
                                          "Số lượng bị bỏ thiếu",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Mô tả sản phẩm',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Mô tả bị bỏ thiếu",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
