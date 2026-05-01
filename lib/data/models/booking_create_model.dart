class BookingCreateResult {
  final bool success;
  final String message;
  final num walletBalance;
  final num requiredAmount;
  final int bookingId;
  final String bookingCode;
  final String inviteCode;
  final String inviteLink;
  final String whatsappUrl;

  const BookingCreateResult({
    required this.success,
    required this.message,
    this.walletBalance = 0,
    this.requiredAmount = 0,
    this.bookingId = 0,
    this.bookingCode = '',
    this.inviteCode = '',
    this.inviteLink = '',
    this.whatsappUrl = '',
  });

  bool get hasInsufficientWallet =>
      !success && requiredAmount > walletBalance;

  factory BookingCreateResult.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']);
    final booking = _readMap(json['booking']);
    final merged = <String, dynamic>{
      ...json,
      ...data,
      ...booking,
    };

    return BookingCreateResult(
      success: _readBool(merged['success']),
      message: _readString(
        merged['message'],
        fallback: _readString(
          data['message'],
          fallback: _readString(
            booking['message'],
          ),
        ),
      ),
      walletBalance: _readNum(
        merged['wallet_balance'],
        fallback: _readNum(data['wallet_balance']),
      ),
      requiredAmount: _readNum(
        merged['required'],
        fallback: _readNum(data['required']),
      ),
      bookingId: _readInt(merged['id'], fallback: _readInt(booking['id'])),
      bookingCode: _readString(
        merged['booking_code'],
        fallback: _readString(booking['booking_code']),
      ),
      inviteCode: _readString(
        merged['invite_code'],
        fallback: _readString(booking['invite_code']),
      ),
      inviteLink: _readString(
        merged['invite_link'],
        fallback: _readString(booking['invite_link']),
      ),
      whatsappUrl: _readString(
        merged['whatsapp_url'],
        fallback: _readString(booking['whatsapp_url']),
      ),
    );
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
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

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static num _readNum(dynamic value, {num fallback = 0}) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
