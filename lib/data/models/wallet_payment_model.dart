class WalletTopupOrder {
  final String keyId;
  final String orderId;
  final int amount;
  final String currency;
  final String name;
  final String description;
  final String contact;
  final String email;
  final Map<String, dynamic> notes;

  const WalletTopupOrder({
    required this.keyId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.name,
    required this.description,
    required this.contact,
    required this.email,
    required this.notes,
  });

  factory WalletTopupOrder.fromJson(Map<String, dynamic> json) {
    final root = _readMap(json['data']).isNotEmpty ? _readMap(json['data']) : json;
    final prefill = _readMap(root['prefill']);
    final notes = _readMap(root['notes']);

    return WalletTopupOrder(
      keyId: _readString(
        root['key'] ?? root['key_id'] ?? root['razorpay_key'],
      ),
      orderId: _readString(
        root['order_id'] ?? root['id'] ?? root['razorpay_order_id'],
      ),
      amount: _readInt(root['amount']),
      currency: _readString(root['currency'], fallback: 'INR'),
      name: _readString(
        root['name'] ?? root['merchant_name'] ?? root['app_name'],
        fallback: 'Turf11',
      ),
      description: _readString(
        root['description'],
        fallback: 'Wallet top-up',
      ),
      contact: _readString(
        prefill['contact'] ?? root['contact'] ?? root['phone'],
      ),
      email: _readString(
        prefill['email'] ?? root['email'],
      ),
      notes: notes,
    );
  }

  Map<String, dynamic> toCheckoutOptions({
    required String fallbackKeyId,
  }) {
    return {
      'key': keyId.isNotEmpty ? keyId : fallbackKeyId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        if (contact.isNotEmpty) 'contact': contact,
        if (email.isNotEmpty) 'email': email,
      },
      if (notes.isNotEmpty) 'notes': notes,
      'theme': {
        'color': '#1F6F43',
      },
    };
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

  static String _readString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
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
}
