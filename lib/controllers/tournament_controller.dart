import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/tournament_model.dart';
import '../data/services/tournament_service.dart';

class TournamentController extends GetxController {
  final tournaments = <TournamentModel>[].obs;
  final registeredTeams = <TournamentRegisteredTeamModel>[].obs;
  final tournamentTeamPlayers = <TournamentTeamPlayerModel>[].obs;
  final selectedTournamentSummary = Rxn<TournamentTeamsSummary>();
  final selectedTournamentTeamSummary = Rxn<TournamentTeamPlayersSummary>();
  final selectedTournamentDetail = Rxn<TournamentDetailModel>();
  final isLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  final isTeamsLoading = false.obs;
  final isPlayersLoading = false.obs;
  final isDetailLoading = false.obs;
  final errorMessage = ''.obs;
  final teamsErrorMessage = ''.obs;
  final playersErrorMessage = ''.obs;
  final detailErrorMessage = ''.obs;
  final totalTournaments = 0.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final selectedStatus = 'open'.obs;

  bool get hasMoreTournaments => currentPage.value < lastPage.value;

  Future<void> loadTournaments({
    bool loadMore = false,
    String? status,
  }) async {
    try {
      final activeStatus = (status ?? selectedStatus.value).trim().toLowerCase();
      if (!loadMore) {
        selectedStatus.value = activeStatus;
      }
      final nextPage = loadMore ? currentPage.value + 1 : 1;
      if (loadMore) {
        if (isLoadMoreLoading.value || !hasMoreTournaments) {
          return;
        }
        isLoadMoreLoading.value = true;
      } else {
        isLoading.value = true;
        errorMessage.value = '';
      }
      final response = await TournamentService.fetchTournaments(
        page: nextPage,
        status: activeStatus,
      );
      if (loadMore) {
        tournaments.addAll(response.tournaments);
      } else {
        tournaments.assignAll(response.tournaments);
      }
      totalTournaments.value = response.total;
      currentPage.value = response.currentPage;
      lastPage.value = response.lastPage;
    } catch (e) {
      if (!loadMore) {
        tournaments.clear();
        totalTournaments.value = 0;
        currentPage.value = 1;
        lastPage.value = 1;
      }
      errorMessage.value = _readableError(e);
      debugPrint(
        '[TournamentController] loadTournaments failed: ${errorMessage.value}',
      );
    } finally {
      if (loadMore) {
        isLoadMoreLoading.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadTournamentTeams(int tournamentId) async {
    try {
      isTeamsLoading.value = true;
      teamsErrorMessage.value = '';
      final response = await TournamentService.fetchTournamentTeams(tournamentId);
      selectedTournamentSummary.value = response.tournament;
      registeredTeams.assignAll(response.teams);
    } catch (e) {
      selectedTournamentSummary.value = null;
      registeredTeams.clear();
      teamsErrorMessage.value = _readableError(e);
      debugPrint(
        '[TournamentController] loadTournamentTeams failed: ${teamsErrorMessage.value}',
      );
    } finally {
      isTeamsLoading.value = false;
    }
  }

  Future<void> loadTournamentDetail(int tournamentId) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';
      final response = await TournamentService.fetchTournamentDetail(
        tournamentId,
      );
      selectedTournamentDetail.value = response.tournament;
    } catch (e) {
      selectedTournamentDetail.value = null;
      detailErrorMessage.value = _readableError(e);
      debugPrint(
        '[TournamentController] loadTournamentDetail failed: ${detailErrorMessage.value}',
      );
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> loadTournamentTeamPlayers(int tournamentId, int teamId) async {
    try {
      isPlayersLoading.value = true;
      playersErrorMessage.value = '';
      final response = await TournamentService.fetchTournamentTeamPlayers(
        tournamentId,
        teamId,
      );
      selectedTournamentTeamSummary.value = response.team;
      tournamentTeamPlayers.assignAll(response.players);
    } catch (e) {
      selectedTournamentTeamSummary.value = null;
      tournamentTeamPlayers.clear();
      playersErrorMessage.value = _readableError(e);
      debugPrint(
        '[TournamentController] loadTournamentTeamPlayers failed: ${playersErrorMessage.value}',
      );
    } finally {
      isPlayersLoading.value = false;
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
