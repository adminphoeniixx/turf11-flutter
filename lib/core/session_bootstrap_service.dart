import 'dart:async';

import 'package:get/get.dart';

import '../controllers/booking_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/team_controller.dart';
import '../controllers/tournament_controller.dart';
import '../controllers/turf_controller.dart';
import '../controllers/wallet_controller.dart';

class SessionBootstrapService {
  SessionBootstrapService._();

  static Future<void>? _bootstrapFuture;

  static Future<void> bootstrapSession({
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _bootstrapFuture != null) {
      return _bootstrapFuture!;
    }

    final future = _runBootstrap(forceRefresh: forceRefresh);
    _bootstrapFuture = future.whenComplete(() {
      if (identical(_bootstrapFuture, future)) {
        _bootstrapFuture = null;
      }
    });
    return _bootstrapFuture!;
  }

  static Future<void> _runBootstrap({
    required bool forceRefresh,
  }) async {
    final profileController = _ensureController<ProfileController>(
      () => ProfileController(),
    );
    final walletController = _ensureController<WalletController>(
      () => WalletController(),
    );
    final turfController = _ensureController<TurfController>(
      () => TurfController(),
    );
    final matchController = _ensureController<MatchController>(
      () => MatchController(),
    );
    final tournamentController = _ensureController<TournamentController>(
      () => TournamentController(),
    );
    final bookingController = _ensureController<BookingController>(
      () => BookingController(),
    );
    final teamController = _ensureController<TeamController>(
      () => TeamController(),
    );

    final tasks = <Future<void>>[
      if (forceRefresh ||
          (profileController.profile.value == null &&
              !profileController.isLoading.value))
        profileController.loadProfile(),
      if (forceRefresh ||
          (walletController.wallet.value == null &&
              !walletController.isLoading.value))
        walletController.loadWallet(),
      if (forceRefresh ||
          (walletController.transactions.isEmpty &&
              !walletController.isTransactionsLoading.value))
        walletController.loadTransactions(),
      if (forceRefresh ||
          (turfController.turfs.isEmpty && !turfController.isLoading.value))
        turfController.loadNearbyTurfs(),
      if (forceRefresh ||
          (matchController.nearbyMatches.isEmpty &&
              !matchController.isNearbyLoading.value))
        matchController.loadNearbyMatches(),
      if (forceRefresh ||
          (matchController.myMatches.isEmpty &&
              !matchController.isMyMatchesLoading.value))
        matchController.loadMyMatches(),
      if (forceRefresh ||
          (tournamentController.tournaments.isEmpty &&
              !tournamentController.isLoading.value))
        tournamentController.loadTournaments(
          status: tournamentController.selectedStatus.value,
        ),
      if (forceRefresh ||
          (bookingController.bookings.isEmpty && !bookingController.isLoading.value))
        bookingController.loadBookings(
          status: bookingController.selectedStatus.value,
        ),
      if (forceRefresh ||
          (teamController.teams.isEmpty && !teamController.isLoading.value))
        teamController.loadTeams(),
    ];

    await Future.wait(tasks);
  }

  static T _ensureController<T extends GetxController>(T Function() create) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return Get.put<T>(create(), permanent: true);
  }

  static Future<void> clearSessionControllers() async {
    _bootstrapFuture = null;

    await _deleteIfRegistered<BookingController>();
    await _deleteIfRegistered<MatchController>();
    await _deleteIfRegistered<ProfileController>();
    await _deleteIfRegistered<TeamController>();
    await _deleteIfRegistered<TournamentController>();
    await _deleteIfRegistered<TurfController>();
    await _deleteIfRegistered<WalletController>();
  }

  static Future<void> _deleteIfRegistered<T extends GetxController>() async {
    if (Get.isRegistered<T>()) {
      await Get.delete<T>(force: true);
    }
  }
}
