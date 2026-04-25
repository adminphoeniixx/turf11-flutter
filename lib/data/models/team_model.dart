class TeamModel {
  final int id;
  final String name;
  final String sport;
  final String city;
  final String code;
  final bool isCaptain;
  final bool canManage;
  final int memberCount;
  final String captainName;
  final List<TeamMemberModel> members;

  const TeamModel({
    required this.id,
    required this.name,
    required this.sport,
    required this.city,
    required this.code,
    required this.isCaptain,
    required this.canManage,
    required this.memberCount,
    required this.captainName,
    required this.members,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final nested = _mergeNested(json);
    final merged = <String, dynamic>{...json, ...nested};
    final captainMap = _readMap(merged['captain']);
    final members = _extractMembers(merged);
    final isCaptain =
        _readBool(merged, const ['is_captain', 'captain', 'is_owner']) ??
            _readString(merged, const ['my_role', 'role'])
                    .toLowerCase()
                    .contains('captain');

    return TeamModel(
      id: _readInt(merged, const ['id', 'team_id', 'player_team_id']) ?? 0,
      name: _readString(merged, const ['name', 'team_name'], fallback: 'Team'),
      sport: _readString(merged, const ['sport', 'sport_type'], fallback: '-'),
      city: _readString(merged, const ['city', 'location'], fallback: '-'),
      code: _readString(
        merged,
        const ['code', 'invite_code', 'team_code'],
        fallback: '',
      ),
      isCaptain: isCaptain,
      canManage:
          _readBool(merged, const ['can_manage', 'can_edit', 'can_update']) ??
              isCaptain,
      memberCount:
          _readInt(
            merged,
            const ['members_count', 'member_count', 'players_count'],
          ) ??
              _readListCount(merged['members']) ??
              _readListCount(merged['team_members']) ??
              _readListCount(merged['member_ids']) ??
              _readListCount(merged['member_names']) ??
              members.length,
      captainName: _readString(
        captainMap.isEmpty ? merged : captainMap,
        const ['name', 'captain_name', 'owner_name'],
        fallback: members
            .where((member) => member.isCaptain)
            .map((member) => member.name)
            .cast<String?>()
            .firstWhere(
              (name) => name != null && name.trim().isNotEmpty,
              orElse: () => '',
            ) ??
            '',
      ),
      members: members,
    );
  }

  TeamModel copyWith({
    int? id,
    String? name,
    String? sport,
    String? city,
    String? code,
    bool? isCaptain,
    bool? canManage,
    int? memberCount,
    String? captainName,
    List<TeamMemberModel>? members,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      city: city ?? this.city,
      code: code ?? this.code,
      isCaptain: isCaptain ?? this.isCaptain,
      canManage: canManage ?? this.canManage,
      memberCount: memberCount ?? this.memberCount,
      captainName: captainName ?? this.captainName,
      members: members ?? this.members,
    );
  }

  int get playerCount {
    final counts = <int>[
      memberCount,
      members.length,
      if (isCaptain || captainName.trim().isNotEmpty) 1,
    ];
    return counts.reduce((current, next) => current > next ? current : next);
  }

  static List<TeamMemberModel> _extractMembers(Map<String, dynamic> source) {
    final candidates = <dynamic>[
      source['members'],
      source['players'],
      source['team_members'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map(
              (item) => TeamMemberModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
      if (candidate is Map<String, dynamic>) {
        final nested = candidate['data'];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map(
                (item) =>
                    TeamMemberModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
    }

    return const <TeamMemberModel>[];
  }

  static Map<String, dynamic> _mergeNested(Map<String, dynamic> source) {
    for (final key in const ['data', 'team']) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return <String, dynamic>{};
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

  static int? _readListCount(dynamic value) {
    if (value is List) {
      return value.length;
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> source, List<String> keys) {
    final value = _readNum(source, keys);
    return value?.toInt();
  }

  static num? _readNum(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) {
        return value;
      }
      if (value is String) {
        final parsed = num.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
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

  static String _readString(
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
}

class TeamMemberModel {
  final int id;
  final String name;
  final String phone;
  final String city;
  final String role;
  final bool isCaptain;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.role,
    required this.isCaptain,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    final userMap = TeamModel._readMap(json['user']);
    final merged = <String, dynamic>{...userMap, ...json};
    final isCaptain =
        TeamModel._readBool(
          merged,
          const ['is_captain', 'captain', 'is_owner'],
        ) ??
            TeamModel._readString(merged, const ['role', 'member_role'])
                .toLowerCase()
                .contains('captain');

    return TeamMemberModel(
      id: TeamModel._readInt(merged, const ['id', 'user_id', 'player_id']) ?? 0,
      name: TeamModel._readString(
        merged,
        const ['name', 'player_name'],
        fallback: 'Player',
      ),
      phone: TeamModel._readString(
        merged,
        const ['phone', 'phone_number', 'player_phone'],
        fallback: '',
      ),
      city: TeamModel._readString(merged, const ['city', 'location'], fallback: ''),
      role: TeamModel._readString(
        merged,
        const ['role', 'member_role'],
        fallback: isCaptain ? 'Captain' : 'Player',
      ),
      isCaptain: isCaptain,
    );
  }

  String get displayRole {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'member') {
      return 'Player';
    }
    if (normalized == 'captain') {
      return 'Captain';
    }
    if (normalized.isEmpty) {
      return isCaptain ? 'Captain' : 'Player';
    }
    return role;
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

class TeamInviteModel {
  final String code;
  final String inviteLink;
  final String whatsappUrl;
  final String shareMessage;
  final String message;

  const TeamInviteModel({
    required this.code,
    required this.inviteLink,
    required this.whatsappUrl,
    required this.shareMessage,
    required this.message,
  });

  factory TeamInviteModel.fromJson(Map<String, dynamic> json) {
    final data = TeamModel._mergeNested(json);
    final merged = <String, dynamic>{...json, ...data};
    return TeamInviteModel(
      code: TeamModel._readString(
        merged,
        const ['code', 'invite_code', 'team_code'],
        fallback: '',
      ),
      inviteLink: TeamModel._readString(
        merged,
        const ['invite_link', 'link', 'url'],
        fallback: '',
      ),
      whatsappUrl: TeamModel._readString(
        merged,
        const ['whatsapp_url', 'whatsapp_link'],
        fallback: '',
      ),
      shareMessage: TeamModel._readString(
        merged,
        const ['share_message', 'share_text', 'message_text'],
        fallback: '',
      ),
      message: TeamModel._readString(
        merged,
        const ['message'],
        fallback: 'Invite link generated successfully.',
      ),
    );
  }
}

class TeamActionResult {
  final bool success;
  final String message;
  final TeamModel? team;

  const TeamActionResult({
    required this.success,
    required this.message,
    this.team,
  });

  factory TeamActionResult.fromJson(Map<String, dynamic> json) {
    final data = TeamModel._mergeNested(json);
    final merged = <String, dynamic>{...json, ...data};
    final teamMap = TeamModel._readMap(json['team']).isNotEmpty
        ? TeamModel._readMap(json['team'])
        : TeamModel._readMap(json['data']);

    return TeamActionResult(
      success:
          TeamModel._readBool(merged, const ['success', 'status']) ?? true,
      message: TeamModel._readString(
        merged,
        const ['message'],
        fallback: 'Request completed successfully.',
      ),
      team: teamMap.isEmpty ? null : TeamModel.fromJson(teamMap),
    );
  }
}

class TeamTournamentRegistrationResult {
  final bool success;
  final String message;

  const TeamTournamentRegistrationResult({
    required this.success,
    required this.message,
  });

  factory TeamTournamentRegistrationResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = TeamModel._mergeNested(json);
    final merged = <String, dynamic>{...json, ...data};
    return TeamTournamentRegistrationResult(
      success:
          TeamModel._readBool(merged, const ['success', 'status']) ?? true,
      message: TeamModel._readString(
        merged,
        const ['message'],
        fallback: 'Team registered successfully.',
      ),
    );
  }
}

class NearbyPlayerModel {
  final int id;
  final String name;
  final String phone;
  final String city;
  final String primarySport;
  final double? distanceKm;

  const NearbyPlayerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.primarySport,
    required this.distanceKm,
  });

  factory NearbyPlayerModel.fromJson(Map<String, dynamic> json) {
    final data = TeamModel._mergeNested(json);
    final merged = <String, dynamic>{...json, ...data};
    return NearbyPlayerModel(
      id: TeamModel._readInt(merged, const ['id', 'player_id', 'user_id']) ?? 0,
      name: TeamModel._readString(
        merged,
        const ['name', 'player_name'],
        fallback: 'Player',
      ),
      phone: TeamModel._readString(
        merged,
        const ['phone', 'phone_number'],
        fallback: '',
      ),
      city: TeamModel._readString(
        merged,
        const ['city', 'location'],
        fallback: '',
      ),
      primarySport: TeamModel._readString(
        merged,
        const ['sport', 'sport_type', 'primary_sport'],
        fallback: 'player',
      ),
      distanceKm:
          TeamModel._readNum(merged, const ['distance_km', 'distance'])
              ?.toDouble(),
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

class PlayerInvitationModel {
  final int id;
  final String type;
  final int referenceId;
  final String message;
  final String status;
  final String senderName;
  final String createdAt;

  const PlayerInvitationModel({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.message,
    required this.status,
    required this.senderName,
    required this.createdAt,
  });

  factory PlayerInvitationModel.fromJson(Map<String, dynamic> json) {
    final data = TeamModel._mergeNested(json);
    final merged = <String, dynamic>{...json, ...data};
    final sender = TeamModel._readMap(merged['sender']);
    return PlayerInvitationModel(
      id: TeamModel._readInt(
            merged,
            const ['id', 'invitation_id'],
          ) ??
          0,
      type: TeamModel._readString(
        merged,
        const ['type'],
        fallback: 'team',
      ),
      referenceId: TeamModel._readInt(
            merged,
            const ['reference_id', 'team_id', 'match_id'],
          ) ??
          0,
      message: TeamModel._readString(
        merged,
        const ['message', 'invite_message'],
        fallback: '',
      ),
      status: TeamModel._readString(
        merged,
        const ['status'],
        fallback: 'pending',
      ),
      senderName: TeamModel._readString(
        sender.isEmpty ? merged : sender,
        const ['name', 'sender_name'],
        fallback: '',
      ),
      createdAt: TeamModel._readString(
        merged,
        const ['created_at'],
        fallback: '',
      ),
    );
  }
}
