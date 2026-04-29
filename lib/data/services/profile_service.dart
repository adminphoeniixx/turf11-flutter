import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/profile_model.dart';

class ProfileService {
  static Future<PlayerProfileResponse> fetchProfile() async {
    final res = await ApiClient.get(ApiConstants.profile);
    return PlayerProfileResponse.fromJson(_toMap(res.data));
  }

  static Future<PlayerProfileResponse> updateProfile({
    required String name,
    required String email,
    required String city,
    required List<String> sports,
  }) async {
    final res = await ApiClient.put(
      ApiConstants.profile,
      data: {
        'name': name,
        'email': email,
        'city': city,
        'sports': sports,
      },
    );
    return PlayerProfileResponse.fromJson(_toMap(res.data));
  }

  static Future<PlayerProfileResponse> updateLocation({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    final res = await ApiClient.put(
      ApiConstants.profile,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
      },
    );
    return PlayerProfileResponse.fromJson(_toMap(res.data));
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
