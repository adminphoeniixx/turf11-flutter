class TournamentModel {
  final int id;
  final String name;
  final String sport;
  final String city;
  final String venue;
  final String startDate;
  final String endDate;
  final num entryFee;
  final int maxTeams;
  final int registeredTeams;
  final TournamentPrizeModel prizes;
  final String posterUrl;
  final String status;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.sport,
    required this.city,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.entryFee,
    required this.maxTeams,
    required this.registeredTeams,
    required this.prizes,
    required this.posterUrl,
    required this.status,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    final prizesMap = _readMap(json['prizes']);
    return TournamentModel(
      id: _readInt(json, const ['id']) ?? 0,
      name: _readString(json, const ['name'], fallback: 'Tournament'),
      sport: _readString(json, const ['sport'], fallback: '-'),
      city: _readString(json, const ['city'], fallback: '-'),
      venue: _readString(json, const ['venue'], fallback: '-'),
      startDate: _readString(json, const ['start_date'], fallback: '-'),
      endDate: _readString(json, const ['end_date'], fallback: '-'),
      entryFee: _readNum(json, const ['entry_fee']) ?? 0,
      maxTeams: _readInt(json, const ['max_teams']) ?? 0,
      registeredTeams: _readInt(json, const ['registered_teams']) ?? 0,
      prizes: TournamentPrizeModel.fromJson(prizesMap),
      posterUrl: _readString(json, const ['poster_url'], fallback: ''),
      status: _readString(json, const ['status'], fallback: 'upcoming'),
    );
  }

  String get dateLabel => '$startDate - $endDate';
  String get locationLabel => '$city | $venue';
  bool get isFull => maxTeams > 0 && registeredTeams >= maxTeams;
  String get statusLabel {
    final normalized = status.trim().toLowerCase();
    if (isFull) {
      return 'Tournament Full';
    }
    switch (normalized) {
      case 'registration_open':
        return 'Registration Open';
      case 'completed':
        return 'Completed';
      case 'ongoing':
        return 'Ongoing';
      default:
        return normalized.isEmpty
            ? 'Upcoming'
            : normalized
                .split('_')
                .map((part) => part.isEmpty
                    ? part
                    : part[0].toUpperCase() + part.substring(1))
                .join(' ');
    }
  }

  double get registrationProgress {
    if (maxTeams <= 0) {
      return 0;
    }
    return (registeredTeams / maxTeams).clamp(0, 1).toDouble();
  }

  String get topPrizeLabel {
    final firstPrize = prizes.first;
    return firstPrize > 0 ? 'Rs ${_formatAmount(firstPrize)}' : 'TBA';
  }

  String get entryFeeLabel =>
      entryFee > 0 ? 'Rs ${_formatAmount(entryFee)}' : 'Free';

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
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

  static String _formatAmount(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }
}

class TournamentPrizeModel {
  final num first;
  final num second;
  final num third;

  const TournamentPrizeModel({
    required this.first,
    required this.second,
    required this.third,
  });

  factory TournamentPrizeModel.fromJson(Map<String, dynamic> json) {
    return TournamentPrizeModel(
      first: TournamentModel._readNum(json, const ['first']) ?? 0,
      second: TournamentModel._readNum(json, const ['second']) ?? 0,
      third: TournamentModel._readNum(json, const ['third']) ?? 0,
    );
  }
}

class TournamentListResponse {
  final List<TournamentModel> tournaments;
  final int currentPage;
  final int lastPage;
  final int total;

