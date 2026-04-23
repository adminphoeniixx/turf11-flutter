import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/team_model.dart';
import '../data/services/team_service.dart';

class TeamController extends GetxController {
  final teams = <TeamModel>[].obs;
  final selectedTeam = Rxn<TeamModel>();
  final invite = Rxn<TeamInviteModel>();
  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final isInviteLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final detailErrorMessage = ''.obs;

  Future<void> loadTeams() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await TeamService.fetchMyTeams();
      teams.assignAll(result);
    } catch (e) {
      teams.clear();
      errorMessage.value = _readableError(e);
      debugPrint('[TeamController] loadTeams failed: ${errorMessage.value}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeamDetail(int teamId) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';
      selectedTeam.value = await TeamService.fetchTeamDetail(teamId);
    } catch (e) {
      detailErrorMessage.value = _readableError(e);
      debugPrint(
        '[TeamController] loadTeamDetail failed: ${detailErrorMessage.value}',
      );
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<TeamActionResult> createTeam({
    required String name,
    required String sport,
    required String city,
  }) async {
    return _runMutation(() async {
      final result = await TeamService.createTeam(
        name: name,
        sport: sport,
        city: city,
      );
      await loadTeams();
      return result;
    });
  }

  Future<TeamActionResult> updateTeam({
    required int teamId,
    required String name,
    required String sport,
    required String city,
  }) async {
    return _runMutation(() async {
      final result = await TeamService.updateTeam(
        teamId: teamId,
        name: name,
        sport: sport,
        city: city,
      );
      await Future.wait([
        loadTeams(),
        loadTeamDetail(teamId),
      ]);
      return result;
    });
  }

  Future<TeamActionResult> deleteTeam(int teamId) async {
    return _runMutation(() async {
      final result = await TeamService.deleteTeam(teamId);
      await loadTeams();
      if (selectedTeam.value?.id == teamId) {
        selectedTeam.value = null;
      }
      return result;
    });
  }

  Future<TeamActionResult> joinTeamByCode(String code) async {
    return _runMutation(() async {
      final result = await TeamService.joinTeamByCode(code);
      await loadTeams();
      return result;
    });
  }

  Future<TeamActionResult> removeMember({
    required int teamId,
    required int memberId,
  }) async {
    return _runMutation(() async {
      final result = await TeamService.removeMember(
        teamId: teamId,
        memberId: memberId,
      );
      await Future.wait([
        loadTeams(),
        loadTeamDetail(teamId),
      ]);
      return result;
    });
  }

  Future<TeamActionResult> leaveTeam(int teamId) async {
    return _runMutation(() async {
      final result = await TeamService.leaveTeam(teamId);
      await loadTeams();
      if (selectedTeam.value?.id == teamId) {
        selectedTeam.value = null;
      }
      return result;
    });
  }

  Future<TeamInviteModel?> loadInviteLink(int teamId) async {
    try {
      isInviteLoading.value = true;
      invite.value = await TeamService.fetchInviteLink(teamId);
      return invite.value;
    } catch (e) {
      Get.snackbar('Error', _readableError(e));
      return null;
    } finally {
      isInviteLoading.value = false;
    }
  }

  Future<TeamTournamentRegistrationResult> registerTeamForTournament({
    required int tournamentId,
    required int playerTeamId,
  }) async {
    try {
      isSaving.value = true;
      final result = await TeamService.registerTeamForTournament(
        tournamentId: tournamentId,
        playerTeamId: playerTeamId,
      );
      if (result.message.isNotEmpty) {
        Get.snackbar(result.success ? 'Success' : 'Error', result.message);
      }
      return result;
    } catch (e) {
      final message = _readableError(e);
      Get.snackbar('Error', message);
      return TeamTournamentRegistrationResult(
        success: false,
        message: message,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<TeamActionResult> _runMutation(
    Future<TeamActionResult> Function() task,
  ) async {
    try {
      isSaving.value = true;
      final result = await task();
      if (result.message.isNotEmpty) {
        Get.snackbar(result.success ? 'Success' : 'Error', result.message);
      }
      return result;
    } catch (e) {
      final message = _readableError(e);
      Get.snackbar('Error', message);
      return TeamActionResult(
        success: false,
        message: message,
      );
    } finally {
      isSaving.value = false;
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
