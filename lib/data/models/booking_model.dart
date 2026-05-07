class BookingModel {
  final int id;
  final int turfId;
  final String bookingCode;
  final String inviteCode;
  final String turfName;
  final String date;
  final String time;
  final int playersCount;
  final String sportType;
  final num amount;
  final String bookingStatus;
  final String paymentStatus;
  final bool canCancel;

  const BookingModel({
    required this.id,
    required this.turfId,
    required this.bookingCode,
    required this.inviteCode,
    required this.turfName,
    required this.date,
    required this.time,
    required this.playersCount,
    required this.sportType,
    required this.amount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.canCancel,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final dataMap = _readMap(json['data']);
    final bookingMap = _readMap(json['booking']);
    final bookingDataMap = _readMap(bookingMap['data']);
    final detailMap = _readMap(json['booking_detail']);
    final dataDetailMap = _readMap(dataMap['booking_detail']);
    final merged = <String, dynamic>{
      ...dataMap,
      ...bookingDataMap,
      ...bookingMap,
      ...dataDetailMap,
      ...detailMap,
      ...json,
    };
    final turfMap = _readMap(merged['turf']);
    final slotMap = _readMap(merged['slot']);
    return BookingModel(
      id: _readInt(merged['id'] ?? merged['booking_id']),
      turfId: _readInt(
        merged['turf_id'] ??
            merged['turfId'] ??
            merged['venue_id'] ??
            merged['ground_id'] ??
            turfMap['id'] ??
            turfMap['turf_id'] ??
            slotMap['turf_id'],
      ),
      bookingCode: (merged['booking_code'] ?? '').toString(),
      inviteCode: (merged['invite_code'] ?? '').toString(),
      turfName: (merged['turf_name'] ?? turfMap['name'] ?? '').toString(),
      date: (merged['date'] ?? '').toString(),
      time: (merged['time'] ?? '').toString(),
      playersCount: _readInt(merged['players_count']),
      sportType: (merged['sport_type'] ?? '').toString(),
      amount: _readNum(merged['amount']),
      bookingStatus: (merged['booking_status'] ?? merged['status'] ?? '').toString(),
      paymentStatus: (merged['payment_status'] ?? '').toString(),
      canCancel: _readBool(merged['can_cancel']),
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

class BookingInviteLinkResult {
  final bool success;
  final String message;
  final String code;
  final String inviteLink;
  final String whatsappUrl;

  const BookingInviteLinkResult({
    required this.success,
    required this.message,
    required this.code,
    required this.inviteLink,
    required this.whatsappUrl,
  });

  factory BookingInviteLinkResult.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']);
    final merged = <String, dynamic>{...json, ...data};
    return BookingInviteLinkResult(
      success: _readBool(merged['success']),
      message: _readString(merged['message']),
      code: _readString(merged['code'], fallback: _readString(merged['invite_code'])),
      inviteLink: _readString(merged['invite_link']),
      whatsappUrl: _readString(merged['whatsapp_url']),
    );
  }
}

class BookingPlayerModel {
  final int id;
  final String name;
  final String phone;
  final String city;

  const BookingPlayerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
  });

  factory BookingPlayerModel.fromJson(Map<String, dynamic> json) {
    final player = _readMap(json['player']);
    final user = _readMap(json['user']);
    final data = _readMap(json['data']);
    final merged = <String, dynamic>{...data, ...player, ...user, ...json};
    return BookingPlayerModel(
      id: _readInt(
        merged['player_id'] ?? merged['user_id'] ?? merged['id'],
      ),
      name: _readString(
        merged['name'] ?? merged['player_name'] ?? merged['full_name'],
        fallback: 'Player',
      ),
      phone: _readString(
        merged['phone'] ?? merged['phone_number'] ?? merged['mobile'],
      ),
      city: _readString(
        merged['city'] ?? merged['location'] ?? merged['area'],
      ),
    );
  }

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'P';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
    final rootData = _readMap(json['data']);
    final root = rootData.isNotEmpty ? <String, dynamic>{...json, ...rootData} : json;
    final bookingsRoot = root['bookings'] ?? root['data'] ?? root['items'];
    final bookingsMap = bookingsRoot is Map<String, dynamic>
        ? bookingsRoot
        : <String, dynamic>{};
    final list = bookingsRoot is List ? bookingsRoot : bookingsMap['data'];

    return BookingListResponse(
      bookings: list is List
          ? list
              .whereType<Map>()
              .map((item) => BookingModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const <BookingModel>[],
      currentPage: BookingModel._readInt(bookingsMap['current_page']) == 0
          ? 1
          : BookingModel._readInt(bookingsMap['current_page']),
      lastPage: BookingModel._readInt(bookingsMap['last_page']) == 0
          ? 1
          : BookingModel._readInt(bookingsMap['last_page']),
      total: BookingModel._readInt(bookingsMap['total']) == 0 && list is List
          ? list.length
          : BookingModel._readInt(bookingsMap['total']),
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

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _readString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

bool _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
