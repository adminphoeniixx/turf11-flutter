import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/match_action_model.dart';
import '../models/match_model.dart';

class MatchService {
  static Future<List<MatchModel>> fetchNearbyMatches({
    required double lat,
    required double lng,
    int radius = 20,
  }) async {
    debugPrint(
      "[MatchService] fetchNearbyMatches called with lat=$lat, lng=$lng, radius=$radius",
    );
    try {
      final res = await ApiClient.get(
        ApiConstants.nearbyMatches,
        queryParameters: {
          "lat": lat,
          "lng": lng,
          "radius": radius,
        },
      );

      final matches = _readMatchList(res.data);
      debugPrint(
        "[MatchService] fetchNearbyMatches parsed ${matches.length} matches",
      );
      return matches;
    } catch (e) {
      debugPrint("[MatchService] nearby API failed: $e");
      debugPrint(
        "[MatchService] Nearby matches unavailable because the backend endpoint failed; returning an empty list",
      );
      return const <MatchModel>[];
    }
  }

  static Future<List<MatchModel>> fetchMyMatches() async {
    debugPrint("[MatchService] fetchMyMatches called");
    final res = await ApiClient.get(ApiConstants.myMatches);
    final matches = _readMatchList(res.data);
    debugPrint("[MatchService] fetchMyMatches parsed ${matches.length} matches");
    return matches;
  }

  static Future<MatchModel> fetchMatchDetail(int matchId) async {
    debugPrint("[MatchService] fetchMatchDetail called for matchId=$matchId");
    final res = await ApiClient.get(ApiConstants.matchDetail(matchId));
    final map = _readMap(res.data);
    debugPrint("[MatchService] fetchMatchDetail payload keys: ${map.keys.toList()}");
    return MatchModel.fromJson(map);
  }

  static Future<MatchModel> createMatch(Map<String, dynamic> data) async {
    debugPrint("[MatchService] createMatch payload: $data");
    final res = await ApiClient.post(ApiConstants.matches, data: data);
    final map = _readMap(res.data);
    debugPrint("[MatchService] createMatch response keys: ${map.keys.toList()}");
    return MatchModel.fromJson(map);
  }

  static Future<String> inviteTeamToMatch({
    required int matchId,
    required int teamId,
  }) async {
    if (matchId <= 0) {
      debugPrint(
        "[MatchService] inviteTeamToMatch blocked because matchId=$matchId",
      );
      throw Exception("Invalid match id detected while inviting a team.");
    }
    if (teamId <= 0) {
      debugPrint(
        "[MatchService] inviteTeamToMatch blocked because teamId=$teamId",
      );
      throw Exception("Invalid team id detected while inviting a team.");
    }

    debugPrint(
      "[MatchService] inviteTeamToMatch called for matchId=$matchId, teamId=$teamId",
    );
    final res = await ApiClient.post(
      ApiConstants.inviteTeamToMatch(matchId),
      data: {
        "team_id": teamId,
      },
    );
    final message = _readMessage(
      res.data,
      fallback: "Team invited successfully.",
    );
    debugPrint("[MatchService] inviteTeamToMatch message: $message");
    return message;
  }

