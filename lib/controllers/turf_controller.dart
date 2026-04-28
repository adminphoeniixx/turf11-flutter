import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../core/location_service.dart';
import '../data/models/turf_model.dart';
import '../data/services/turf_service.dart';

class TurfController extends GetxController {
  final turfs = <TurfModel>[].obs;
  final slots = <TurfSlotModel>[].obs;
  final reviews = <TurfReviewModel>[].obs;
  final selectedTurf = Rxn<TurfModel>();
  final isLoading = false.obs;
  final isSlotsLoading = false.obs;
  final isDetailLoading = false.obs;
  final errorMessage = ''.obs;
  final slotsErrorMessage = ''.obs;
  final detailErrorMessage = ''.obs;
  final isUsingFallbackLocation = false.obs;

  Future<void> loadNearbyTurfs({int radius = 20}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // final location = await LocationService.getCurrentOrFallbackLocation();
      // isUsingFallbackLocation.value = location.isFallback;
      isUsingFallbackLocation.value = true;
      final result = await TurfService.fetchNearbyTurfs(
        lat: 28.4595,
        lng: 77.0266,
        radius: radius,
      );
      turfs.assignAll(result);
    } catch (e) {
      turfs.clear();
      errorMessage.value = _readableError(e);
      debugPrint('[TurfController] loadNearbyTurfs failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableSlots({
    required int turfId,
    required String date,
  }) async {
    try {
      isSlotsLoading.value = true;
      slotsErrorMessage.value = '';
      final result = await TurfService.fetchAvailableSlots(
        turfId: turfId,
        date: date,
      );
      final selectedDate = _parseSelectedDate(date);
      final visibleSlots = selectedDate == null
          ? result
          : result
              .where((slot) => !slot.isExpiredForDate(selectedDate))
              .toList();
      slots.assignAll(visibleSlots);
    } catch (e) {
      slots.clear();
      slotsErrorMessage.value = _readableError(e);
      debugPrint('[TurfController] loadAvailableSlots failed: $e');
    } finally {
      isSlotsLoading.value = false;
    }
  }

  Future<void> loadTurfDetail(int turfId) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';
      final result = await TurfService.fetchTurfDetail(turfId);
      selectedTurf.value = result.turf;
      reviews.assignAll(result.reviews);
    } catch (e) {
      selectedTurf.value = null;
      reviews.clear();
      detailErrorMessage.value = _readableError(e);
      debugPrint('[TurfController] loadTurfDetail failed: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  String _readableError(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  DateTime? _parseSelectedDate(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(normalized);
    if (direct != null) {
      return direct;
    }

    final parts = normalized.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}
