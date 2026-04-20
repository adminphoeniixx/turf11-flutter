class BookingCreateResult {
  final bool success;
  final String message;
  final num walletBalance;
  final num requiredAmount;

  const BookingCreateResult({
    required this.success,
    required this.message,
    this.walletBalance = 0,
    this.requiredAmount = 0,
  });

  bool get hasInsufficientWallet =>
      !success && walletBalance > 0 && requiredAmount > walletBalance;

  factory BookingCreateResult.fromJson(Map<String, dynamic> json) {
    return BookingCreateResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      walletBalance: _readNum(json['wallet_balance']),
      requiredAmount: _readNum(json['required']),
    );
  }

  static num _readNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
