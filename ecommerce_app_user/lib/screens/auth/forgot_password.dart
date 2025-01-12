import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../consts/validator.dart';
import '../../services/assets_manager.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/ForgotPasswordScreen';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _emailController.dispose();
    }
    super.dispose();
  }

  Future<void> _forgetPassFCT() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        Fluttertoast.showToast(
          msg: "Đã gửi liên kết đặt lại mật khẩu! Kiểm tra email của bạn.",
          textColor: Colors.white,
        );
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.message ?? "Có lỗi xảy ra",
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppNameTextWidget(
          fontSize: 22,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: ListView(
            // shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              // Section 1 - Header
              const SizedBox(
                height: 10,
              ),
              Image.asset(
                AssetsManager.forgotPassword,
                width: size.width * 0.6,
                height: size.width * 0.6,
              ),
              const SizedBox(
                height: 10,
              ),
              const TitlesTextWidget(
                label: 'Quên mật khẩu',
                fontSize: 22,
              ),
              const SubtitleTextWidget(
                label:
                    'Vui lòng nhập địa chỉ email mà bạn muốn nhận thông tin đặt lại mật khẩu',
                fontSize: 14,
              ),
              const SizedBox(
                height: 40,
              ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'youremail@email.com',
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(IconlyLight.message),
                        ),
                        filled: true,
                      ),
                      validator: (value) {
                        return MyValidators.emailValidator(value);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    // backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  icon: const Icon(IconlyBold.send),
                  label: const Text(
                    "Gửi yêu cầu",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await _forgetPassFCT();
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
