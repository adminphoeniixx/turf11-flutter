import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/tournament_model.dart';

class TournamentService {
  static Future<TournamentListResponse> fetchTournaments({int page = 1}) async {
    final res = await ApiClient.get(
      ApiConstants.tournaments,
      queryParameters: {'page': page},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return TournamentListResponse.fromJson(data);
    }
    if (data is Map) {
      return TournamentListResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const TournamentListResponse(
      tournaments: <TournamentModel>[],
      currentPage: 1,
      lastPage: 1,
      total: 0,
    );
  }

  static Future<TournamentTeamsResponse> fetchTournamentTeams(
    int tournamentId,
  ) async {
    final res = await ApiClient.get(ApiConstants.tournamentTeams(tournamentId));
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return TournamentTeamsResponse.fromJson(data);
    }
    if (data is Map) {
      return TournamentTeamsResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const TournamentTeamsResponse(
      tournament: null,
      teams: <TournamentRegisteredTeamModel>[],
      count: 0,
    );
  }

  static Future<TournamentTeamPlayersResponse> fetchTournamentTeamPlayers(
    int tournamentId,
    int teamId,
  ) async {
    final res = await ApiClient.get(
      ApiConstants.tournamentTeamPlayers(tournamentId, teamId),
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return TournamentTeamPlayersResponse.fromJson(data);
    }
    if (data is Map) {
      return TournamentTeamPlayersResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    return const TournamentTeamPlayersResponse(
      team: null,
      players: <TournamentTeamPlayerModel>[],
      count: 0,
    );
  }
}
