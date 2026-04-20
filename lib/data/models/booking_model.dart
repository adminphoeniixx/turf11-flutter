class BookingModel {
  final int id;
  final String bookingCode;
  final String turfName;
  final String date;
  final String time;
  final int playersCount;
  final String sportType;
  final num amount;
  final String bookingStatus;
  final String paymentStatus;

  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.turfName,
    required this.date,
    required this.time,
    required this.playersCount,
    required this.sportType,
    required this.amount,
    required this.bookingStatus,
    required this.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _readInt(json['id']),
      bookingCode: (json['booking_code'] ?? '').toString(),
      turfName: (json['turf_name'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      playersCount: _readInt(json['players_count']),
      sportType: (json['sport_type'] ?? '').toString(),
      amount: _readNum(json['amount']),
      bookingStatus: (json['booking_status'] ?? '').toString(),
      paymentStatus: (json['payment_status'] ?? '').toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num _readNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BookingListResponse {
  final List<BookingModel> bookings;
  final int currentPage;
  final int lastPage;
  final int total;

  const BookingListResponse({
    required this.bookings,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    final bookingsRoot = json['bookings'];
    final bookingsMap = bookingsRoot is Map<String, dynamic>
        ? bookingsRoot
        : <String, dynamic>{};
    final list = bookingsMap['data'];

    return BookingListResponse(
      bookings: list is List
          ? list
              .whereType<Map>()
              .map((item) => BookingModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const <BookingModel>[],
      currentPage: BookingModel._readInt(bookingsMap['current_page']),
      lastPage: BookingModel._readInt(bookingsMap['last_page']),
      total: BookingModel._readInt(bookingsMap['total']),
    );
  }
}

class BookingCancelResult {
  final bool success;
  final String message;
  final num refundAmount;

  const BookingCancelResult({
    required this.success,
    required this.message,
    required this.refundAmount,
  });

  factory BookingCancelResult.fromJson(Map<String, dynamic> json) {
    return BookingCancelResult(
      success: _readBool(json['success']),
      message: (json['message'] ?? '').toString(),
      refundAmount: BookingModel._readNum(json['refund_amount']),
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
