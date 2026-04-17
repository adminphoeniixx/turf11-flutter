import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.dmSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    'Mark all read',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                children: const [
                  _Notif(
                    icon: LucideIcons.checkCircle,
                    iconBg: AppColors.greenLt,
                    iconColor: AppColors.green,
                    title: 'Match Confirmed!',
                    body: 'Cricket 8v8 at DLF Arena confirmed for 7 PM.',
                    time: '10 min ago',
                    unread: true,
                  ),
                  _Notif(
                    icon: LucideIcons.wallet,
                    iconBg: Color(0xFFFFFBEB),
                    iconColor: Color(0xFFB45309),
                    title: 'Payment Received',
                    body: 'Mohit Kumar paid Rs 100 for tonight\'s match.',
                    time: '45 min ago',
                    unread: true,
                  ),
                  _Notif(
                    icon: LucideIcons.trophy,
                    iconBg: AppColors.greenLt,
                    iconColor: AppColors.green,
                    title: 'Tournament Registration Open',
                    body: 'Gurugram T10 Cup now accepting teams. Rs 500 entry.',
                    time: 'Yesterday 3 PM',
                  ),
                  _Notif(
                    icon: LucideIcons.alertCircle,
                    iconBg: AppColors.redLt,
                    iconColor: AppColors.red,
                    title: 'Payment Reminder',
                    body: 'Arjun Nair hasn\'t paid Rs 100. 6h remaining.',
                    time: 'Yesterday 8 PM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool unread;

  const _Notif({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unread)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 6, right: 5),
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.muted2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
