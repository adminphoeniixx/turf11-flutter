import 'package:get/get.dart';

import '../core/session_bootstrap_service.dart';
import '../core/storage_service.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final lastOtpRequestId = ''.obs;

  // 🔹 SEND OTP
  Future<bool> sendOtp(String phone, bool isLogin) async {
    try {
      isLoading.value = true;

      try {
        final phoneStatus = await AuthService.checkPhone(phone);
        if (phoneStatus.exists != null) {
          if (isLogin && phoneStatus.exists == false) {
            Get.snackbar(
              "Error",
              phoneStatus.message.isNotEmpty
                  ? phoneStatus.message
                  : "This phone number is not registered.",
            );
            return false;
          }

          if (!isLogin && phoneStatus.exists == true) {
            Get.snackbar(
              "Error",
              phoneStatus.message.isNotEmpty
                  ? phoneStatus.message
                  : "This phone number is already registered.",
            );
            return false;
          }
        }
      } catch (_) {
        // Proceed with send OTP even if pre-check is unavailable.
      }

      final res = await AuthService.sendOtp(
        phone,
        isLogin ? "login" : "register",
      );
      lastOtpRequestId.value = res.requestId;

      Get.snackbar(
        "Success",
        res.message.isNotEmpty ? res.message : "OTP sent successfully",
      );
      return true;
    } catch (e) {
      Get.snackbar("Error", _readableError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 LOGIN
  Future<bool> login(String phone, String otp) async {
    try {
      isLoading.value = true;

      final res = await AuthService.login(phone, otp);
      await StorageService.saveToken(res.token);
      await SessionBootstrapService.bootstrapSession(forceRefresh: true);

      Get.snackbar("Success", res.message.isNotEmpty ? res.message : "Login successful");
      return true;
    } catch (e) {
      Get.snackbar("Error", _readableError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 REGISTER
  Future<bool> register(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      final res = await AuthService.register(data);
      await StorageService.saveToken(res.token);
      await SessionBootstrapService.bootstrapSession(forceRefresh: true);

      Get.snackbar("Success", res.message.isNotEmpty ? res.message : "Registered successfully");
      return true;
    } catch (e) {
      Get.snackbar("Error", _readableError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 RESEND OTP ✅ FIXED (NOW INSIDE CLASS)
  Future<bool> resendOtp(String phone, bool isLogin) async {
    try {
      isLoading.value = true;

      final res = await AuthService.resendOtp(
        phone,
        isLogin ? "login" : "register",
      );
      lastOtpRequestId.value = res.requestId;

      Get.snackbar(
        "Success",
        res.message.isNotEmpty ? res.message : "OTP resent successfully",
      );
      return true;
    } catch (e) {
      Get.snackbar("Error", _readableError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 LOGOUT
  Future<bool> logout() async {
    String? errorMessage;

    try {
      isLoading.value = true;
      await AuthService.logout();
    } catch (e) {
      errorMessage = _readableError(e);
    } finally {
      await StorageService.clear();
      await SessionBootstrapService.clearSessionControllers();
      isLoading.value = false;
    }

    if (errorMessage != null) {
      Get.snackbar(
        "Logged out",
        "Session cleared on this device. Server response: $errorMessage",
      );
      return true;
    }

    Get.snackbar("Success", "Logged out successfully");
    return true;
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith("Exception: ")) {
      return raw.substring("Exception: ".length);
    }
    return raw;
  }
}
