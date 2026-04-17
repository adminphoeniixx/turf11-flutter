class PlayerProfileResponse {
  final bool success;
  final PlayerProfile player;

  const PlayerProfileResponse({
    required this.success,
    required this.player,
  });

  factory PlayerProfileResponse.fromJson(Map<String, dynamic> json) {
    final playerMap = _readMap(json['player']);

    return PlayerProfileResponse(
      success: _readBool(json['success']),
      player: PlayerProfile.fromJson(playerMap),
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
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}

class PlayerProfile {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String avatarUrl;
  final String city;
  final String state;
  final List<String> sports;
  final double walletBalance;
  final int rewardPoints;
  final int totalBookings;
  final double totalSpent;
  final String memberSince;

  const PlayerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarUrl,
    required this.city,
    required this.state,
    required this.sports,
    required this.walletBalance,
    required this.rewardPoints,
    required this.totalBookings,
    required this.totalSpent,
    required this.memberSince,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final stats = _readMap(json['stats']);
    final sportsRaw = json['sports'];

    return PlayerProfile(
      id: _readInt(json['id']),
      name: _readString(json['name'], fallback: 'Player'),
      phone: _readString(json['phone']),
      email: _readString(json['email']),
      avatarUrl: _readString(json['avatar_url']),
      city: _readString(json['city']),
      state: _readString(json['state']),
      sports: sportsRaw is List
          ? sportsRaw.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList()
          : const <String>[],
      walletBalance: _readDouble(json['wallet_balance']),
      rewardPoints: _readInt(json['reward_points']),
      totalBookings: _readInt(stats['total_bookings']),
      totalSpent: _readDouble(stats['total_spent']),
      memberSince: _readString(json['member_since']),
    );
  }

  String get primarySport => sports.isEmpty ? 'Player' : sports.first;

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
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get locationLabel {
    final parts = <String>[
      if (city.trim().isNotEmpty) city.trim(),
      if (state.trim().isNotEmpty) state.trim(),
    ];
    return parts.join(', ');
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
