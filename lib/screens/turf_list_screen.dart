import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_widgets.dart' as custom;
import 'booking_screen.dart';

class TurfListScreen extends StatefulWidget {
  final bool showBackButton;

  const TurfListScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<TurfListScreen> createState() => _TurfListScreenState();
}

class _TurfListScreenState extends State<TurfListScreen> {
  int _sportIndex = 0;

  static const _turfs = [
    (
      name: 'DLF Arena Cricket Box',
      location: 'Sector 29 | 1.2 km',
      price: 'Rs 800/hr',
      rating: '4.2 (128)',
      badge: 'Open Now',
      badgeColor: Colors.white,
      available: true,
    ),
    (
      name: 'Sector 56 Cricket Box',
      location: 'Sector 56 | 2.4 km',
      price: 'Rs 600/hr',
      rating: '4.7 (89)',
      badge: 'Peak Hours',
      badgeColor: Color(0xFFFEF3CD),
      available: true,
    ),
    (
      name: 'CyberHub Cricket Arena',
      location: 'CyberHub | 3.1 km',
      price: 'Rs 900/hr',
      rating: '4.5 (203)',
      badge: 'Full Today',
      badgeColor: Color(0xFFFDECEA),
      available: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton)
              BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                              'Nearby Turfs',
                              style: GoogleFonts.dmSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                            ),
                            Text(
                              'Gurugram | 12 found',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.slidersHorizontal,
                                size: 14,
                                color: AppColors.dark,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Filter',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const custom.SearchBar(hint: 'Search turf name, area...'),
                    ChipRow(
                      const ['All', 'Cricket', 'Football', 'Badminton'],
                      initial: _sportIndex,
                      onChanged: (index) => setState(() => _sportIndex = index),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _turfs.length,
                        itemBuilder: (context, index) {
                          final turf = _turfs[index];
                          return _TurfListCard(
                            name: turf.name,
                            location: turf.location,
                            price: turf.price,
                            rating: turf.rating,
                            badge: turf.badge,
                            badgeBg: turf.badgeColor,
                            available: turf.available,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BookingScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurfListCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String rating;
  final String badge;
  final Color badgeBg;
  final bool available;
  final VoidCallback? onTap;

  const _TurfListCard({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.badge,
    required this.badgeBg,
    required this.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Container(
                height: 100,
                color: const Color(0xFF2D5A1B),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.dmSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: available ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      Text(
                        price,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 10, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.muted),
                          ),
                        ],
                      ),
                      Text(
                        'Star $rating',
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _pill('Map', AppColors.white, AppColors.dark),
                      const SizedBox(width: 6),
                      _pill(
                        available ? 'Book' : 'Notify Me',
                        available ? AppColors.dark : AppColors.white,
                        available ? Colors.white : AppColors.dark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: bg == AppColors.white
            ? Border.all(color: AppColors.border, width: 1.5)
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
