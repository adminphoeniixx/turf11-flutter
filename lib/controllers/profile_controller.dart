import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/profile_model.dart';
import '../data/services/profile_service.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final profile = Rxn<PlayerProfile>();
  final errorMessage = ''.obs;

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await ProfileService.fetchProfile();
      profile.value = response.player;
    } catch (e) {
      final message = _readableError(e);
      errorMessage.value = message;
      debugPrint('[ProfileController] loadProfile failed: $message');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String city,
    required List<String> sports,
  }) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';
      final response = await ProfileService.updateProfile(
        name: name,
        email: email,
        city: city,
        sports: sports,
      );
      profile.value = response.player;
      Get.snackbar('Success', 'Profile updated');
      return true;
    } catch (e) {
      final message = _readableError(e);
      errorMessage.value = message;
      Get.snackbar('Error', message);
      debugPrint('[ProfileController] updateProfile failed: $message');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }
}
