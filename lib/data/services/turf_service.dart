import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/turf_model.dart';

class TurfService {
  static Future<List<TurfModel>> fetchNearbyTurfs({
    required double lat,
    required double lng,
    int radius = 20,
  }) async {
    final res = await ApiClient.get(
      ApiConstants.turfsNearby,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        
        'radius': radius,
      },
    );

    final root = _toMap(res.data);
    final candidates = [
      root['turfs'],
      root['data'],
      root,
    ];

    for (final candidate in candidates) {
      final list = _extractList(candidate);
      if (list.isNotEmpty) {
        return list;
      }
    }

    return const <TurfModel>[];
  }

  static Future<TurfDetailResponse> fetchTurfDetail(int turfId) async {
    final res = await ApiClient.get(ApiConstants.turfDetail(turfId));
    final map = _toMap(res.data);
    if (map.isEmpty) {
      return const TurfDetailResponse(turf: null, reviews: <TurfReviewModel>[]);
    }
    return TurfDetailResponse.fromJson(map);
  }

  static Future<List<TurfSlotModel>> fetchAvailableSlots({
    required int turfId,
    required String date,
  }) async {
    final res = await ApiClient.get(
      ApiConstants.turfSlots(turfId),
      queryParameters: {'date': date},
    );

    final root = _toMap(res.data);
    final candidates = [
      root['slots'],
      root['data'],
      root,
    ];

    for (final candidate in candidates) {
      final list = _extractSlots(candidate);
      if (list.isNotEmpty) {
        return list;
      }
    }

    return const <TurfSlotModel>[];
  }

  static List<TurfModel> _extractList(dynamic candidate) {
    if (candidate is List) {
      return candidate
          .whereType<Map>()
          .map((item) => TurfModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (candidate is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'turfs']) {
        final nested = candidate[key];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map(
                (item) => TurfModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
    }
    return const <TurfModel>[];
  }

  static List<TurfSlotModel> _extractSlots(dynamic candidate) {
    if (candidate is List) {
      return candidate
          .whereType<Map>()
          .map((item) => TurfSlotModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (candidate is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'slots']) {
        final nested = candidate[key];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map(
                (item) =>
                    TurfSlotModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
    }
    return const <TurfSlotModel>[];
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
