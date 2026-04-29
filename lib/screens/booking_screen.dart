import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/booking_controller.dart';
import '../controllers/turf_controller.dart';
import '../data/models/booking_create_model.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'matches_screen.dart';
import 'my_bookings_screen.dart';
import 'wallet_razorpay_screen.dart';

class BookingScreen extends StatefulWidget {
  final int turfId;
  final String turfName;
  final String sportType;
  final int pricePerHour;

  const BookingScreen({
    super.key,
    required this.turfId,
    required this.turfName,
    this.sportType = 'cricket',
    this.pricePerHour = 800,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final BookingController _bookingController;
  late final TurfController _turfController;
  late DateTime _selectedDate;
  final List<int> _selectedSlotIds = <int>[];
  int _selectedPeople = 7;
  static const _people = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];

  @override
  void initState() {
    super.initState();
    _bookingController = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    _turfController = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _turfController.loadTurfDetail(widget.turfId);
      _loadSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlayers = _people[_selectedPeople];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(
              label: 'Book Your Slot',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailHeroCard(),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected =
                              _isSameDate(date, _selectedDate);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                                _selectedSlotIds.clear();
                              });
                              _loadSlots();
                            },
                            child: Container(
                              width: 66,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.dark
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E').format(date).toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    DateFormat('MMM').format(date),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.muted2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Time Slots',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap one or more available slots to book them together.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      if (_turfController.isSlotsLoading.value) {
                        return const _BookingSlotsLoadingState();
                      }

                      if (_turfController.slotsErrorMessage.value.isNotEmpty &&
                          _turfController.slots.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _turfController.slotsErrorMessage.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        );
                      }

