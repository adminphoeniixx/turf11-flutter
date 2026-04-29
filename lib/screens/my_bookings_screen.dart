import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/booking_controller.dart';
import '../data/models/booking_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late final BookingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.loadBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'My Bookings', onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings',
                    style: GoogleFonts.dmSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.totalBookings.value > 0
                          ? '${controller.totalBookings.value} confirmed bookings found.'
                          : 'View your confirmed turf bookings here.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                final bookings = controller.bookings;
                final errorMessage = controller.errorMessage.value;

                if (isLoading && bookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (errorMessage.isNotEmpty && bookings.isEmpty) {
                  return _BookingsMessage(
                    icon: LucideIcons.alertCircle,
                    title: 'Unable to load bookings',
                    subtitle: errorMessage,
                  );
                }

                if (bookings.isEmpty) {
                  return const _BookingsMessage(
                    icon: LucideIcons.calendar,
                    title: 'No confirmed bookings yet',
                    subtitle:
                        'Once a booking is confirmed, it will appear here.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: () => controller.loadBookings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: bookings.length + (controller.hasMoreBookings ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= bookings.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Obx(
                            () => AppButton(
                              label: controller.isLoadMoreLoading.value
                                  ? 'Loading...'
                                  : 'Load More',
                              isOutline: true,
                              onTap: controller.isLoadMoreLoading.value
                                  ? null
                                  : () => controller.loadBookings(loadMore: true),
                            ),
                          ),
                        );
                      }
                      final booking = bookings[index];
                      final isCanceling = controller.cancelingBookingIds.contains(
                        booking.id,
                      );
                      return _BookingCard(
                        booking: booking,
                        isCanceling: isCanceling,
                        onCancel: () => _showCancelBookingSheet(booking),
                        onInvite: () => _showInviteLinkSheet(booking),
                        onPlayers: () => _showPlayersSheet(booking),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelBookingSheet(BookingModel booking) async {
    final reasonController = TextEditingController(text: 'Changed plans');
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancel Booking',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will cancel ${booking.bookingCode.isEmpty ? 'your booking' : booking.bookingCode}.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Tell us why you are cancelling',
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted2,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Keep Booking',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final reason =
                                        reasonController.text.trim().isEmpty
                                            ? 'Changed plans'
                                            : reasonController.text.trim();

                                    setModalState(() {
                                      isSubmitting = true;
                                    });
                                    final result =
                                        await controller.cancelBooking(
                                      bookingId: booking.id,
                                      reason: reason,
                                    );

                                    if (!mounted) {
                                      return;
                                    }

                                    Navigator.of(sheetContext).pop();
                                    if (result.success) {
                                      _showCancelSuccessSheet(result);
                                    } else {
                                      Get.snackbar(
                                        'Cancel Failed',
                                        result.message,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Cancel Booking',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showCancelSuccessSheet(BookingCancelResult result) async {
    final refundAmount = _formatAmount(result.refundAmount);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  'Booking Cancelled',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.message,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Refund to Wallet',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rs $refundAmount',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInviteLinkSheet(BookingModel booking) async {
    final invite = await controller.loadBookingInviteLink(booking.id);
    if (!mounted) {
      return;
    }
    if (!invite.success &&
        invite.code.isEmpty &&
        invite.inviteLink.isEmpty &&
        invite.whatsappUrl.isEmpty) {
      Get.snackbar(
        'Error',
        invite.message.isNotEmpty ? invite.message : 'Unable to load invite details.',
      );
      return;
    }

    final shareText = [
      if (invite.code.isNotEmpty) 'Join my booking with code: ${invite.code}',
      if (invite.inviteLink.isNotEmpty) invite.inviteLink,
    ].join('\n');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Invite',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                _InviteInfoRow(label: 'Code', value: invite.code),
                _InviteInfoRow(label: 'Invite Link', value: invite.inviteLink),
                if (invite.whatsappUrl.isNotEmpty)
                  _InviteInfoRow(label: 'WhatsApp URL', value: invite.whatsappUrl),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'WhatsApp',
                        onTap: invite.whatsappUrl.isEmpty
                            ? null
                            : () async {
                                final uri = Uri.tryParse(invite.whatsappUrl);
                                if (uri == null) {
                                  Get.snackbar('Error', 'WhatsApp link is invalid.');
                                  return;
                                }
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Share',
                        isOutline: true,
                        onTap: () => SharePlus.instance.share(
                          ShareParams(text: shareText),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Copy Code',
                        isOutline: true,
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: invite.code));
                          Get.snackbar('Copied', 'Booking code copied.');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Copy Link',
                        isOutline: true,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: invite.inviteLink.isNotEmpty
                                  ? invite.inviteLink
                                  : invite.code,
                            ),
                          );
                          Get.snackbar('Copied', 'Booking invite copied.');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlayersSheet(BookingModel booking) async {
    await controller.loadBookingPlayers(booking.id);
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Obx(() {
          final isLoading = controller.isPlayersLoading.value;
          final players = controller.bookingPlayers;
          final error = controller.bookingPlayersErrorMessage.value;
          return FractionallySizedBox(
            heightFactor: 0.78,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Joined Players',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    players.isEmpty
                        ? 'Players who join this booking will appear here.'
                        : '${players.length} player${players.length == 1 ? '' : 's'} joined this booking.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (error.isNotEmpty) {
                          return Center(
                            child: Text(
                              error,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                          );
                        }
                        if (players.isEmpty) {
                          return Center(
                            child: Text(
                              'No joined players found yet.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: players.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final player = players[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  AppAvatar(initials: player.initials, size: 42),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          [
                                            if (player.city.isNotEmpty) player.city,
                                            if (player.phone.isNotEmpty) player.phone,
                                          ].join(' | '),
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
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  String _formatAmount(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isCanceling;
  final VoidCallback onCancel;
  final VoidCallback onInvite;
  final VoidCallback onPlayers;

  const _BookingCard({
    required this.booking,
    required this.isCanceling,
    required this.onCancel,
    required this.onInvite,
    required this.onPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.greenLt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  LucideIcons.checkCircle,
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
                      booking.turfName,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookingCode.isEmpty
                          ? 'Booking #${booking.id}'
                          : booking.bookingCode,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                _capitalize(booking.bookingStatus),
                type: BadgeType.green,
              ),
            ],
          ),
          const SizedBox(height: 14),
          InfoRow(label: 'Date', value: booking.date),
          InfoRow(label: 'Time', value: booking.time),
          InfoRow(
            label: 'Sport',
            value: _capitalize(booking.sportType),
          ),
          InfoRow(
            label: 'Players',
            value: '${booking.playersCount}',
          ),
          InfoRow(
            label: 'Payment',
            value: _capitalize(booking.paymentStatus),
          ),
          const AppDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Paid',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rs ${_formatAmount(booking.amount)}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          if (booking.bookingStatus.trim().toLowerCase() == 'confirmed') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onInvite,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dark,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(LucideIcons.share2, size: 16),
                    label: Text(
                      'Invite',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPlayers,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dark,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(LucideIcons.users, size: 16),
                    label: Text(
                      'Players',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCanceling ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isCanceling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.red,
                          ),
                        ),
                      )
                    : const Icon(LucideIcons.xCircle, size: 16),
                label: Text(
                  isCanceling ? 'Cancelling...' : 'Cancel Booking',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '-';
    }
    return normalized[0].toUpperCase() + normalized.substring(1).toLowerCase();
  }

  String _formatAmount(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }
}

class _BookingsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BookingsMessage({
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.green, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
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

class _InviteInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InviteInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}
