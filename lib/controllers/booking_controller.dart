import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'wallet_controller.dart';
import '../data/models/booking_create_model.dart';
import '../data/models/booking_model.dart';
import '../data/services/booking_service.dart';

class BookingController extends GetxController {
  final bookings = <BookingModel>[].obs;
  final bookingPlayers = <BookingPlayerModel>[].obs;
  final isLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  final isCreateLoading = false.obs;
  final isInviteLoading = false.obs;
  final isPlayersLoading = false.obs;
  final cancelingBookingIds = <int>{}.obs;
  final errorMessage = ''.obs;
  final bookingPlayersErrorMessage = ''.obs;
  final selectedStatus = 'confirmed'.obs;
  final totalBookings = 0.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;

  bool get hasMoreBookings => currentPage.value < lastPage.value;

  Future<void> loadBookings({String? status, bool loadMore = false}) async {
    try {
      final nextPage = loadMore ? currentPage.value + 1 : 1;
      if (loadMore) {
        if (isLoadMoreLoading.value || !hasMoreBookings) {
          return;
        }
        isLoadMoreLoading.value = true;
      } else {
        isLoading.value = true;
        errorMessage.value = '';
      }
      if (!loadMore && status != null && status.trim().isNotEmpty) {
        selectedStatus.value = status.trim();
      }

      final response = await BookingService.fetchBookings(
        status: selectedStatus.value,
        page: nextPage,
      );
      if (loadMore) {
        bookings.addAll(response.bookings);
      } else {
        bookings.assignAll(response.bookings);
      }
      totalBookings.value = response.total;
      currentPage.value = response.currentPage;
      lastPage.value = response.lastPage;
    } catch (e) {
      if (!loadMore) {
        bookings.clear();
        totalBookings.value = 0;
        currentPage.value = 1;
        lastPage.value = 1;
      }
      errorMessage.value = _readableError(e);
      debugPrint(
        '[BookingController] loadBookings failed: ${errorMessage.value}',
      );
    } finally {
      if (loadMore) {
        isLoadMoreLoading.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<BookingCreateResult> createBooking({
    required int turfId,
    required List<int> slotIds,
    required int playersCount,
    required String sportType,
    String? couponCode,
  }) async {
    if (turfId <= 0) {
      return const BookingCreateResult(
        success: false,
        message: 'Invalid turf selected.',
      );
    }
    if (slotIds.where((id) => id > 0).isEmpty) {
      return const BookingCreateResult(
        success: false,
        message: 'Please select at least one valid slot.',
      );
    }
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
        await Future.wait([
          loadBookings(status: selectedStatus.value),
          _refreshWalletState(),
        ]);
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
        await Future.wait([
          loadBookings(status: selectedStatus.value),
          _refreshWalletState(),
        ]);
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

  Future<BookingInviteLinkResult> loadBookingInviteLink(int bookingId) async {
    try {
      isInviteLoading.value = true;
      return await BookingService.fetchBookingInviteLink(bookingId: bookingId);
    } catch (e) {
      return BookingInviteLinkResult(
        success: false,
        message: _readableError(e),
        code: '',
        inviteLink: '',
        whatsappUrl: '',
      );
    } finally {
      isInviteLoading.value = false;
    }
  }

  Future<BookingCreateResult> joinBookingByCode(String code) async {
    try {
      isCreateLoading.value = true;
      final result = await BookingService.joinBookingByCode(code: code);
      if (result.success) {
        await loadBookings(status: selectedStatus.value);
      }
      return result;
    } catch (e) {
      return BookingCreateResult(
        success: false,
        message: _readableError(e),
      );
    } finally {
      isCreateLoading.value = false;
    }
  }

  Future<void> loadBookingPlayers(int bookingId) async {
    try {
      isPlayersLoading.value = true;
      bookingPlayersErrorMessage.value = '';
      bookingPlayers.clear();
      final result = await BookingService.fetchBookingPlayers(bookingId: bookingId);
      bookingPlayers.assignAll(result);
    } catch (e) {
      bookingPlayers.clear();
      bookingPlayersErrorMessage.value = _readableError(e);
    } finally {
      isPlayersLoading.value = false;
    }
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  Future<void> _refreshWalletState() async {
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    await Future.wait([
      walletController.loadWallet(),
      walletController.loadTransactions(),
    ]);
  }
}
