import 'package:flutter/foundation.dart';

class MatchModel {
  final int id;
  final String title;
  final String sport;
  final String format;
  final String city;
  final String turfName;
  final String venueAddress;
  final String creatorName;
  final String date;
  final String timeStart;
  final String timeEnd;
  final int minPlayers;
  final int maxPlayers;
  final int joinedPlayers;
  final int feePerPlayer;
  final int slotTotalCost;
  final int estimatedFee;
  final String skillLevel;
  final String feeMode;
  final String inviteCode;
  final String description;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isCreator;
  final bool canFinalize;
  final bool hasJoined;
  final String myStatus;
  final String myPaymentStatus;
  final List<MatchPlayerModel> players;

  const MatchModel({
    required this.id,
    required this.title,
    required this.sport,
    required this.format,
    required this.city,
    required this.turfName,
    required this.venueAddress,
    required this.creatorName,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.minPlayers,
    required this.maxPlayers,
    required this.joinedPlayers,
    required this.feePerPlayer,
    required this.slotTotalCost,
    required this.estimatedFee,
    required this.skillLevel,
    required this.feeMode,
    required this.inviteCode,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.isCreator,
    required this.canFinalize,
    required this.hasJoined,
    required this.myStatus,
    required this.myPaymentStatus,
    required this.players,
  });

  int get slotsLeft {
    final remaining = maxPlayers - joinedPlayers;
    return remaining < 0 ? 0 : remaining;
  }

  double get fillProgress {
    if (maxPlayers <= 0) {
      return 0;
    }

    return (joinedPlayers / maxPlayers).clamp(0, 1).toDouble();
  }

  bool get isFull => slotsLeft == 0;

  List<MatchPlayerModel> get activePlayers {
    return players.where((player) => !player.hasLeft).toList();
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final nestedMaps = _collectNestedMaps(json);
    final merged = <String, dynamic>{...json};
    for (final item in nestedMaps) {
      merged.addAll(item);
    }

    final resolvedId = _readInt(merged, const [
          "id",
          "match_id",
          "sport_match_id",
          "sportMatchId",
          "_id",
        ]) ??
        0;

    if (resolvedId == 0) {
      debugPrint(
        "[MatchModel] Could not resolve match id. Available keys: ${merged.keys.toList()}",
      );
      debugPrint("[MatchModel] Raw payload: $json");
    }

    final joinedPlayers = _readJoinedPlayers(merged);
    final parsedPlayers = _readPlayers(merged);
    if (joinedPlayers > 0 && parsedPlayers.isEmpty) {
      debugPrint(
        "[MatchModel] joinedPlayers=$joinedPlayers but no player objects parsed. Keys: ${merged.keys.toList()}",
      );
    }
    final maxPlayers =
        _readMaxPlayers(merged) ??
        _readInt(merged, const ["max_players", "total_players", "player_limit"]) ??
        0;
    final sanitizedJoinedPlayers = joinedPlayers < 0 ? 0 : joinedPlayers;

    return MatchModel(
      id: resolvedId,
      title: _readString(merged, const ["title", "name"],
          fallback: "Untitled Match"),
      sport: _readString(merged, const ["sport", "game_type"],
          fallback: "cricket"),
      format: _readString(merged, const ["format", "match_format"],
          fallback: "5v5"),
      city: _readString(merged, const ["city", "location", "venue_city"],
          fallback: "Gurugram"),
      turfName: _readString(merged, const ["turf_name"], fallback: "-"),
      venueAddress: _readString(
        merged,
        const ["venue_address", "address"],
        fallback: "",
      ),
      creatorName: _readString(
        merged,
        const ["creator_name", "created_by_name", "host_name"],
        fallback: "",
      ),
      date: _readString(merged, const ["date", "match_date", "scheduled_date"]),
      timeStart:
          _readString(merged, const ["time_start", "start_time", "from_time", "time"]),
      timeEnd: _readString(merged, const ["time_end", "end_time", "to_time"]),
      minPlayers:
          _readInt(merged, const ["min_players"]) ??
          _readInt(_readMap(merged["metadata"]), const ["min_players"]) ??
          0,
      maxPlayers: maxPlayers,
      joinedPlayers: sanitizedJoinedPlayers > maxPlayers && maxPlayers > 0
          ? maxPlayers
          : sanitizedJoinedPlayers,
      feePerPlayer:
          _readInt(
                merged,
                const ["fee", "fee_per_player", "price_per_player", "amount"],
              ) ??
              0,
      slotTotalCost:
          _readInt(merged, const ["slot_total_cost"]) ??
          _readInt(_readMap(merged["metadata"]), const ["slot_total_cost"]) ??
          0,
      estimatedFee: _readInt(merged, const ["estimated_fee"]) ?? 0,
      skillLevel: _readString(merged, const ["skill_level", "level"], fallback: "all"),
      feeMode: _readString(
        merged,
        const ["fee_mode"],
        fallback: _readString(
          _readMap(merged["metadata"]),
          const ["fee_mode"],
          fallback: "split",
        ),
      ),
      inviteCode: _readString(
        merged,
        const ["invite_code", "match_code"],
        fallback: _readString(
          _readMap(merged["metadata"]),
          const ["invite_code"],
          fallback: "",
        ),
      ),
      description: _readString(merged, const ["description", "details"]),
      latitude: _readDouble(merged, const ["lat", "latitude"]),
      longitude: _readDouble(merged, const ["lng", "longitude", "long"]),
      status: _readString(merged, const ["status"], fallback: "open"),
      isCreator:
          _readBool(
            merged,
            const ["is_creator", "creator", "created_by_me"],
          ) ??
          parsedPlayers.any((player) => player.isCreator),
      canFinalize: _readBool(merged, const ["can_finalize"]) ?? false,
      hasJoined:
          _readBool(merged, const ["has_joined", "is_joined"]) ??
          false,
      myStatus: _readString(merged, const ["my_status"], fallback: ""),
      myPaymentStatus:
          _readString(merged, const ["my_payment_status"], fallback: ""),
      players: parsedPlayers,
    );
  }