  static Future<String> joinMatchByCode(String code) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw Exception("Invite code is required.");
    }
    debugPrint("[MatchService] joinMatchByCode called for code=$normalizedCode");
    final res = await ApiClient.post(
      ApiConstants.joinMatchByCode,
      data: {
        "code": normalizedCode,
      },
    );
    final message = _readMessage(
      res.data,
      fallback: "Joined match successfully.",
    );
    debugPrint("[MatchService] joinMatchByCode message: $message");
    return message;
  }

  static Future<MatchInviteLinkModel> fetchMatchInviteLink(int matchId) async {
    debugPrint("[MatchService] fetchMatchInviteLink called for matchId=$matchId");
    final res = await ApiClient.get(ApiConstants.matchInviteLink(matchId));
    final map = _readMap(res.data);
    return MatchInviteLinkModel.fromJson(map);
  }

  static Future<List<NearbyPlayerModel>> fetchNearbyPlayers({
    required double lat,
    required double lng,
    int radius = 10,
  }) async {
    debugPrint(
      "[MatchService] fetchNearbyPlayers called with lat=$lat, lng=$lng, radius=$radius",
    );
    final res = await ApiClient.get(
      ApiConstants.nearbyPlayers,
      queryParameters: {
        "lat": lat,
        "lng": lng,
        "radius": radius,
      },
    );
    final root = _readMap(res.data);
    final candidates = [
      root["data"],
      root["players"],
      root["items"],
      res.data,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return _parseNearbyPlayers(candidate);
      }
      if (candidate is Map<String, dynamic>) {
        final nested = candidate["data"] ?? candidate["players"] ?? candidate["items"];
        if (nested is List) {
          return _parseNearbyPlayers(nested);
        }
      }
    }

    return const <NearbyPlayerModel>[];
  }

  static Future<String> invitePlayersToMatch({
    required int matchId,
    required List<int> playerIds,
  }) async {
    if (matchId <= 0) {
      throw Exception("Invalid match id detected while inviting players.");
    }
    if (playerIds.isEmpty) {
      throw Exception("Please select at least one player.");
    }
    final res = await ApiClient.post(
      ApiConstants.invitePlayersToMatch(matchId),
      data: {
        "player_ids": playerIds,
      },
    );
    return _readMessage(
      res.data,
      fallback: "Players invited successfully.",
    );
  }

  static Future<String> removePlayerFromMatch({
    required int matchId,
    required int playerId,
  }) async {
    if (matchId <= 0 || playerId <= 0) {
      throw Exception("Invalid match/player id detected while removing player.");
    }
    final res = await ApiClient.post(
      ApiConstants.removePlayerFromMatch(matchId, playerId),
    );
    return _readMessage(
      res.data,
      fallback: "Player removed successfully.",
    );
  }

  static Future<String> finalizeMatch(int matchId) async {
    if (matchId <= 0) {
      throw Exception("Invalid match id detected while finalizing match.");
    }
    final res = await ApiClient.post(ApiConstants.finalizeMatch(matchId));
    return _readMessage(
      res.data,
      fallback: "Match finalized successfully.",
    );
  }

  static Future<String> joinMatch(int matchId) async {
    if (matchId <= 0) {
      debugPrint("[MatchService] joinMatch blocked because matchId=$matchId");
      throw Exception(
        "Invalid match id detected while joining. Check nearby/my-matches API payload mapping.",
      );
    }
    debugPrint("[MatchService] joinMatch called for matchId=$matchId");
    final res = await ApiClient.post(ApiConstants.joinMatch(matchId));
    final message =
        _readMessage(res.data, fallback: "Joined match successfully.");
    debugPrint("[MatchService] joinMatch message: $message");
    return message;
  }

  static Future<String> leaveMatch(int matchId) async {
    if (matchId <= 0) {
      debugPrint("[MatchService] leaveMatch blocked because matchId=$matchId");
      throw Exception(
        "Invalid match id detected while leaving. Check match API payload mapping.",
      );
    }
    debugPrint("[MatchService] leaveMatch called for matchId=$matchId");
    final res = await ApiClient.post(ApiConstants.leaveMatch(matchId));
    final message =
        _readMessage(res.data, fallback: "Left match successfully.");
    debugPrint("[MatchService] leaveMatch message: $message");
    return message;
  }

  static List<MatchModel> _readMatchList(dynamic data) {
    final root = _readMap(data);
    final candidates = [
      root["data"],
      root["matches"],
      root["items"],
      data,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return _parseMatchItems(candidate);
      }

      if (candidate is Map<String, dynamic>) {
        final nestedList =
            candidate["data"] ?? candidate["matches"] ?? candidate["items"];
        if (nestedList is List) {
          return _parseMatchItems(nestedList);
        }
      }
    }

    return const <MatchModel>[];
  }

  static List<MatchModel> _parseMatchItems(List items) {
    final matches = <MatchModel>[];

    for (final item in items) {
      if (item is! Map) {
        debugPrint(
          "[MatchService] Skipping nearby match item because it is not a map: ${item.runtimeType}",
        );
        continue;
      }

      try {
        matches.add(MatchModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint("[MatchService] Failed to parse nearby match item: $e");
        debugPrint("[MatchService] Bad nearby match payload: $item");
      }
    }

    return matches;
  }

  static List<NearbyPlayerModel> _parseNearbyPlayers(List items) {
    final players = <NearbyPlayerModel>[];

    for (final item in items) {
      if (item is! Map) {
        continue;
      }

      try {
        players.add(NearbyPlayerModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint("[MatchService] Failed to parse nearby player item: $e");
      }
    }

    return players;
  }

  static Map<String, dynamic> _readMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  static String _readMessage(dynamic data, {required String fallback}) {
    final map = _readMap(data);
    final nested = map["data"];

    for (final value in [
      map["message"],
      map["detail"],
      nested is Map<String, dynamic> ? nested["message"] : null,
    ]) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

}
