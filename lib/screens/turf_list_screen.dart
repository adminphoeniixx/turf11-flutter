import 'package:flutter/material.dart' hide SearchBar;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/turf_controller.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
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
  late final TurfController controller;
  final TextEditingController _searchController = TextEditingController();
  int _sportIndex = 0;

  static const _sports = ['All', 'Cricket', 'Football', 'Badminton'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.loadNearbyTurfs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton)
              BackRow(label: 'Turfs', onBack: () => Navigator.pop(context)),
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
                            Obx(() {
                              final count = _visibleTurfs(
                                controller.turfs,
                                query,
                              ).length;
                              final subtitle =
                                  controller.isUsingFallbackLocation.value
                                      ? '$count found using fallback location'
                                      : '$count found near you';
                              return Text(
                                subtitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              );
                            }),
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
                    // SearchBar(
                    //   hint: 'Search turf name, area...',
                    //   controller: _searchController,
                    //   onChanged: (_) => setState(() {}),
                    // ),
                    ChipRow(
                      _sports,
                      initial: _sportIndex,
                      onChanged: (index) => setState(() => _sportIndex = index),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Obx(() {
                        final isLoading = controller.isLoading.value;
                        final visibleTurfs =
                            _visibleTurfs(controller.turfs, query);

                        if (isLoading && controller.turfs.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.errorMessage.value.isNotEmpty &&
                            controller.turfs.isEmpty) {
                          return _MessageState(
                            icon: LucideIcons.alertCircle,
                            title: 'Unable to load turfs',
                            subtitle: controller.errorMessage.value,
                          );
                        }

                        if (visibleTurfs.isEmpty) {
                          return const _MessageState(
                            icon: LucideIcons.mapPin,
                            title: 'No turfs found',
                            subtitle:
                                'Try changing your search or check again in a bit.',
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.green,
                          onRefresh: controller.loadNearbyTurfs,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: visibleTurfs.length,
                            itemBuilder: (context, index) {
                              final turf = visibleTurfs[index];
                              return _TurfListCard(
                                turf: turf,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingScreen(
                                      turfId: turf.id,
                                      turfName: turf.name,
                                      sportType: turf.sportType,
                                      pricePerHour: turf.pricePerHour.toInt(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
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

  List<TurfModel> _visibleTurfs(List<TurfModel> turfs, String query) {
    final activeSport = _sports[_sportIndex].toLowerCase();
    return turfs.where((turf) {
      final matchesSport =
          activeSport == 'all' || turf.sportType.toLowerCase() == activeSport;
      final matchesQuery = query.isEmpty ||
          turf.name.toLowerCase().contains(query) ||
          turf.location.toLowerCase().contains(query);
      return matchesSport && matchesQuery;
    }).toList();
  }
}

class _TurfListCard extends StatelessWidget {
  final TurfModel turf;
  final VoidCallback? onTap;

  const _TurfListCard({
    required this.turf,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
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
                          color: turf.isAvailable
                              ? Colors.white
                              : const Color(0xFFFDECEA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          turf.isAvailable ? turf.formatLabel : 'Unavailable',
                          style: GoogleFonts.dmSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: turf.isAvailable
                                ? AppColors.green
                                : AppColors.red,
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
                      Expanded(
                        child: Text(
                          turf.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        turf.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: turf.hasPrice ? 15 : 11,
                          fontWeight: FontWeight.w800,
                          color:
                              turf.hasPrice ? AppColors.green : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(LucideIcons.mapPin,
                                  size: 10, color: AppColors.muted),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _locationText(turf),
                                style: GoogleFonts.dmSans(
                                    fontSize: 10, color: AppColors.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${turf.ratingLabel} ${turf.reviewLabel}',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: AppColors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _metaPill(_capitalize(turf.sportType)),
                      const SizedBox(width: 6),
                      _metaPill(turf.formatLabel),
                      if (turf.city.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _metaPill(turf.city),
                          ),
                        ),
                      ] else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _pill('Details', AppColors.white, AppColors.dark),
                      const SizedBox(width: 6),
                      _pill(
                        turf.isAvailable ? 'Book Now' : 'Notify Me',
                        turf.isAvailable ? AppColors.dark : AppColors.white,
                        turf.isAvailable ? Colors.white : AppColors.dark,
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

  String _locationText(TurfModel turf) {
    final distance = turf.distanceKm != null && turf.distanceKm! > 0
        ? '${turf.distanceKm!.toStringAsFixed(1)} km | '
        : '';
    final address =
        turf.address.trim().isNotEmpty ? turf.address : turf.location;
    return '$distance$address';
  }

  String _capitalize(String value) {
    if (value.trim().isEmpty) {
      return '';
    }
    final normalized = value.trim().toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  Widget _metaPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
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

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.green, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
