import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../core/storage_service.dart';

class FcmTokenService {
  static bool _isSyncing = false;

  static Future<NotificationSettings> requestNotificationPermission() {
    return FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> syncDeviceToken() async {
    if (_isSyncing) {
      return;
    }

    final hasToken = await StorageService.hasToken();
    if (!hasToken) {
      debugPrint('[FcmTokenService] Skipped because user is not logged in.');
      return;
    }

    try {
      _isSyncing = true;
      final messaging = FirebaseMessaging.instance;
      await requestNotificationPermission();

      final fcmToken = await messaging.getToken();
      if (fcmToken == null || fcmToken.trim().isEmpty) {
        debugPrint('[FcmTokenService] Firebase returned empty FCM token.');
        return;
      }

      await ApiClient.post(
        ApiConstants.fcmToken,
        data: {
          'fcm_token': fcmToken,
        },
      );
      debugPrint('[FcmTokenService] FCM token synced successfully.');
    } catch (e) {
      debugPrint('[FcmTokenService] syncDeviceToken failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
