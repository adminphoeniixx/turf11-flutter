class WalletResponse {
  final bool success;
  final double walletBalance;
  final int rewardPoints;
  final List<WalletTransaction> transactions;

  const WalletResponse({
    required this.success,
    required this.walletBalance,
    required this.rewardPoints,
    required this.transactions,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    final transactionsRaw = json['transactions'];
    final transactionList = _extractTransactions(transactionsRaw);

    return WalletResponse(
      success: _readBool(json['success']),
      walletBalance: _readDouble(json['wallet_balance']),
      rewardPoints: _readInt(json['reward_points']),
      transactions: transactionList,
    );
  }

  static List<WalletTransaction> _extractTransactions(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => WalletTransaction.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }

    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => WalletTransaction.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    }

    return const <WalletTransaction>[];
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}

class WalletTransaction {
  final int id;
  final String txnCode;
  final String type;
  final String direction;
  final double amount;
  final double balanceAfter;
  final String description;
  final String createdAt;
  final String status;
  final String performedByName;

  const WalletTransaction({
    required this.id,
    required this.txnCode,
    required this.type,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.performedByName,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _readInt(json['id']),
      txnCode: (json['txn_code'] ?? '').toString(),
      type: (json['type'] ?? json['transaction_type'] ?? '').toString(),
      direction: (json['direction'] ?? '').toString(),
      amount: _readDouble(json['amount']),
      balanceAfter: _readDouble(json['balance_after']),
      description: (json['description'] ?? json['message'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['date'] ?? '').toString(),
      status: (json['status'] ?? json['gateway_status'] ?? '').toString(),
      performedByName: (json['performed_by_name'] ?? '').toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
