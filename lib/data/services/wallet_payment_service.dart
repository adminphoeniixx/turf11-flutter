import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/wallet_payment_model.dart';

class WalletPaymentService {
  static Future<WalletTopupOrder> createTopupOrder({
    required int amount,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.walletTopupOrder,
      data: {
        'amount': amount,
      },
    );

    return WalletTopupOrder.fromJson(_toMap(res.data));
  }

  static Future<String> verifyTopupPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.walletTopupVerify,
      data: {
        'order_id': orderId,
        'payment_id': paymentId,
        'signature': signature,
        'amount': amount,
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
}