  static List<Map<String, dynamic>> _collectNestedMaps(
    Map<String, dynamic> source,
  ) {
    final nested = <Map<String, dynamic>>[];

    for (final key in const ["data", "match", "sport_match", "sportMatch"]) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        nested.add(value);
      } else if (value is Map) {
        nested.add(Map<String, dynamic>.from(value));
      }
    }

    return nested;
  }

  static int _readJoinedPlayers(Map<String, dynamic> source) {
    final direct = _readInt(source, const [
      "joined_players",
      "joined_players_count",
      "players_joined",
      "current_players",
      "filled_slots",
      "participants_count",
      "booked_slots",
    ]);

    if (direct != null) {
      return direct;
    }

    final summary = _readPlayersSummary(source);
    if (summary != null) {
      return summary.joined;
    }

    final players = source["players"] ?? source["participants"] ?? source["members"];
    if (players is List) {
      return players.length;
    }

    return 0;
  }

  static List<MatchPlayerModel> _readPlayers(Map<String, dynamic> source) {
    final candidates = [
      source["players"],
      source["participants"],
      source["members"],
      source["users"],
      source["joined_users"],
      source["joinedPlayers"],
      source["accepted_players"],
      source["confirmed_players"],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => MatchPlayerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    return const <MatchPlayerModel>[];
  }

  static int? _readMaxPlayers(Map<String, dynamic> source) {
    final direct = _readInt(
      source,
      const ["max_players", "total_players", "player_limit"],
    );
    if (direct != null) {
      return direct;
    }

    final summary = _readPlayersSummary(source);
    return summary?.max;
  }

  static _PlayersSummary? _readPlayersSummary(Map<String, dynamic> source) {
    final raw = source["players"];
    if (raw is! String) {
      return null;
    }
    final normalized = raw.trim();
    final match = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final joined = int.tryParse(match.group(1) ?? '');
    final max = int.tryParse(match.group(2) ?? '');
    if (joined == null || max == null) {
      return null;
    }
    return _PlayersSummary(joined: joined, max: max);
  }

  static int? _readInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value.trim());
      }
    }

    return null;
  }

  static double? _readDouble(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is double) {
        return value;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value.trim());
      }
    }

    return null;
  }

  static String _readString(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = "",
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return fallback;
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
}

class MatchPlayerModel {
  final int id;
  final String name;
  final String phone;
  final String status;
  final String paymentStatus;
  final int feePaid;
  final String source;
  final bool isCreator;

  const MatchPlayerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.paymentStatus,
    required this.feePaid,
    required this.source,
    required this.isCreator,
  });

  factory MatchPlayerModel.fromJson(Map<String, dynamic> json) {
    final data = MatchModel._readMap(json['data']);
    final player = MatchModel._readMap(json['player']);
    final user = MatchModel._readMap(json['user']);
    final member = MatchModel._readMap(json['member']);
    final merged = <String, dynamic>{
      ...data,
      ...player,
      ...user,
      ...member,
      ...json,
    };

    return MatchPlayerModel(
      id:
          MatchModel._readInt(
            merged,
            const ['player_id', 'id', 'user_id', 'member_id'],
          ) ??
          0,
      name: MatchModel._readString(
        merged,
        const ['name', 'player_name', 'full_name', 'display_name', 'username'],
        fallback: 'Player',
      ),
      phone: MatchModel._readString(
        merged,
        const ['phone', 'phone_number', 'mobile'],
        fallback: '',
      ),
      status: MatchModel._readString(
        merged,
        const ['status', 'join_status'],
        fallback: '',
      ),
      paymentStatus: MatchModel._readString(
        merged,
        const ['payment_status'],
        fallback: '',
      ),
      feePaid: MatchModel._readInt(
            merged,
            const ['fee_paid'],
          ) ??
          0,
      source: MatchModel._readString(
        merged,
        const ['source'],
        fallback: '',
      ),
      isCreator:
          MatchModel._readBool(
            merged,
            const ['is_creator', 'creator'],
          ) ??
          false,
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

  bool get hasLeft => status.trim().toLowerCase() == 'left';
}

class _PlayersSummary {
  final int joined;
  final int max;

  const _PlayersSummary({
    required this.joined,
    required this.max,
  });
}
