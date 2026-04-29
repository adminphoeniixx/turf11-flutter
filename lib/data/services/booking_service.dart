import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/booking_create_model.dart';
import '../models/booking_model.dart';

class BookingService {
  static Future<BookingListResponse> fetchBookings({
    String status = 'confirmed',
    int page = 1,
  }) async {
    final res = await ApiClient.get(
      ApiConstants.bookings,
      queryParameters: {
        if (status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
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
    final cleanedSlotIds = slotIds.where((id) => id > 0).toSet().toList();
    final payload = <String, dynamic>{
      'turf_id': turfId,
      'slot_ids': cleanedSlotIds,
      'players_count': playersCount,
      'sport_type': sportType.trim(),
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'coupon_code': couponCode.trim(),
    };

    final res = await ApiClient.post(
      ApiConstants.bookings,
      data: payload,
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

  static Future<BookingInviteLinkResult> fetchBookingInviteLink({
    required int bookingId,
  }) async {
    final res = await ApiClient.get(ApiConstants.bookingInviteLink(bookingId));
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return BookingInviteLinkResult.fromJson(data);
    }
    if (data is Map) {
      return BookingInviteLinkResult.fromJson(Map<String, dynamic>.from(data));
    }
    return const BookingInviteLinkResult(
      success: false,
      message: 'Unexpected invite response received.',
      code: '',
      inviteLink: '',
      whatsappUrl: '',
    );
  }

  static Future<List<BookingPlayerModel>> fetchBookingPlayers({
    required int bookingId,
  }) async {
    final res = await ApiClient.get(ApiConstants.bookingPlayers(bookingId));
    final data = res.data;
    final root = data is Map<String, dynamic>
        ? data
        : data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};
    final candidates = [
      root['players'],
      root['booking_players'],
      root['participants'],
      root['members'],
      root['data'],
      data,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map(
              (item) => BookingPlayerModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
      if (candidate is Map<String, dynamic>) {
        final nested =
            candidate['data'] ??
            candidate['players'] ??
            candidate['booking_players'] ??
            candidate['participants'] ??
            candidate['members'] ??
            candidate['items'];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map(
                (item) => BookingPlayerModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }
    }

    return const <BookingPlayerModel>[];
  }
}
