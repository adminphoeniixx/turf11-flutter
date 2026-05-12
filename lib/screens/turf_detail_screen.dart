import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/turf_controller.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/turf_media_gallery.dart';

class TurfDetailScreen extends StatefulWidget {
  final TurfModel initialTurf;

  const TurfDetailScreen({
    super.key,
    required this.initialTurf,
  });

  @override
  State<TurfDetailScreen> createState() => _TurfDetailScreenState();
}

class _TurfDetailScreenState extends State<TurfDetailScreen> {
  late final TurfController _turfController;

  @override
  void initState() {
    super.initState();
    _turfController = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    _turfController.selectedTurf.value = widget.initialTurf;
    _turfController.reviews.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _turfController.loadTurfDetail(widget.initialTurf.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(
              label: 'Turf Details',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  kScreenHorizontalPadding,
                  kScreenTopSpacing,
                  kScreenHorizontalPadding,
                  kScreenBottomSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailHeroCard(),
                    const SizedBox(height: kScreenBlockSpacing),
                    _detailSections(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailHeroCard() {
    return Obx(() {
      final turf = _turfController.selectedTurf.value ?? widget.initialTurf;
      final isLoading = _turfController.isDetailLoading.value &&
          _turfController.selectedTurf.value == null;
      final detailError = _turfController.detailErrorMessage.value;

      if (isLoading) {
        return const _TurfHeroLoadingCard();
      }

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E20), AppColors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turf.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _detailLocation(turf),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.8),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppBadge(turf.formatLabel, type: BadgeType.dark),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _heroStat(
                  LucideIcons.star,
                  _ratingText(turf.rating, turf.totalReviews),
                ),
                _heroStat(
                  LucideIcons.users,
                  turf.maxCapacity > 0
                      ? 'Up to ${turf.maxCapacity}'
                      : 'Flexible capacity',
                ),
                _heroStat(LucideIcons.clock3, _hoursText(turf)),
              ],
            ),
            if (detailError.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                detailError,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _detailSections() {
    return Obx(() {
      final turf = _turfController.selectedTurf.value ?? widget.initialTurf;

      return Column(
        children: [
          TurfMediaGallery(turf: turf),
          if (turf.description.trim().isNotEmpty)
            SmallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('About Turf'),
                  const SizedBox(height: 8),
                  Text(
                    turf.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          if (turf.pricing != null)
            SmallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Pricing'),
                  const SizedBox(height: 10),
                  InfoRow(
                    label: 'Weekday',
                    value: 'Rs ${_formatAmount(turf.pricing!.weekday)}',
                  ),
                  InfoRow(
                    label: 'Weekend',
                    value: 'Rs ${_formatAmount(turf.pricing!.weekend)}',
                  ),
                  InfoRow(
                    label: 'Peak',
                    value: 'Rs ${_formatAmount(turf.pricing!.peak)}',
                  ),
                  InfoRow(
                    label: 'Surge pricing',
                    value: turf.pricing!.surgeEnabled ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
            ),
          if (turf.amenities.isNotEmpty)
            SmallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Amenities'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: turf.amenities
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              item,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          SmallCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Venue Details'),
                const SizedBox(height: 10),
                InfoRow(label: 'Sport', value: _capitalize(turf.sportType)),
                InfoRow(label: 'Format', value: turf.formatLabel),
                InfoRow(label: 'Location', value: _detailLocation(turf)),
                InfoRow(label: 'Operating hours', value: _hoursText(turf)),
                if (turf.ownerName.trim().isNotEmpty)
                  InfoRow(label: 'Owner', value: turf.ownerName),
                if (turf.ownerBusiness.trim().isNotEmpty)
                  InfoRow(label: 'Business', value: turf.ownerBusiness),
                if (turf.totalBookings > 0)
                  InfoRow(
                    label: 'Past bookings',
                    value: '${turf.totalBookings}',
                  ),
              ],
            ),
          ),
          SmallCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _sectionTitle('Recent Reviews')),
                    _StarRating(
                      rating: turf.rating.toDouble(),
                      size: 13,
                      showValue: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_turfController.reviews.isEmpty)
                  Text(
                    'No reviews yet.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  )
                else
                  ..._turfController.reviews.take(3).map(_reviewTile),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _reviewTile(TurfReviewModel review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.playerName,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              _StarRating(
                rating: review.rating.toDouble(),
                size: 12,
                showValue: true,
              ),
            ],
          ),
          if (review.text.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.text,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.tags
                  .map((tag) => AppBadge(tag, type: BadgeType.green))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.dark,
      ),
    );
  }

  Widget _heroStat(IconData icon, String text) {
    final label = text.trim().isEmpty ? '-' : text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _detailLocation(TurfModel turf) {
    final parts = <String>[
      if (turf.address.trim().isNotEmpty) turf.address,
      if (turf.city.trim().isNotEmpty) turf.city,
    ];
    if (parts.isEmpty) {
      return turf.location.trim().isNotEmpty
          ? turf.location
          : 'Location unavailable';
    }
    return parts.join(', ');
  }

  String _hoursText(TurfModel turf) {
    final hours = turf.operatingHours;
    if (hours == null) {
      return 'Hours unavailable';
    }
    return '${hours.opens} - ${hours.closes}';
  }

  String _capitalize(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }
    final normalized = value.trim().toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _formatAmount(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }

  String _ratingText(num rating, int totalReviews) {
    if (rating <= 0 && totalReviews <= 0) {
      return 'No reviews';
    }
    final ratingLabel = rating > 0 ? rating.toStringAsFixed(1) : '';
    final reviewLabel = totalReviews > 0 ? '($totalReviews)' : '';
    return [ratingLabel, reviewLabel]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const _StarRating({
    required this.rating,
    this.size = 13,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final isFilled = index < filledStars;
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              LucideIcons.star,
              size: size,
              color: isFilled ? AppColors.green : AppColors.border,
            ),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : '-',
            style: GoogleFonts.dmSans(
              fontSize: size - 1,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ],
    );
  }
}

class _TurfHeroLoadingCard extends StatelessWidget {
  const _TurfHeroLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E20), AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            width: 180,
            height: 22,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 10),
          ShimmerBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: 12,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ShimmerBox(
                width: 92,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              ShimmerBox(
                width: 110,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              ShimmerBox(
                width: 96,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
