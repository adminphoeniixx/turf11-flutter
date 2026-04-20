import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/booking_create_model.dart';
import '../models/booking_model.dart';

class BookingService {
  static Future<BookingListResponse> fetchBookings({
    String status = 'confirmed',
  }) async {
    final res = await ApiClient.get(
      ApiConstants.bookings,
      queryParameters: {
        if (status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return BookingListResponse.fromJson(data);
    }
    if (data is Map) {
      return BookingListResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const BookingListResponse(
      bookings: <BookingModel>[],
      currentPage: 1,
      lastPage: 1,
      total: 0,
    );
  }

  static Future<BookingCreateResult> createBooking({
    required int turfId,
    required List<int> slotIds,
    required int playersCount,
    required String sportType,
    String? couponCode,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.bookings,
      data: {
        'turf_id': turfId,
        'slot_ids': slotIds,
        'players_count': playersCount,
        'sport_type': sportType,
        'coupon_code': couponCode,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return BookingCreateResult.fromJson(data);
    }
    if (data is Map) {
      return BookingCreateResult.fromJson(Map<String, dynamic>.from(data));
    }
    return const BookingCreateResult(
      success: false,
      message: 'Unexpected booking response received.',
    );
  }

  static Future<BookingCancelResult> cancelBooking({
    required int bookingId,
    required String reason,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.cancelBooking(bookingId),
      data: {
        'reason': reason,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return BookingCancelResult.fromJson(data);
    }
    if (data is Map) {
      return BookingCancelResult.fromJson(Map<String, dynamic>.from(data));
    }
    return const BookingCancelResult(
      success: false,
      message: 'Unexpected cancel booking response received.',
      refundAmount: 0,
    );
  }
}