                      if (_turfController.slots.isEmpty) {
                        return Text(
                          'No slots available for this date.',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _turfController.slots.map((slot) {
                          final canSelect = _canSelectSlot(slot);
                          final isSelected = _selectedSlotIds.contains(slot.id);
                          return GestureDetector(
                            onTap: !canSelect
                                ? null
                                : () => setState(() {
                                    if (isSelected) {
                                      _selectedSlotIds.remove(slot.id);
                                    } else {
                                      _selectedSlotIds.add(slot.id);
                                    }
                                  }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: !canSelect
                                    ? AppColors.bg
                                    : isSelected
                                        ? AppColors.dark
                                        : AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.dark
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.label,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: !canSelect
                                          ? AppColors.muted2
                                          : isSelected
                                              ? Colors.white
                                              : AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    !slot.isAvailable
                                        ? 'Unavailable'
                                        : _isSlotExpired(slot)
                                            ? 'Time passed'
                                            : slot.price > 0
                                        ? 'Rs ${_formatAmount(slot.price)}'
                                        : 'Available',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: !canSelect
                                          ? AppColors.muted2
                                          : isSelected
                                              ? Colors.white70
                                              : AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 18),
                    Text(
                      'No. of People',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: _people.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedPeople;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeople = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.dark
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _people[index].toString().padLeft(2, '0'),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.dark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _detailSections(),
                    const SizedBox(height: 18),
                    _summaryCard(selectedPlayers),
                    Obx(
                      () => AppButton(
                        label: _bookingController.isCreateLoading.value
                            ? 'Confirming...'
                            : 'Confirm Booking',
                        trailingIcon: _bookingController.isCreateLoading.value
                            ? null
                            : Icons.arrow_forward,
                        onTap: _bookingController.isCreateLoading.value
                            ? null
                            : () => _confirmBooking(
                                  context,
                                  selectedPlayers: selectedPlayers,
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Create Match for this Slot',
                      isOutline: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateMatchScreen(
                            initialTurf: TurfModel(
                              id: widget.turfId,
                              name: widget.turfName,
                              format: '',
                              city: '',
                              address: '',
                              location: widget.turfName,
                              sportType: widget.sportType,
                              description: '',
                              maxCapacity: 0,
                              pricePerHour: widget.pricePerHour,
                              rating: 0,
                              totalReviews: 0,
                              totalBookings: 0,
                              isAvailable: true,
                              amenities: const <String>[],
                              ownerName: '',
                              ownerBusiness: '',
                            ),
                          ),
                        ),
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

  Future<void> _confirmBooking(
    BuildContext context, {
    required int selectedPlayers,
  }) async {
    _selectedSlotIds.removeWhere(
      (slotId) => !_turfController.slots.any(
        (slot) => slot.id == slotId && _canSelectSlot(slot),
      ),
    );
    if (_selectedSlotIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one available slot.');
      return;
    }
    final result = await _bookingController.createBooking(
      turfId: widget.turfId,
      slotIds: List<int>.from(_selectedSlotIds),
      playersCount: selectedPlayers,
      sportType: widget.sportType,
      couponCode: null,
    );

    if (!mounted) {
      return;
    }

    if (result.success) {
      Get.snackbar(
        'Success',
        result.message.isNotEmpty
            ? result.message
            : 'Booking confirmed successfully.',
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );
      return;
    }

    if (result.hasInsufficientWallet ||
        result.message.toLowerCase().contains('insufficient wallet balance')) {
      await _showInsufficientWalletDialog(context, result);
      return;
    }

    Get.snackbar(
      'Error',
      result.message.isNotEmpty
          ? result.message
          : 'Unable to confirm booking right now.',
    );
  }

  Future<void> _showInsufficientWalletDialog(
    BuildContext context,
    BookingCreateResult result,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: AppColors.white,
          title: Text(
            'Wallet Balance Low',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'Please top up your wallet to continue.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            Column(
              children: [
                AppButton(
                  label: 'Top Up Wallet',
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WalletRazorpayScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Maybe Later',
                  isOutline: true,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSlots() async {
    await _turfController.loadAvailableSlots(
      turfId: widget.turfId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedSlotIds.clear();
    });
  }

  Widget _detailHeroCard() {
    return Obx(() {
      final turf = _turfController.selectedTurf.value;
      final isLoading = _turfController.isDetailLoading.value && turf == null;
      final detailError = _turfController.detailErrorMessage.value;

      if (isLoading) {
        return const _BookingHeroLoadingCard();
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
                        turf?.name ?? widget.turfName,
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
                          color: Colors.white.withOpacity(0.8),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppBadge(
                  turf?.formatLabel ?? 'Turf',
                  type: BadgeType.dark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _heroStat(
                  LucideIcons.star,
                  turf != null
                      ? '${turf.ratingLabel} ${turf.reviewLabel}'
                      : 'New',
                ),
                _heroStat(
                  LucideIcons.users,
                  turf?.maxCapacity != null && turf!.maxCapacity > 0
                      ? 'Up to ${turf.maxCapacity}'
                      : 'Flexible capacity',
                ),
                _heroStat(
                  LucideIcons.clock3,
                  _hoursText(turf),
                ),
              ],
            ),
            if (detailError.isNotEmpty && turf == null) ...[
              const SizedBox(height: 10),
              Text(
                detailError,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
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
      final turf = _turfController.selectedTurf.value;
      if (turf == null) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          if (turf.description.trim().isNotEmpty)
            SmallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Turf',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
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
                  Text(
                    'Pricing',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
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
                  Text(
                    'Amenities',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
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
                Text(
                  'Venue Details',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 10),
                InfoRow(label: 'Sport', value: _capitalize(turf.sportType)),
                InfoRow(label: 'Format', value: turf.formatLabel),
                InfoRow(
                  label: 'Operating hours',
                  value: _hoursText(turf),
                ),
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
          if (_turfController.reviews.isNotEmpty)
            SmallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Reviews',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._turfController.reviews.take(3).map(
                        (review) => Padding(
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
                                  Text(
                                    review.rating.toStringAsFixed(1),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.text,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  height: 1.5,
                                ),
                              ),
                              if (review.tags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: review.tags
                                      .map(
                                        (tag) => AppBadge(
                                          tag,
                                          type: BadgeType.green,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _heroStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
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

  Widget _summaryCard(int selectedPlayers) {
    final slots = _selectedSlots;
    final amount = slots.isEmpty
        ? 0.0
        : slots.fold<double>(
            0,
            (total, slot) => total + slot.price.toDouble(),
          );
    final slotText = slots.isEmpty
        ? 'Select slot(s)'
        : slots.map((slot) => slot.label).join(', ');

    return SmallCard(
      child: Column(
        children: [
          InfoRow(label: 'Turf', value: widget.turfName),
          InfoRow(
            label: 'Sport',
            value: _capitalize(widget.sportType),
          ),
          InfoRow(
            label: 'Date & Time',
            value: '${DateFormat('dd MMM yyyy').format(_selectedDate)}, $slotText',
          ),
          InfoRow(
            label: 'Players',
            value: '$selectedPlayers selected',
          ),
          const AppDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              Text(
                'Rs ${_formatAmount(amount)}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<TurfSlotModel> get _selectedSlots {
    return _turfController.slots
        .where((slot) => _selectedSlotIds.contains(slot.id))
        .toList();
  }

  bool _canSelectSlot(TurfSlotModel slot) {
    return slot.isAvailable && !_isSlotExpired(slot);
  }

  bool _isSlotExpired(TurfSlotModel slot) {
    if (!_isSameDate(_selectedDate, DateTime.now())) {
      return false;
    }

    final slotStart = _slotStartDateTime(slot);
    if (slotStart == null) {
      return false;
    }

    return !slotStart.isAfter(DateTime.now());
  }

  DateTime? _slotStartDateTime(TurfSlotModel slot) {
    final startText = _extractStartTime(slot.label);
    if (startText == null) {
      return null;
    }

    for (final pattern in const [
      'HH:mm:ss',
      'HH:mm',
      'H:mm',
      'hh:mm a',
      'h:mm a',
      'h a',
    ]) {
      try {
        final parsedTime = DateFormat(pattern).parseStrict(startText);
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          parsedTime.hour,
          parsedTime.minute,
          parsedTime.second,
        );
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  String? _extractStartTime(String label) {
    final parts = label.split(' - ');
    if (parts.isNotEmpty && parts.first.trim().isNotEmpty) {
      return parts.first.trim();
    }

    final match = RegExp(
      r'(\d{1,2}:\d{2}(?::\d{2})?\s?[APMapm]{0,2}|\d{1,2}\s?[APMapm]{2})',
    ).firstMatch(label);
    return match?.group(0)?.trim();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _detailLocation(TurfModel? turf) {
    if (turf == null) {
      return 'Loading turf details...';
    }
    final parts = <String>[
      if (turf.address.trim().isNotEmpty) turf.address,
      if (turf.city.trim().isNotEmpty) turf.city,
    ];
    if (parts.isEmpty) {
      return 'Location unavailable';
    }
    return parts.join(', ');
  }

  String _hoursText(TurfModel? turf) {
    final hours = turf?.operatingHours;
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
}

class _BookingSlotsLoadingState extends StatelessWidget {
  const _BookingSlotsLoadingState();

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.greenLt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.clock3,
                  size: 16,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading slots',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Checking the latest availability for this date.',
                      style: GoogleFonts.dmSans(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              6,
              (index) => ShimmerBox(
                width: index.isEven ? 116 : 104,
                height: 58,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingHeroLoadingCard extends StatelessWidget {
  const _BookingHeroLoadingCard();

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
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
