class MatchInviteLinkModel {
  final String code;
  final String inviteLink;
  final String whatsappUrl;
  final String shareMessage;
  final String message;

  const MatchInviteLinkModel({
    required this.code,
    required this.inviteLink,
    required this.whatsappUrl,
    required this.shareMessage,
    required this.message,
  });

  factory MatchInviteLinkModel.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']);
    final merged = <String, dynamic>{...json, ...data};
    return MatchInviteLinkModel(
      code: _readString(
        merged,
        const ['code', 'invite_code', 'match_code'],
      ),
      inviteLink: _readString(
        merged,
        const ['invite_link', 'link', 'url'],
      ),
      whatsappUrl: _readString(
        merged,
        const ['whatsapp_url', 'whatsapp_link'],
      ),
      shareMessage: _readString(
        merged,
        const ['share_message', 'share_text', 'message_text'],
      ),
      message: _readString(
        merged,
        const ['message'],
        fallback: 'Invite link generated successfully.',
      ),
    );
  }
}

class NearbyPlayerModel {
  final int id;
  final String name;
  final String city;
  final String sport;
  final String phone;

  const NearbyPlayerModel({
    required this.id,
    required this.name,
    required this.city,
    required this.sport,
    required this.phone,
  });

  factory NearbyPlayerModel.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']);
    final user = _readMap(json['user']);
    final merged = <String, dynamic>{...json, ...data, ...user};
    return NearbyPlayerModel(
      id: _readInt(merged, const ['id', 'player_id', 'user_id']) ?? 0,
      name: _readString(
        merged,
        const ['name', 'player_name'],
        fallback: 'Player',
      ),
      city: _readString(
        merged,
        const ['city', 'location'],
      ),
      sport: _readString(
        merged,
        const ['sport', 'sport_type'],
      ),
      phone: _readString(
        merged,
        const ['phone', 'phone_number'],
      ),
    );
  }

  String get initials {
    final parts = name
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
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

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _readString(
  Map<String, dynamic> source,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = source[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

int? _readInt(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}
