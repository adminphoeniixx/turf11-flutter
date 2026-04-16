import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/wallet_model.dart';

class WalletService {
  static Future<WalletResponse> fetchWallet() async {
    final res = await ApiClient.get(ApiConstants.wallet);
    return WalletResponse.fromJson(_toMap(res.data));
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
