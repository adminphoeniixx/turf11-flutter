import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
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
        return candidate
            .whereType<Map>()
            .map((item) => MatchModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      if (candidate is Map<String, dynamic>) {
        final nestedList =
            candidate["data"] ?? candidate["matches"] ?? candidate["items"];
        if (nestedList is List) {
          return nestedList
              .whereType<Map>()
              .map((item) =>
                  MatchModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    }

    return const <MatchModel>[];
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
