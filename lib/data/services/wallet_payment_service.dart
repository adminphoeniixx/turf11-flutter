import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/wallet_payment_model.dart';

class WalletPaymentService {
  static Future<WalletTopupOrder> createTopupOrder({
    required int amount,
  }) async {
    final payload = {
      'amount': amount,
    };

    final res = await _postWithFallback(
      primaryPath: ApiConstants.walletTopupOrder,
      fallbackPath: ApiConstants.walletTopupOrderLegacy,
      data: payload,
    );

    return WalletTopupOrder.fromJson(_toMap(res.data));
  }

  static Future<String> verifyTopupPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.walletTopupVerify,
      data: {
        'gateway_order_id': orderId,
        'gateway_payment_id': paymentId,
        'razorpay_signature': signature,
      },
    );

    final data = _toMap(res.data);
    final message = data['message'] ?? _toMap(data['data'])['message'];
    return message?.toString() ?? 'Wallet recharged successfully.';
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  static Future<Response<dynamic>> _postWithFallback({
    required String primaryPath,
    required String fallbackPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await ApiClient.post(primaryPath, data: data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        rethrow;
      }

      return ApiClient.post(fallbackPath, data: data);
    }
  }
}
