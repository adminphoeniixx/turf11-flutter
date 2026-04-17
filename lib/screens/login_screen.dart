import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());
  final TextEditingController mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 SAME UI (no change)
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const AppLogo(width: 170),
                ),
              ),
              const SizedBox(height: 28),

              Text('Welcome back.',
                  style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      letterSpacing: -0.3)),

              const SizedBox(height: 4),

              Text('Sign in with your mobile number',
                  style:
                      GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),

              const SizedBox(height: 24),

              // 🔥 SAME MOBILE FIELD UI
              _MobileField(controller: mobileController),

              const SizedBox(height: 4),

              // 🔥 ONLY LOGIC CHANGED HERE
              Obx(
                () => AppButton(
                  label: controller.isLoading.value ? 'Sending OTP...' : 'Send OTP',
                  trailingIcon:
                      controller.isLoading.value ? null : Icons.arrow_forward,
                  onTap: controller.isLoading.value
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          final phone = mobileController.text.trim();

                          if (phone.length != 10) {
                            Get.snackbar("Error", "Enter valid number");
                            return;
                          }

                          final sent = await controller.sendOtp(phone, true);
                          if (!sent) {
                            return;
                          }

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpScreen(
                                phone: phone,
                                isLogin: true,
                              ),
                            ),
                          );
                        },
                ),
              ),

              const SizedBox(height: 10),

              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controller.isLoading.value ? 1 : 0,
                  child: Text(
                    'Please wait, OTP request is being processed.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'New here? ',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted),
                      ),
                      TextSpan(
                        text: 'Create Account →',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileField extends StatelessWidget {
  final TextEditingController controller;

  const _MobileField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              border: Border(
                  right: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Text('🇮🇳 +91',
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark2)),
          ),
          Expanded(
            child: TextField(
              controller: controller, // ✅ ONLY ADD THIS
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: '9876543210',
                border: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                hintStyle:
                    GoogleFonts.dmSans(fontSize: 14, color: AppColors.muted2),
              ),
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}
