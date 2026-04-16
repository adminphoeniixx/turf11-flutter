import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../core/location_service.dart';
import '../data/models/match_model.dart';
import '../data/services/match_service.dart';

class MatchController extends GetxController {
  static const defaultLat = 28.4595;
  static const defaultLng = 77.0266;
  static const defaultRadius = 20;

  final nearbyMatches = <MatchModel>[].obs;
  final myMatches = <MatchModel>[].obs;
  final selectedMatch = Rxn<MatchModel>();
  final joinedStateOverrides = <int, bool>{}.obs;

  final isNearbyLoading = false.obs;
  final isMyMatchesLoading = false.obs;
  final isDetailLoading = false.obs;
  final isCreateLoading = false.obs;
  final isJoinLoading = false.obs;
  final isUsingFallbackLocation = false.obs;
  final currentLat = defaultLat.obs;
  final currentLng = defaultLng.obs;

  Future<void> loadNearbyMatches({
    double? lat,
    double? lng,
    int radius = defaultRadius,
  }) async {
    try {
      isNearbyLoading.value = true;
      late final double requestLat;
      late final double requestLng;
      if (lat == null || lng == null) {
        final location = await _resolveLocation();
        requestLat = location.latitude;
        requestLng = location.longitude;
      } else {
        currentLat.value = lat;
        currentLng.value = lng;
        isUsingFallbackLocation.value = false;
        requestLat = lat;
        requestLng = lng;
      }
      final matches = await MatchService.fetchNearbyMatches(
        lat: requestLat,
        lng: requestLng,
        radius: radius,
      );
      nearbyMatches.assignAll(matches);
    } catch (e) {
      _logError('loadNearbyMatches', e);
    } finally {
      isNearbyLoading.value = false;
    }
  }

  Future<void> loadMyMatches() async {
    try {
      isMyMatchesLoading.value = true;
      final matches = await MatchService.fetchMyMatches();
      myMatches.assignAll(matches);
    } catch (e) {
      _logError('loadMyMatches', e);
    } finally {
      isMyMatchesLoading.value = false;
    }
  }

  Future<void> loadMatchDetail(int matchId) async {
    try {
      isDetailLoading.value = true;
      selectedMatch.value = await MatchService.fetchMatchDetail(matchId);
    } catch (e) {
      _logError('loadMatchDetail', e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<MatchModel?> createMatch(Map<String, dynamic> payload) async {
    try {
      isCreateLoading.value = true;
      final match = await MatchService.createMatch(payload);
      setMatchJoinedState(match.id, true);
      Get.snackbar("Success", "Match created successfully.");
      await refreshAll();
      return match;
    } catch (e) {
      _logError('createMatch', e);
      return null;
    } finally {
      isCreateLoading.value = false;
    }
  }

  Future<bool> joinMatch(int matchId) async {
    if (matchId <= 0) {
      debugPrint("[MatchController] joinMatch blocked: invalid match id");
      return false;
    }
    try {
      isJoinLoading.value = true;
      final message = await MatchService.joinMatch(matchId);
      setMatchJoinedState(matchId, true);
      Get.snackbar("Success", message);
      await _refreshAfterMutation(matchId);
      return true;
    } catch (e) {
      _logError('joinMatch', e);
      return false;
    } finally {
      isJoinLoading.value = false;
    }
  }

  Future<bool> leaveMatch(int matchId) async {
    if (matchId <= 0) {
      debugPrint("[MatchController] leaveMatch blocked: invalid match id");
      return false;
    }
    try {
      isJoinLoading.value = true;
      final message = await MatchService.leaveMatch(matchId);
      setMatchJoinedState(matchId, false);
      Get.snackbar("Success", message);
      await _refreshAfterMutation(matchId);
      return true;
    } catch (e) {
      _logError('leaveMatch', e);
      return false;
    } finally {
      isJoinLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    final location = await _resolveLocation();
    await Future.wait([
      loadNearbyMatches(
        lat: location.latitude,
        lng: location.longitude,
      ),
      loadMyMatches(),
    ]);
  }

  Future<void> _refreshAfterMutation(int matchId) async {
    final location = await _resolveLocation();
    await Future.wait([
      loadNearbyMatches(
        lat: location.latitude,
        lng: location.longitude,
      ),
      loadMyMatches(),
      loadMatchDetail(matchId),
    ]);
  }

  Future<AppLocation> _resolveLocation() async {
    final location = await LocationService.getCurrentOrFallbackLocation();
    currentLat.value = location.latitude;
    currentLng.value = location.longitude;
    isUsingFallbackLocation.value = location.isFallback;
    return location;
  }

  bool isMatchJoined(int matchId, {bool fallback = false}) {
    return joinedStateOverrides[matchId] ?? fallback;
  }

  void setMatchJoinedState(int matchId, bool isJoined) {
    if (matchId <= 0) {
      return;
    }
    joinedStateOverrides[matchId] = isJoined;
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith("Exception: ")) {
      return raw.substring("Exception: ".length);
    }
    return raw;
  }

  void _logError(String action, Object error) {
    debugPrint("[MatchController] $action failed: ${_readableError(error)}");
  }
}
