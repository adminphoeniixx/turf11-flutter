import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/wallet_controller.dart';
import '../data/models/wallet_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  late final WalletController _walletController;
  int _selectedAmt = 1;

  static const _amounts = [100, 500, 1000, 2000, 5000];
  static const _bonuses = [5, 30, 80, 200, 600];

  @override
  void initState() {
    super.initState();
    _walletController = Get.put(WalletController());
    _walletController.loadWallet();
    _walletController.loadTransactions();
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
                final isLoading =
                    _walletController.isLoading.value && wallet == null;
                final transactions = _walletController.transactions;
                final isTransactionsLoading =
                    _walletController.isTransactionsLoading.value;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _walletCard(wallet, isLoading),
                      const SizedBox(height: 14),
                      Text(
                        'Quick Recharge',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                              onTap: () => setState(() => _selectedAmt = i),
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
                                      '₹${_amounts[i]}',
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
                      const SizedBox(height: 14),
                      const SectionLabel('Or Enter Custom Amount'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1.5),
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
                                '₹',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  border: InputBorder.none,
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
                      const SizedBox(height: 14),
                      const SectionLabel('Pay Via'),
                      ChipRow(['UPI', 'Card', 'Net Banking']),
                      const SizedBox(height: 4),
                      AppButton(
                        label: 'Add ₹${_amounts[_selectedAmt]} to Wallet',
                        color: AppColors.green,
                        trailingIcon: Icons.arrow_forward,
                        onTap: () {},
                      ),
                      const SectionLabel('Transaction History'),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (isTransactionsLoading && transactions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (transactions.isEmpty)
                        SmallCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'No wallet transactions yet.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SmallCard(
                          child: Column(
                            children: [
                              for (var i = 0; i < transactions.length; i++) ...[
                                _txnItem(transactions[i]),
                                if (i != transactions.length - 1)
                                  const AppDivider(),
                              ],
                            ],
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
                ? (isLoading ? 'Loading...' : '₹0.00')
                : '₹${wallet.walletBalance.toStringAsFixed(2)}',
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
              _tag('Transactions ${_walletController.transactions.length}'),
              const SizedBox(width: 8),
              _tag(wallet == null
                  ? 'Points 0'
                  : 'Points ${wallet.rewardPoints}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _txnItem(WalletTransaction txn) {
    final isCredit = _isCredit(txn);
    final amountText = isCredit
        ? '+₹${_formatAmount(txn.amount)}'
        : '-₹${_formatAmount(txn.amount)}';
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
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatSubtitle(WalletTransaction txn) {
    final parts = <String>[
      if (txn.performedByName.trim().isNotEmpty) txn.performedByName.trim(),
      if (txn.createdAt.trim().isNotEmpty) _formatDateTime(txn.createdAt),
      if (txn.txnCode.trim().isNotEmpty) txn.txnCode.trim(),
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
}
