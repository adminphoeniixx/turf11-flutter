import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../screens/wallet_razorpay_screen.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class WalletFeedback {
  WalletFeedback._();

  static bool isInsufficientWalletMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('insufficient') ||
        normalized.contains('low balance') ||
        normalized.contains('wallet balance') ||
        normalized.contains('top up') ||
        normalized.contains('recharge');
  }

  static Future<void> showLowBalance({
    BuildContext? context,
    String message = '',
    num? walletBalance,
    num? requiredAmount,
  }) async {
    final activeContext = context ?? Get.context;
    if (activeContext == null) {
      Get.snackbar(
        'Wallet Balance Low',
        message.isNotEmpty ? message : 'Please top up your wallet to continue.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: activeContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _WalletSheetShell(
          icon: LucideIcons.wallet,
          iconColor: AppColors.amber,
          iconBg: AppColors.amberLt,
          title: 'Wallet Balance Low',
          message: message.isNotEmpty
              ? message
              : 'Please top up your wallet to continue.',
          details: [
            if (walletBalance != null) 'Balance: Rs ${_formatAmount(walletBalance)}',
            if (requiredAmount != null) 'Required: Rs ${_formatAmount(requiredAmount)}',
          ],
          primaryLabel: 'Top Up Wallet',
          onPrimary: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(activeContext).push(
              MaterialPageRoute(builder: (_) => const WalletRazorpayScreen()),
            );
          },
          secondaryLabel: 'Maybe Later',
          onSecondary: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  static Future<void> showPaymentSuccess({
    BuildContext? context,
    String title = 'Thank You',
    String message = 'Payment completed successfully.',
    VoidCallback? onDone,
  }) async {
    final activeContext = context ?? Get.context;
    if (activeContext == null) {
      Get.snackbar(title, message);
      onDone?.call();
      return;
    }

    await showModalBottomSheet<void>(
      context: activeContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _WalletSheetShell(
          icon: LucideIcons.checkCircle2,
          iconColor: AppColors.green,
          iconBg: AppColors.greenLt,
          title: title,
          message: message,
          primaryLabel: 'Done',
          onPrimary: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
    onDone?.call();
  }

  static String _formatAmount(num value) {
    final amount = value.toDouble();
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }
}

class _WalletSheetShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String message;
  final List<String> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _WalletSheetShell({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.details = const <String>[],
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
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
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
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
            if (details.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details
                      .map(
                        (detail) => Text(
                          detail,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppButton(label: primaryLabel, onTap: onPrimary),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              AppButton(
                label: secondaryLabel!,
                isOutline: true,
                onTap: onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
