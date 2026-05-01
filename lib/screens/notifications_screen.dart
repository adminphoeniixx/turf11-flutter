import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NotificationItem> _items = [
    const _NotificationItem(
      icon: LucideIcons.checkCircle2,
      iconBg: AppColors.greenLt,
      iconColor: AppColors.green,
      title: 'Match Confirmed',
      body: 'Cricket 8v8 at DLF Arena confirmed for 7:00 PM today.',
      time: '10 min ago',
      category: 'Match Update',
      unread: true,
    ),
    const _NotificationItem(
      icon: LucideIcons.wallet,
      iconBg: Color(0xFFFFF4DB),
      iconColor: Color(0xFFB45309),
      title: 'Payment Received',
      body: 'Mohit Kumar paid Rs 100 for tonight\'s match entry.',
      time: '45 min ago',
      category: 'Payments',
      unread: true,
    ),
    const _NotificationItem(
      icon: LucideIcons.trophy,
      iconBg: Color(0xFFE6F0FF),
      iconColor: AppColors.green,
      title: 'Tournament Registration Open',
      body: 'Gurugram T10 Cup is now accepting teams. Entry fee is Rs 500.',
      time: 'Yesterday, 3:00 PM',
      category: 'Tournament',
    ),
    const _NotificationItem(
      icon: LucideIcons.alertTriangle,
      iconBg: AppColors.redLt,
      iconColor: AppColors.red,
      title: 'Payment Reminder',
      body: 'Arjun Nair has not paid Rs 100 yet. 6 hours remaining.',
      time: 'Yesterday, 8:00 PM',
      category: 'Reminder',
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(unread: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((item) => item.unread).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(
                label: 'Notification', onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: GoogleFonts.dmSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unreadCount == 0
                                ? 'You are all caught up.'
                                : '$unreadCount unread updates waiting for you.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: unreadCount == 0 ? null : _markAllRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: unreadCount == 0
                                ? AppColors.bg2
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'Mark all read',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: unreadCount == 0
                                  ? AppColors.muted2
                                  : AppColors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.greenLt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            LucideIcons.bell,
                            color: AppColors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity Center',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Track match updates, payments, reminders and tournament alerts in one place.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _NotifCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: item.unread ? AppColors.white : AppColors.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, size: 20, color: item.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (item.unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                AppBadge(
                  item.category,
                  type: item.unread ? BadgeType.green : BadgeType.dark,
                ),
                const SizedBox(height: 10),
                Text(
                  item.body,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.clock3,
                      size: 12,
                      color: AppColors.muted2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.time,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final String category;
  final bool unread;

  const _NotificationItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.unread = false,
  });

  _NotificationItem copyWith({bool? unread}) {
    return _NotificationItem(
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      title: title,
      body: body,
      time: time,
      category: category,
      unread: unread ?? this.unread,
    );
  }
}
