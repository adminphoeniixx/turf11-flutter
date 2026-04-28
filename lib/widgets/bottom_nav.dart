import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: LucideIcons.home, label: 'Home'),
    (icon: LucideIcons.mapPin, label: 'Turfs'),
    (icon: LucideIcons.trophy, label: 'Leagues'),
    (icon: LucideIcons.calendarDays, label: 'Bookings'),
    (icon: LucideIcons.user, label: 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(
          top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final on = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon,
                    size: 20,
                    color: on ? AppColors.green : AppColors.muted2),
                const SizedBox(height: 3),
                Text(item.label,
                    style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: on ? AppColors.green : AppColors.muted2)),
                if (on)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: AppColors.green, shape: BoxShape.circle),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
