import 'package:flutter/foundation.dart';

class MatchModel {
  final int id;
  final String title;
  final String sport;
  final String format;
  final String city;
  final String date;
  final String timeStart;
  final String timeEnd;
  final int maxPlayers;
  final int joinedPlayers;
  final int feePerPlayer;
  final String skillLevel;
  final String description;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isCreator;

  const MatchModel({
    required this.id,
    required this.title,
    required this.sport,
    required this.format,
    required this.city,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.maxPlayers,
    required this.joinedPlayers,
    required this.feePerPlayer,
    required this.skillLevel,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.isCreator,
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
    final maxPlayers =
        _readMaxPlayers(merged) ??
        _readInt(merged, const ["max_players", "total_players", "player_limit"]) ??
        0;

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
      date: _readString(merged, const ["date", "match_date", "scheduled_date"]),
      timeStart:
          _readString(merged, const ["time_start", "start_time", "from_time", "time"]),
      timeEnd: _readString(merged, const ["time_end", "end_time", "to_time"]),
      maxPlayers: maxPlayers,
      joinedPlayers: joinedPlayers > maxPlayers && maxPlayers > 0
          ? maxPlayers
          : joinedPlayers,
      feePerPlayer:
          _readInt(merged, const ["fee_per_player", "price_per_player", "amount"]) ??
              0,
      skillLevel: _readString(merged, const ["skill_level", "level"], fallback: "all"),
      description: _readString(merged, const ["description", "details"]),
      latitude: _readDouble(merged, const ["lat", "latitude"]),
      longitude: _readDouble(merged, const ["lng", "longitude", "long"]),
      status: _readString(merged, const ["status"], fallback: "open"),
      isCreator: _readBool(merged, const ["is_creator", "creator", "created_by_me"]) ??
          false,
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

class _PlayersSummary {
  final int joined;
  final int max;

  const _PlayersSummary({
    required this.joined,
    required this.max,
  });
}
