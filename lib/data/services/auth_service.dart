import '../models/auth_model.dart';
import '../../core/api_client.dart';
import '../../core/api_constants.dart';

class AuthService {
  static Future<SendOtpResponse> sendOtp(String phone, String type) async {
    final res = await ApiClient.post(
      ApiConstants.sendOtp,
      data: {
        "phone": phone,
        "type": type,
      },
    );
    return SendOtpResponse.fromJson(_toMap(res.data));
  }

  static Future<CheckPhoneResponse> checkPhone(String phone) async {
    final res = await ApiClient.get(
      ApiConstants.checkPhone,
      queryParameters: {"phone": phone},
    );

    return CheckPhoneResponse.fromJson(_toMap(res.data));
  }

  static Future<SendOtpResponse> resendOtp(String phone, String type) async {
    try {
      final res = await ApiClient.post(
        ApiConstants.resendOtp,
        data: {
          "phone": phone,
          "type": type,
        },
      );
      return SendOtpResponse.fromJson(_toMap(res.data));
    } catch (_) {
      return sendOtp(phone, type);
    }
  }

  static Future<AuthResponse> login(String phone, String otp) async {
    final res = await ApiClient.post(
      ApiConstants.login,
      data: {
        "phone": phone,
        "otp": otp,
        "device_name": "flutter",
      },
    );

    return AuthResponse.fromJson(_toMap(res.data));
  }

  static Future<AuthResponse> register(Map<String, dynamic> data) async {
    final res = await ApiClient.post(
      ApiConstants.register,
      data: data,
    );

    return AuthResponse.fromJson(_toMap(res.data));
  }

  static Future<void> logout() async {
    await ApiClient.post(ApiConstants.logout);
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{};
  }
}
