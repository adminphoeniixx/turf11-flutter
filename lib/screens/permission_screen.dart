import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/location_service.dart';
import '../data/services/fcm_token_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PermissionScreen extends StatefulWidget {
  final Widget nextScreen;

  const PermissionScreen({
    super.key,
    required this.nextScreen,
  });

  static Future<bool> areRequiredPermissionsEnabled() async {
    final locationPermission = await Geolocator.checkPermission();
    final notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    final isLocationEnabled = locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse;
    final isNotificationEnabled = _isNotificationEnabled(
      notificationSettings.authorizationStatus,
    );

    return isLocationEnabled && isNotificationEnabled;
  }

  static bool _isNotificationEnabled(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  bool _locationEnabled = false;
  bool _notificationEnabled = false;
  bool _isLoading = true;
  bool _isRequestingLocation = false;
  bool _isRequestingNotification = false;
  bool _isRouting = false;

  bool get _allEnabled => _locationEnabled && _notificationEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadPermissionState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadPermissionState());
    }
  }

  Future<void> _loadPermissionState() async {
    final locationPermission = await Geolocator.checkPermission();
    final notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _locationEnabled = locationPermission == LocationPermission.always ||
          locationPermission == LocationPermission.whileInUse;
      _notificationEnabled = PermissionScreen._isNotificationEnabled(
        notificationSettings.authorizationStatus,
      );
      _isLoading = false;
    });

    if (_allEnabled) {
      _goNext();
    }
  }

  Future<void> _requestLocation() async {
    if (_locationEnabled || _isRequestingLocation) {
      return;
    }

    setState(() => _isRequestingLocation = true);
    try {
      final permission = await LocationService.ensureLocationPermission();
      if (!mounted) {
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showSettingsMessage(
          'Please enable location permission from settings.',
          LocationService.openAppSettings,
        );
      }

      setState(() {
        _locationEnabled = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } finally {
      if (mounted) {
        setState(() => _isRequestingLocation = false);
      }
    }

    if (_allEnabled) {
      _goNext();
    }
  }

  Future<void> _requestNotification() async {
    if (_notificationEnabled || _isRequestingNotification) {
      return;
    }

    setState(() => _isRequestingNotification = true);
    try {
      final settings = await FcmTokenService.requestNotificationPermission();
      unawaited(FcmTokenService.syncDeviceToken());
      if (!mounted) {
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _showSettingsMessage(
          'Please enable notification permission from settings.',
          LocationService.openAppSettings,
        );
      }

      setState(() {
        _notificationEnabled = PermissionScreen._isNotificationEnabled(
          settings.authorizationStatus,
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isRequestingNotification = false);
      }
    }

    if (_allEnabled) {
      _goNext();
    }
  }

  void _showSettingsMessage(
    String message,
    Future<bool> Function() openSettings,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => unawaited(openSettings()),
        ),
      ),
    );
  }

  void _goNext() {
    if (_isRouting || !mounted) {
      return;
    }
    _isRouting = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(width: 160),
                    const SizedBox(height: 28),
                    Text(
                      'Permissions',
                      style: textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turf11 needs these permissions to give you the best experience.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PermissionTile(
                      icon: LucideIcons.mapPin,
                      title: 'Location',
                      description:
                          'Your current location helps us show nearby turfs, matches, and players.',
                      value: _locationEnabled,
                      isLoading: _isRequestingLocation,
                      onChanged: (_) => unawaited(_requestLocation()),
                    ),
                    _PermissionTile(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      description:
                          'Notifications keep you updated about bookings, matches, wallet activity, and important alerts.',
                      value: _notificationEnabled,
                      isLoading: _isRequestingNotification,
                      onChanged: (_) => unawaited(_requestNotification()),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: _allEnabled ? 'Continue' : 'Enable permissions',
                      color: AppColors.green,
                      onTap: _allEnabled
                          ? _goNext
                          : () {
                              if (!_locationEnabled) {
                                unawaited(_requestLocation());
                                return;
                              }
                              if (!_notificationEnabled) {
                                unawaited(_requestNotification());
                              }
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.greenLt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    height: 1.35,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.green,
                    ),
                  ),
                )
              : Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.green,
                  activeTrackColor: AppColors.greenLt,
                  inactiveThumbColor: AppColors.muted2,
                  inactiveTrackColor: AppColors.border,
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
        ],
      ),
    );
  }
}
