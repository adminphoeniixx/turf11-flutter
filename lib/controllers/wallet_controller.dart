import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/wallet_model.dart';
import '../data/models/wallet_payment_model.dart';
import '../data/services/wallet_payment_service.dart';
import '../data/services/wallet_service.dart';

class WalletController extends GetxController {
  final isLoading = false.obs;
  final isTopupLoading = false.obs;
  final wallet = Rxn<WalletResponse>();

  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      wallet.value = await WalletService.fetchWallet();
    } catch (e) {
      debugPrint('[WalletController] loadWallet failed: ${_readableError(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<WalletTopupOrder> createTopupOrder({
    required int amount,
  }) async {
    try {
      isTopupLoading.value = true;
      return await WalletPaymentService.createTopupOrder(amount: amount);
    } catch (e) {
      debugPrint(
        '[WalletController] createTopupOrder failed: ${_readableError(e)}',
      );
      rethrow;
    } finally {
      isTopupLoading.value = false;
    }
  }

  Future<String> verifyTopupPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount,
  }) async {
    try {
      isTopupLoading.value = true;
      final message = await WalletPaymentService.verifyTopupPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        amount: amount,
      );
      await loadWallet();
      return message;
    } catch (e) {
      debugPrint(
        '[WalletController] verifyTopupPayment failed: ${_readableError(e)}',
      );
      rethrow;
    } finally {
      isTopupLoading.value = false;
    }
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }
}
