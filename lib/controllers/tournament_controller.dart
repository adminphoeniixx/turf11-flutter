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
  final isLoading = false.obs;
  final isTeamsLoading = false.obs;
  final isPlayersLoading = false.obs;
  final errorMessage = ''.obs;
  final teamsErrorMessage = ''.obs;
  final playersErrorMessage = ''.obs;
  final totalTournaments = 0.obs;

  Future<void> loadTournaments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await TournamentService.fetchTournaments();
      tournaments.assignAll(response.tournaments);
      totalTournaments.value = response.total;
    } catch (e) {
      tournaments.clear();
      totalTournaments.value = 0;
      errorMessage.value = _readableError(e);
      debugPrint(
        '[TournamentController] loadTournaments failed: ${errorMessage.value}',
      );
    } finally {
      isLoading.value = false;
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