  const TournamentListResponse({
    required this.tournaments,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory TournamentListResponse.fromJson(Map<String, dynamic> json) {
    final root = json['tournaments'];
    final tournamentsMap = root is Map<String, dynamic>
        ? root
        : root is Map
            ? Map<String, dynamic>.from(root)
            : <String, dynamic>{};
    final list = tournamentsMap['data'];

    return TournamentListResponse(
      tournaments: list is List
          ? list
              .whereType<Map>()
              .map(
                (item) =>
                    TournamentModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
          : const <TournamentModel>[],
      currentPage:
          TournamentModel._readInt(tournamentsMap, const ['current_page']) ?? 1,
      lastPage:
          TournamentModel._readInt(tournamentsMap, const ['last_page']) ?? 1,
      total: TournamentModel._readInt(tournamentsMap, const ['total']) ?? 0,
    );
  }
}

class TournamentTeamsSummary {
  final int id;
  final String name;
  final int maxTeams;
  final int registeredTeams;

  const TournamentTeamsSummary({
    required this.id,
    required this.name,
    required this.maxTeams,
    required this.registeredTeams,
  });

  factory TournamentTeamsSummary.fromJson(Map<String, dynamic> json) {
    return TournamentTeamsSummary(
      id: TournamentModel._readInt(json, const ['id']) ?? 0,
      name: TournamentModel._readString(
        json,
        const ['name'],
        fallback: 'Tournament',
      ),
      maxTeams: TournamentModel._readInt(json, const ['max_teams']) ?? 0,
      registeredTeams:
          TournamentModel._readInt(json, const ['registered_teams']) ?? 0,
    );
  }
}

class TournamentRegisteredTeamModel {
  final int id;
  final String teamName;
  final String captainName;
  final String captainPhone;
  final int? playerTeamId;
  final String logoUrl;
  final int playersCount;
  final String paymentStatus;
  final num entryFeePaid;
  final String status;
  final String registeredAt;

  const TournamentRegisteredTeamModel({
    required this.id,
    required this.teamName,
    required this.captainName,
    required this.captainPhone,
    required this.playerTeamId,
    required this.logoUrl,
    required this.playersCount,
    required this.paymentStatus,
    required this.entryFeePaid,
    required this.status,
    required this.registeredAt,
  });

  factory TournamentRegisteredTeamModel.fromJson(Map<String, dynamic> json) {
    return TournamentRegisteredTeamModel(
      id: TournamentModel._readInt(json, const ['id']) ?? 0,
      teamName: TournamentModel._readString(
        json,
        const ['team_name', 'name'],
        fallback: 'Team',
      ),
      captainName: TournamentModel._readString(
        json,
        const ['captain_name'],
        fallback: '-',
      ),
      captainPhone: TournamentModel._readString(
        json,
        const ['captain_phone'],
        fallback: '',
      ),
      playerTeamId:
          TournamentModel._readInt(json, const ['player_team_id']),
      logoUrl: TournamentModel._readString(
        json,
        const ['logo_url'],
        fallback: '',
      ),
      playersCount:
          TournamentModel._readInt(json, const ['players_count']) ?? 0,
      paymentStatus: TournamentModel._readString(
        json,
        const ['payment_status'],
        fallback: 'pending',
      ),
      entryFeePaid:
          TournamentModel._readNum(json, const ['entry_fee_paid']) ?? 0,
      status: TournamentModel._readString(
        json,
        const ['status'],
        fallback: 'registered',
      ),
      registeredAt: TournamentModel._readString(
        json,
        const ['registered_at'],
        fallback: '-',
      ),
    );
  }

  String get statusLabel {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Registered';
    }
    return normalized
        .split('_')
        .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  String get paymentLabel {
    final normalized = paymentStatus.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Pending';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String get entryFeePaidLabel {
    return entryFeePaid > 0
        ? 'Rs ${TournamentModel._formatAmount(entryFeePaid)}'
        : 'Rs 0';
  }
}

class TournamentTeamsResponse {
  final TournamentTeamsSummary? tournament;
  final List<TournamentRegisteredTeamModel> teams;
  final int count;

  const TournamentTeamsResponse({
    required this.tournament,
    required this.teams,
    required this.count,
  });

  factory TournamentTeamsResponse.fromJson(Map<String, dynamic> json) {
    final tournamentMap = json['tournament'] is Map<String, dynamic>
        ? json['tournament'] as Map<String, dynamic>
        : json['tournament'] is Map
            ? Map<String, dynamic>.from(json['tournament'] as Map)
            : <String, dynamic>{};
    final teamsRaw = json['teams'];
    return TournamentTeamsResponse(
      tournament: tournamentMap.isEmpty
          ? null
          : TournamentTeamsSummary.fromJson(tournamentMap),
      teams: teamsRaw is List
          ? teamsRaw
              .whereType<Map>()
              .map(
                (item) => TournamentRegisteredTeamModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <TournamentRegisteredTeamModel>[],
      count: TournamentModel._readInt(json, const ['count']) ?? 0,
    );
  }
}

class TournamentTeamPlayersSummary {
  final int id;
  final String teamName;
  final String captainName;
  final String status;
  final String paymentStatus;

  const TournamentTeamPlayersSummary({
    required this.id,
    required this.teamName,
    required this.captainName,
    required this.status,
    required this.paymentStatus,
  });

  factory TournamentTeamPlayersSummary.fromJson(Map<String, dynamic> json) {
    return TournamentTeamPlayersSummary(
      id: TournamentModel._readInt(json, const ['id']) ?? 0,
      teamName: TournamentModel._readString(
        json,
        const ['team_name', 'name'],
        fallback: 'Team',
      ),
      captainName: TournamentModel._readString(
        json,
        const ['captain_name'],
        fallback: '-',
      ),
      status: TournamentModel._readString(
        json,
        const ['status'],
        fallback: 'registered',
      ),
      paymentStatus: TournamentModel._readString(
        json,
        const ['payment_status'],
        fallback: 'pending',
      ),
    );
  }
}

class TournamentTeamPlayerStats {
  final int totalBookings;
  final int matchesPlayed;

  const TournamentTeamPlayerStats({
    required this.totalBookings,
    required this.matchesPlayed,
  });

  factory TournamentTeamPlayerStats.fromJson(Map<String, dynamic> json) {
    return TournamentTeamPlayerStats(
      totalBookings:
          TournamentModel._readInt(json, const ['total_bookings']) ?? 0,
      matchesPlayed:
          TournamentModel._readInt(json, const ['matches_played']) ?? 0,
    );
  }
}

class TournamentTeamPlayerModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String avatarUrl;
  final List<String> sports;
  final bool isCaptain;
  final TournamentTeamPlayerStats stats;

  const TournamentTeamPlayerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.avatarUrl,
    required this.sports,
    required this.isCaptain,
    required this.stats,
  });

  factory TournamentTeamPlayerModel.fromJson(Map<String, dynamic> json) {
    final statsMap = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : json['stats'] is Map
            ? Map<String, dynamic>.from(json['stats'] as Map)
            : <String, dynamic>{};
    return TournamentTeamPlayerModel(
      id: TournamentModel._readInt(json, const ['id']) ?? 0,
      name: TournamentModel._readString(
        json,
        const ['name'],
        fallback: 'Player',
      ),
      phone: TournamentModel._readString(
        json,
        const ['phone'],
        fallback: '',
      ),
      email: TournamentModel._readString(
        json,
        const ['email'],
        fallback: '',
      ),
      city: TournamentModel._readString(
        json,
        const ['city'],
        fallback: '',
      ),
      avatarUrl: TournamentModel._readString(
        json,
        const ['avatar_url'],
        fallback: '',
      ),
      sports: _readSports(json['sports']),
      isCaptain: _readBool(json['is_captain']) ?? false,
      stats: TournamentTeamPlayerStats.fromJson(statsMap),
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

  static List<String> _readSports(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  static bool? _readBool(dynamic value) {
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
    return null;
  }
}

class TournamentTeamPlayersResponse {
  final TournamentTeamPlayersSummary? team;
  final List<TournamentTeamPlayerModel> players;
  final int count;

  const TournamentTeamPlayersResponse({
    required this.team,
    required this.players,
    required this.count,
  });

  factory TournamentTeamPlayersResponse.fromJson(Map<String, dynamic> json) {
    final teamMap = json['team'] is Map<String, dynamic>
        ? json['team'] as Map<String, dynamic>
        : json['team'] is Map
            ? Map<String, dynamic>.from(json['team'] as Map)
            : <String, dynamic>{};
    final playersRaw = json['players'];
    return TournamentTeamPlayersResponse(
      team: teamMap.isEmpty
          ? null
          : TournamentTeamPlayersSummary.fromJson(teamMap),
      players: playersRaw is List
          ? playersRaw
              .whereType<Map>()
              .map(
                (item) => TournamentTeamPlayerModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <TournamentTeamPlayerModel>[],
      count: TournamentModel._readInt(json, const ['count']) ?? 0,
    );
  }
}
