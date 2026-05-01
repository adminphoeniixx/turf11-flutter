import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../controllers/wallet_controller.dart';
import '../data/models/wallet_model.dart';
import '../data/models/wallet_payment_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class WalletRazorpayScreen extends StatefulWidget {
  const WalletRazorpayScreen({super.key});

  @override
  State<WalletRazorpayScreen> createState() => _WalletRazorpayScreenState();
}

class _WalletRazorpayScreenState extends State<WalletRazorpayScreen> {
  static const _fallbackRazorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  static const _amounts = [100, 500, 1000, 2000, 5000];
  static const _bonuses = [5, 30, 80, 200, 600];

  late final WalletController _walletController;
  late final Razorpay _razorpay;
  final TextEditingController _customAmountController =
      TextEditingController();

  int _selectedAmt = 1;
  WalletTopupOrder? _pendingOrder;

  @override
  void initState() {
    super.initState();
    _walletController = Get.put(WalletController());
    _walletController.loadWallet();
    _walletController.loadTransactions();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Wallet', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Obx(() {
                final wallet = _walletController.wallet.value;
                final isWalletLoading =
                    _walletController.isLoading.value && wallet == null;
                final isTopupLoading = _walletController.isTopupLoading.value;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    kScreenHorizontalPadding,
                    kScreenTopSpacing,
                    kScreenHorizontalPadding,
                    kScreenBottomSpacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _walletCard(wallet, isWalletLoading),
                      const SizedBox(height: kScreenSectionSpacing),
                      Text(
                        'Quick Recharge',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          ...List.generate(_amounts.length, (i) {
                            final selected = i == _selectedAmt;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedAmt = i;
                                _customAmountController.clear();
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      selected ? AppColors.dark : AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.dark
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Rs ${_amounts[i]}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? Colors.white
                                            : AppColors.dark,
                                      ),
                                    ),
                                    Text(
                                      '+${_bonuses[i]} bonus',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white.withOpacity(0.6)
                                            : AppColors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Custom',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kScreenSectionSpacing),
                      const SectionLabel('Or Enter Custom Amount'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Rs',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _customAmountController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintStyle: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppColors.muted2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: kScreenSectionSpacing),
                      const SectionLabel('Pay Via'),
                      _paymentMethodCard(),
                      const SizedBox(height: 8),
                      AppButton(
                        label: isTopupLoading
                            ? 'Processing...'
                            : 'Add Rs ${_selectedAmount()} to Wallet',
                        color: AppColors.green,
                        onTap: isTopupLoading ? null : _startWalletTopup,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wallet credit is completed only after backend payment verification.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startWalletTopup() async {
    final amountInRupees = _selectedAmount();
    if (amountInRupees < 1) {
      Get.snackbar('Invalid amount', 'Please enter a valid amount.');
      return;
    }

    try {
      final amountInPaise = amountInRupees * 100;
      final order = await _walletController.createTopupOrder(
        amount: amountInPaise,
      );
      final keyId =
          order.keyId.isNotEmpty ? order.keyId : _fallbackRazorpayKey;

      if (keyId.isEmpty) {
        throw Exception(
          'Missing Razorpay key. Return key_id from backend or use --dart-define=RAZORPAY_KEY_ID=rzp_test_xxx.',
        );
      }

      _pendingOrder = order;
      _razorpay.open(order.toCheckoutOptions(fallbackKeyId: keyId));
    } catch (e) {
      Get.snackbar('Payment error', _readableError(e));
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final order = _pendingOrder;
    if (order == null) {
      Get.snackbar(
        'Verification error',
        'Payment succeeded but the pending order context was lost.',
      );
      return;
    }

    final paymentId = response.paymentId;
    final signature = response.signature;
    final orderId = response.orderId ?? order.orderId;

    if (paymentId == null || signature == null || orderId.isEmpty) {
      Get.snackbar(
        'Verification error',
        'Missing payment verification data from Razorpay.',
      );
      return;
    }

    try {
      final message = await _walletController.verifyTopupPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      _pendingOrder = null;
      await _showTopupSuccessSheet(
        message.isNotEmpty
            ? message
            : 'Your wallet has been recharged successfully.',
      );
    } catch (e) {
      Get.snackbar('Verification failed', _readableError(e));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _pendingOrder = null;
    final message = (response.message ?? 'Payment was not completed.').trim();
    Get.snackbar('Payment failed', message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final walletName = response.walletName ?? 'External wallet';
    Get.snackbar('External wallet', '$walletName selected.');
  }

  Future<void> _showTopupSuccessSheet(String message) async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.greenLt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.checkCircle2,
                    color: AppColors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Wallet Recharged',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Done',
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _selectedAmount() {
    final custom = int.tryParse(_customAmountController.text.trim());
    if (custom != null && custom > 0) {
      return custom;
    }
    return _amounts[_selectedAmt];
  }

  Widget _walletCard(WalletResponse? wallet, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.dark, Color(0xFF2C3E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TURF11 WALLET',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            wallet == null
                ? (isLoading ? 'Loading...' : 'Rs 0.00')
                : 'Rs ${wallet.walletBalance.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            wallet == null
                ? 'Reward points: 0'
                : 'Reward points: ${wallet.rewardPoints}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: _openTransactionHistorySheet,
                child: _tag(
                  'View Transactions',
                  bgColor: AppColors.greenLt,
                  textColor: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              _tag(
                wallet == null ? 'Points 0' : 'Points ${wallet.rewardPoints}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(
    String text, {
    Color? bgColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _txnItem(WalletTransaction txn) {
    final isCredit = _isCredit(txn);
    final amountText = isCredit
        ? '+Rs ${_formatAmount(txn.amount)}'
        : '-Rs ${_formatAmount(txn.amount)}';
    final title = txn.description.trim().isNotEmpty
        ? txn.description.trim()
        : _formatTitle(txn.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.greenLt : AppColors.redLt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? LucideIcons.arrowDownLeft : LucideIcons.activity,
              size: 16,
              color: isCredit ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  _formatSubtitle(txn),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCredit(WalletTransaction txn) {
    final direction = txn.direction.trim().toLowerCase();
    if (direction == 'credit') {
      return true;
    }
    if (direction == 'debit') {
      return false;
    }

    final normalized = txn.type.trim().toLowerCase();
    return normalized.contains('credit') ||
        normalized.contains('add') ||
        normalized.contains('recharge') ||
        normalized.contains('refund') ||
        normalized.contains('deposit');
  }

  String _formatAmount(double amount) {
    final isWhole = amount == amount.roundToDouble();
    return amount.toStringAsFixed(isWhole ? 0 : 2);
  }

  String _formatTitle(String raw) {
    if (raw.trim().isEmpty) {
      return 'Wallet Transaction';
    }

    return raw
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatSubtitle(WalletTransaction txn) {
    final parts = <String>[
      if (txn.performedByName.trim().isNotEmpty) txn.performedByName.trim(),
      if (txn.createdAt.trim().isNotEmpty) _formatDateTime(txn.createdAt),
      if (txn.txnCode.trim().isNotEmpty) txn.txnCode.trim(),
      if (txn.balanceAfter > 0) 'Balance after: Rs ${_formatAmount(txn.balanceAfter)}',
    ];

    if (parts.isEmpty) {
      return 'Wallet update';
    }

    return parts.join(' | ');
  }

  String _formatDateTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    return DateFormat('dd MMM yyyy, h:mm a').format(parsed.toLocal());
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  Widget _paymentMethodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.wallet,
              color: AppColors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Razorpay',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  'Secure checkout via Razorpay',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Active',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTransactionHistorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Obx(() {
                  final transactions = _walletController.transactions;
                  final isTransactionsLoading =
                      _walletController.isTransactionsLoading.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transaction History',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aapke wallet ke saare credits aur debits yahan dikhenge.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: isTransactionsLoading && transactions.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : transactions.isEmpty
                                ? Center(
                                    child: Text(
                                      'No wallet transactions yet.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: transactions.length,
                                    separatorBuilder: (_, __) =>
                                        const AppDivider(),
                                    itemBuilder: (context, index) =>
                                        _txnItem(transactions[index]),
                                  ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
