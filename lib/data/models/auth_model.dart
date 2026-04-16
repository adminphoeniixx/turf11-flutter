class AuthResponse {
  final String token;
  final String message;

  AuthResponse({
    required this.token,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedData = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return AuthResponse(
      token: (json['token'] ??
              json['access_token'] ??
              nestedData['token'] ??
              nestedData['access_token'] ??
              "")
          .toString(),
      message: (json['message'] ?? nestedData['message'] ?? "").toString(),
    );
  }
}

class CheckPhoneResponse {
  final bool? exists;
  final String message;

  const CheckPhoneResponse({
    required this.exists,
    required this.message,
  });

  factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final exists = _readExists(json) ?? _readExists(nestedData);

    return CheckPhoneResponse(
      exists: exists,
      message: (json['message'] ?? nestedData['message'] ?? "").toString(),
    );
  }

  static bool? _readExists(Map<String, dynamic> source) {
    for (final key in const [
      'exists',
      'is_registered',
      'registered',
      'user_exists',
      'phone_exists',
      'can_login',
    ]) {
      final value = source[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }

    return null;
  }
}
