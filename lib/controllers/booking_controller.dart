import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/booking_create_model.dart';
import '../data/models/booking_model.dart';
import '../data/services/booking_service.dart';

class BookingController extends GetxController {
  final bookings = <BookingModel>[].obs;
  final isLoading = false.obs;
  final isCreateLoading = false.obs;
  final cancelingBookingIds = <int>{}.obs;
  final errorMessage = ''.obs;
  final selectedStatus = 'confirmed'.obs;
  final totalBookings = 0.obs;

  Future<void> loadBookings({String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (status != null && status.trim().isNotEmpty) {
        selectedStatus.value = status.trim();
      }

      final response = await BookingService.fetchBookings(
        status: selectedStatus.value,
      );
      bookings.assignAll(response.bookings);
      totalBookings.value = response.total;
    } catch (e) {
      bookings.clear();
      totalBookings.value = 0;
      errorMessage.value = _readableError(e);
      debugPrint(
        '[BookingController] loadBookings failed: ${errorMessage.value}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<BookingCreateResult> createBooking({
    required int turfId,
    required List<int> slotIds,
    required int playersCount,
    required String sportType,
    String? couponCode,
  }) async {
    try {
      isCreateLoading.value = true;
      final result = await BookingService.createBooking(
        turfId: turfId,
        slotIds: slotIds,
        playersCount: playersCount,
        sportType: sportType,
        couponCode: couponCode,
      );
      if (result.success) {
        await loadBookings(status: selectedStatus.value);
      }
      return result;
    } catch (e) {
      debugPrint(
        '[BookingController] createBooking failed: ${_readableError(e)}',
      );
      return BookingCreateResult(
        success: false,
        message: _readableError(e),
      );
    } finally {
      isCreateLoading.value = false;
    }
  }

  Future<BookingCancelResult> cancelBooking({
    required int bookingId,
    required String reason,
  }) async {
    try {
      cancelingBookingIds.add(bookingId);
      final result = await BookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
      if (result.success) {
        await loadBookings(status: selectedStatus.value);
      }
      return result;
    } catch (e) {
      debugPrint(
        '[BookingController] cancelBooking failed: ${_readableError(e)}',
      );
      return BookingCancelResult(
        success: false,
        message: _readableError(e),
        refundAmount: 0,
      );
    } finally {
      cancelingBookingIds.remove(bookingId);
    }
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }
}
